package encore.backend.audio;

import flixel.FlxG;
import flixel.sound.FlxSound;

/**
 * Class which holds the paths for the stems of a song.
 */
class StemPaths
{
	public var DRUMS:Array<String> = [];
	public var BACKING:Array<String> = [];
	public var BASS:Array<String> = [];
	public var LEAD:Array<String> = [];
	public var VOCALS:Array<String> = [];

	/**
	 * Construct a new stem path structure
	 * @param stemsObject The `stems` object, given by an `InfoJson` parsed `info.json` file.
	 */
	public function new(stemsObject:Dynamic)
	{
		DRUMS = stemsObject.drums;
		BACKING = stemsObject.backing;
		BASS = stemsObject.bass;
		LEAD = stemsObject.lead;
		VOCALS = stemsObject.vocals;
	}
}

/**
 * Class to manage multiple FlxSound instances, as stems for a song.
 */
class StemGroup
{
	public var paths:StemPaths;
	public var folderPath:String;
	public var soundList:Array<FlxSound> = [];
	public var time:Float;
	public var length:Float;

	/**
	 * Construct a new group of stems.
	 * @param paths `StemPaths` object.
	 */
	public function new(folderPath:String, paths:StemPaths)
	{
		this.paths = paths;
		this.folderPath = folderPath;
	}

	public function loadAll()
	{
		loadSoundByGroup(paths.BACKING);
		loadSoundByGroup(paths.VOCALS);
		loadSoundByGroup(paths.DRUMS);
		loadSoundByGroup(paths.BASS);
		loadSoundByGroup(paths.LEAD);
	}

	public function loadSoundByGroup(group:Array<String>)
	{
		for (stem in group)
		{
			var filePath = folderPath + stem;

			var sound:FlxSound = new FlxSound();
			sound.loadEmbedded(filePath);
			FlxG.sound.list.add(sound);
			soundList.push(sound);
		}
	}

	public function playAll()
	{
		for (sound in soundList)
		{
			sound.play();
		}
	}
}