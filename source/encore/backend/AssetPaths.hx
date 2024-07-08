package encore.backend;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

/**
 * Macro based class
 * JUST IN CASE. Use the macro vars
**/
@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class Paths {
	static var cachedGraphics:Map<String, FlxGraphic> = [];
	static var cachedSounds:Map<String, Sound> = [];

	public static function getText(path:String):String
	{
        #if sys
        return File.getContent(path);
        #else
		return Assets.getText(path);
		#end
	}

	public static function getRandomSplashLine(splashPath:String = 'assets/data/splashes.txt'):String
	{
		var allLines = getText(splashPath).split('\n');

		return allLines[FlxG.random.int(0, allLines.length - 1)];
	}

	public static var songFolder:String = 'Songs/';

	public static var defaultSongs:Array<String> = ['Synthfox Soundworks - Untitled Chords Thing', '24kmagic'];

	public static function getListOfSongs():Array<String>
	{
		var songFolders:Array<String> = [];

		var allSongs:Array<String> = #if sys FileSystem.readDirectory(songFolder); #else defaultSongs; #end

		for (song in allSongs)
		{
			var pathToInfoJson = songFolder + song + '/info.json';
			// trace('Checking for ' + pathToInfoJson);
			if (#if sys FileSystem.exists(pathToInfoJson) #else Assets.exists(pathToInfoJson) #end)
			{
				// trace('Found info.json!');
				songFolders.push(song);
			}
		}
		return songFolders;
	}

	public static function getSound(path:String)
	{
		// may make sounds load much quicker??
		if (cachedSounds.exists(path))
			return cachedSounds.get(path);
		else
		{
			#if sys
			var sound = Sound.fromFile(path);
			#else
			var sound = Assets.getSound(path);
			#end
			cachedSounds.set(path, sound);
			return cachedSounds.get(path);
		}

		trace('sound not found and not created');
		return null;
    }
	public static function getImage(path:String)
	{
		// trace('Something wants to get a sound: ' + path);
		if (cachedGraphics.exists(path))
			return cachedGraphics.get(path);
		else
		{
			#if sys
			var bitmap = BitmapData.fromFile(path);
			#else
			var bitmap = Assets.getBitmapData(path);
			#end
			cachedGraphics.set(path, FlxGraphic.fromBitmapData(bitmap));
			return cachedGraphics.get(path);
		}

		trace('bitmap not found and not created');
		return null;
	}
}
