package;

import encore.backend.songs.SongHandler;
import flixel.FlxState;

class GameState extends FlxState
{
	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (SongHandler.instance.currentPlayingStems != null)
		{
			// avoid audio being unsynced by 0.1ms
			if (SongHandler.instance.currentPlayingStems.checkSyncError() > 100)
			{
				SongHandler.instance.currentPlayingStems.time = SongHandler.instance.currentPlayingStems.time; // assign all times to itself's time because we have nothing else to choose from, lol
			}
		}
		super.update(elapsed);
	}
}
