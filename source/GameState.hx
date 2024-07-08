package;

import encore.backend.AssetPaths.Paths;
import encore.backend.shaders.MenuBlur;
import encore.backend.shaders.MenuBlurHtml5;
import encore.backend.songs.SongHandler;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class GameState extends FlxState
{
	var albumArtImage:FlxSprite;

	// yes, both look horrible. I know
	#if sys
	var wavyShader:MenuBlur;
	#else
	var wavyShader:MenuBlurHtml5;
	#end

	override public function create()
	{
		super.create();
		albumArtImage = new FlxSprite();
		wavyShader = new #if sys MenuBlur(); #else MenuBlurHtml5(); #end
	}

	public function fillScreenWithAlbumArt()
	{
		var initialImageWidth:Float = albumArtImage.width;
		var preferredWidth:Int = FlxG.width;
		var ratioIncrease:Float = preferredWidth / initialImageWidth;
		albumArtImage.setGraphicSize(Math.floor(initialImageWidth * ratioIncrease));
		albumArtImage.updateHitbox(); // I hate you
		albumArtImage.x = 0;
		albumArtImage.screenCenter(Y);
	}

	public function updateAlbumArt(path:String)
	{
		// remove the sprite and create it again
		remove(albumArtImage);
		albumArtImage = new FlxSprite();
		albumArtImage.loadGraphic(Paths.getImage(path));
		albumArtImage.shader = wavyShader;
		add(albumArtImage);

		fillScreenWithAlbumArt();
	}

	override public function update(elapsed:Float)
	{
		if (SongHandler.instance.currentPlayingStems != null)
		{
			// avoid audio being unsynced by 0.1ms
			if (SongHandler.instance.currentPlayingStems.checkSyncError() > 100)
			{
				resyncStems();
			}
		}
		super.update(elapsed);
	}
	public function resyncStems()
	{
		SongHandler.instance.currentPlayingStems.time = SongHandler.instance.currentPlayingStems.time; // assign all times to itself's time because we have nothing else to choose from, lol
	}

	public function openWeb(url:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [url]);
		#else
		FlxG.openURL(url);
		#end
	}
}
