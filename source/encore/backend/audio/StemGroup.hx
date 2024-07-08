package encore.backend.audio;

import encore.backend.AssetPaths.Paths;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
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
class StemGroup extends FlxTypedGroup<FlxSound>
{
	public var paths:StemPaths;
	public var folderPath:String;
	public var time(get, set):Float;
	public var pitch(get, set):Float;
	public var volume(get, set):Float;
	public var playing(get, never):Bool;
	public var duration(get, never):Float;
	public var paused(default, set):Bool;

	/**
	 * Construct a new group of stems.
	 * @param paths `StemPaths` object.
	 */
	public function new(folderPath:String, paths:StemPaths)
	{
		this.paths = paths;
		this.folderPath = folderPath;
		super();
	}

	function get_playing():Bool
	{
		if (getFirstAlive() != null)
		{
			return getFirstAlive().playing;
		}
		else
		{
			return false;
		}
	}

	/**
	 * Warning! this will only return the first audio found's duration
	 * @return Float (not averaged out)
	 */
	function get_duration():Float
	{
		if (getFirstAlive() != null)
		{
			return getFirstAlive().length;
		}
		else
		{
			return 0;
		}
	}

	function get_volume():Float
	{
		if (getFirstAlive() != null)
		{
			return getFirstAlive().volume;
		}
		else
		{
			return 1;
		}
	}

	// in PlayState, adjust the code so that it only mutes the player1 vocal tracks?
	function set_volume(volume:Float):Float
	{
		forEachAlive(function(snd:FlxSound)
		{
			snd.volume = volume;
		});

		return volume;
	}

	// public var length:Float;

	function get_pitch():Float
	{
		#if FLX_PITCH
		if (getFirstAlive() != null)
			return getFirstAlive().pitch;
		else
		#end
		return 1;
	}

	function set_pitch(val:Float):Float
	{
		#if FLX_PITCH
		forEachAlive(function(snd:FlxSound)
		{
			snd.pitch = val;
		});
		#end
		return val;
	}

	function set_paused(val:Bool):Bool
	{
		forEachAlive(function(snd:FlxSound)
		{
			if (val)
				snd.pause();
			else
				snd.play();
		});

		return val;
	}

	function get_time():Float
	{
		if (getFirstAlive() != null)
		{
			return getFirstAlive().time;
		}
		else
		{
			return 0;
		}
	}

	function set_time(time:Float):Float
	{
		forEachAlive(function(snd:FlxSound)
		{
			// account for different offsets per sound?
			snd.time = time;
		});

		return time;
	}

	public function checkSyncError(?targetTime:Float):Float
	{
		var error:Float = 0;

		forEachAlive(function(snd)
		{
			if (targetTime == null)
				targetTime = snd.time;
			else
			{
				var diff:Float = snd.time - targetTime;
				if (Math.abs(diff) > Math.abs(error))
					error = diff;
			}
		});
		return error;
	}

	public dynamic function onComplete():Void {}

	public override function add(sound:FlxSound):FlxSound
	{
		var result:FlxSound = super.add(sound);

		if (result == null)
			return null;

		result.time = this.time;

		result.onComplete = function()
		{
			this.onComplete();
		}

		// Apply parameters to the new sound.
		result.pitch = this.pitch;
		result.volume = this.volume;

		return result;
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

			// trace('Attempting to load ' + filePath);

			var sound:FlxSound = new FlxSound();
			sound.loadEmbedded(Paths.getSound(filePath));
			FlxG.sound.list.add(sound);
			add(sound);
		}
	}

	public function playAll()
	{
		forEachAlive(function(snd:FlxSound)
		{
			snd.play();
		});
	}

	public function pauseAll()
	{
		forEachAlive(function(snd:FlxSound)
		{
			snd.pause();
		});
	}

	public function stop()
	{
		if (members != null)
		{
			forEachAlive(function(sound:FlxSound)
			{
				sound.stop();
			});
		}
	}
  
	public override function destroy()
	{
		stop();
		super.destroy();
	}
	public override function clear()
	{
		this.stop();

		super.clear();
	}
}