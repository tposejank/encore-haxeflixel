package encore.backend;

import flixel.FlxG;
import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.CallStack;
import lime.app.Application;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;

using StringTools;
#if sys
import sys.FileSystem;
import sys.io.File;
#end


/**
 * A custom crash handler that writes to a log file and displays a message box.
 */
@:nullSafety
class CrashHandler
{
	public static final LOG_FOLDER = 'logs';

	/**
	 * Initializes
	 */
	public static function initialize():Void
	{
		trace('Enabling standard uncaught error handler...');
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

		#if cpp
		trace('Enabling C++ critical error handler...');
		untyped __global__.__hxcpp_set_critical_error_handler(onCriticalError);
		#end
	}

	static function generateTimestamp(?date:Date = null):String
	{
		if (date == null)
			date = Date.now();

		return
			'${date.getFullYear()}-${Std.string(date.getMonth() + 1).lpad('0', 2)}-${Std.string(date.getDate()).lpad('0', 2)}-${Std.string(date.getHours()).lpad('0', 2)}-${Std.string(date.getMinutes()).lpad('0', 2)}-${Std.string(date.getSeconds()).lpad('0', 2)}';
	}

	/**
	 * Called when an uncaught error occurs.
	 * This handles most thrown errors, and is sufficient to handle everything alone on HTML5.
	 * @param error Information on the error that was thrown.
	 */
	static function onUncaughtError(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		
		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "Encore_" + dateNow + ".txt";

		var platform:String = 'unknown';
		#if sys
		platform = Sys.systemName();
		#end

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(innerStackItem, file, line, column):
					errMsg += '  in ${file}#${line}';
					if (column != null)
						errMsg += ':${column}';
				case CFunction:
					errMsg += '[Function] ';
				case Module(m):
					errMsg += '[Module(${m})] ';
				case Method(classname, method):
					errMsg += '[Function(${classname}.${method})] ';
				case LocalFunction(v):
					errMsg += '[LocalFunction(${v})] ';
				default:
					#if sys Sys.println(stackItem); #end
			}
		}
		errMsg += "\nUncaught Error: \nState: "
			+ '\n${errMsg}
		Time: ${generateTimestamp()}
		Driver: ${FlxG?.stage?.context3D?.driverInfo ?? 'N/A'}
		System: ${platform}
		';

		#if sys
		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.exit(1);
		#end

		Application.current.window.alert(errMsg, "Error Caught");
	}

	static function onCriticalError(message:String):Void
	{
		var errMsg:String = "\nCritical Error: " + message;
		// no point in handling these im not smart
		Application.current.window.alert(errMsg, "Fatal Critical Error");
	}
}
