package encore.backend;

import lime.graphics.Image;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

/**
 * Macro based class
**/
@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class Paths {
	public static function getText(path:String):String
	{
        #if sys
        return File.getContent(path);
        #else
		return Assets.getText(path);
		#end
	}

	public static var songFolder:String = 'Songs/';

	public static function getListOfSongs():Array<String>
	{
		var songFolders:Array<String> = [];

		var allSongs:Array<String> = #if sys FileSystem.readDirectory(songFolder); #else ['Synthfox Soundworks - Untitled Chords Thing']; #end

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
		// trace('Something wants to get a sound: ' + path);
		#if sys
		return Sound.fromFile(path);
		#else
		return Assets.getSound(path);
        #end
    }
	public static function getImage(path:String)
	{
		// trace('Something wants to get a sound: ' + path);
		#if sys
		return BitmapData.fromFile(path);
		#else
		return Assets.getBitmapData(path);
		#end
	}
}
