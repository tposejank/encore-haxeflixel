package encore.states;

import encore.backend.AssetPaths.Paths;
import encore.backend.audio.StemGroup.StemPaths;
import encore.backend.audio.StemGroup;
import encore.backend.shaders.MenuWavy;
import encore.backend.songs.SongHandler;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

/**
 * Home menu state
 */
class HomeMenuState extends GameState
{
	var encoreLogo:FlxSprite;
	var backgroundTop:FlxSprite;
	var line1:FlxSprite;

	var backgroundBottom:FlxSprite;
	var line2:FlxSprite;

	var playText:FlxText;
	var optionsText:FlxText;
	var quitText:FlxText;

	var songPlayButton:FlxSprite;
	var songPlayButtonBG:FlxSprite;

	var songSkipButton:FlxSprite;
	var songSkipButtonBG:FlxSprite;

	var currentSongPlayingTitle:FlxText;
	var currentSongPlayingArtist:FlxText;

	var albumArtImage:FlxSprite;

	var wavyShader:MenuWavy;

	override public function create()
	{
		super.create();

		SongHandler.instance = new SongHandler();

		currentSongPlayingTitle = new FlxText(1120, 48, 0, '');
		currentSongPlayingTitle.setFormat('assets/fonts/Rubik-BoldItalic.ttf', 18, FlxColor.WHITE, RIGHT);

		currentSongPlayingArtist = new FlxText(1120, 72, 0, '');
		currentSongPlayingArtist.setFormat('assets/fonts/Rubik-Italic.ttf', 18, FlxColor.WHITE, RIGHT);

		albumArtImage = new FlxSprite(0, 0);

		wavyShader = new MenuWavy();

		albumArtImage.shader = wavyShader;

		playSongStems();

		add(albumArtImage);

		backgroundTop = new FlxSprite(0, 0).makeGraphic(FlxG.width, 155, 0xFF12121d);
		// add(backgroundTop);

		line1 = new FlxSprite(0, 155 - 3).makeGraphic(FlxG.width, 3, 0xFFFFFFFF);
		add(line1);

		backgroundBottom = new FlxSprite(0, FlxG.height - 125).makeGraphic(FlxG.width, 125, 0xFF12121d);
		// add(backgroundBottom);

		line2 = new FlxSprite(0, backgroundBottom.y).makeGraphic(FlxG.width, 3, 0xFFFFFFFF);
		add(line2);

		encoreLogo = new FlxSprite(80, 25);
		encoreLogo.loadGraphic('assets/images/ui/encore-white.png');
		encoreLogo.scale.set(0.3, 0.3);
		encoreLogo.updateHitbox();
		add(encoreLogo);

		playText = new FlxText(80, 235, 0, 'Play', 50);
		playText.font = 'assets/fonts/RedHatDisplay-Black.ttf';
		add(playText);

		optionsText = new FlxText(80, 305, 0, 'Options', 50);
		optionsText.font = 'assets/fonts/RedHatDisplay-Black.ttf';
		add(optionsText);

		#if sys
		quitText = new FlxText(80, 375, 0, 'Quit', 50);
		quitText.font = 'assets/fonts/RedHatDisplay-Black.ttf';
		add(quitText);
		#end
		songPlayButtonBG = new FlxSprite(1130, 50);
		songPlayButtonBG.makeGraphic(40, 40, 0xFF181827);
		add(songPlayButtonBG);

		songPlayButton = new FlxSprite(1130, 50);
		songPlayButton.loadGraphic('assets/images/ui/ui-buttonicons.png', true, 40, 40);
		songPlayButton.animation.add('1', [0], 0, false); // PLAY (when paused)
		songPlayButton.animation.add('2', [1], 0, false); // PAUSE (when playing)
		songPlayButton.animation.play('2'); // PAUSE
		add(songPlayButton);

		songSkipButtonBG = new FlxSprite(1170, 50);
		songSkipButtonBG.makeGraphic(40, 40, 0xFF181827);
		add(songSkipButtonBG);

		songSkipButton = new FlxSprite(1170, 50);
		songSkipButton.loadGraphic('assets/images/ui/ui-buttonicons.png', true, 40, 40);
		songSkipButton.animation.add('1', [2], 0, false); // SKIP
		songSkipButton.animation.play('1'); // SKIP
		add(songSkipButton);
		add(currentSongPlayingTitle);
		add(currentSongPlayingArtist);
	}

	public function realignTexts()
	{
		currentSongPlayingTitle.x = 1120 - currentSongPlayingTitle.width;
		currentSongPlayingArtist.x = 1120 - currentSongPlayingArtist.width;
	}

	public function playSongStems():SongRegistry
	{
		// Start playing menu music
		var sampleSong:SongRegistry = SongHandler.instance.getAny();
		// change song texts
		currentSongPlayingTitle.text = sampleSong.data.title;
		currentSongPlayingArtist.text = sampleSong.data.artist;
		realignTexts();

		albumArtImage.loadGraphic(Paths.getImage(sampleSong.path + sampleSong.data.art));

		var stemPaths:StemPaths = new StemPaths(sampleSong.data.stems);
		trace('Playing ' + sampleSong.path);
		var stems:StemGroup = new StemGroup(sampleSong.path, stemPaths);
		SongHandler.instance.currentPlayingStems = stems;

		stems.loadAll();
		stems.playAll();
		return sampleSong;
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.mouse.overlaps(playText))
		{
			playText.color = 0xFFFFFFFF;

			if (FlxG.mouse.justPressed)
			{
				trace('SOON');
				FlxG.switchState(new PlayState());
			}
		}
		else
		{
			playText.color = 0xFFaaaaaa;
		}

		if (FlxG.mouse.overlaps(optionsText))
		{
			optionsText.color = 0xFFFFFFFF;

			if (FlxG.mouse.justPressed)
			{
				trace('SOON');
			}
		}
		else
		{
			optionsText.color = 0xFFaaaaaa;
		}

		#if sys
		if (FlxG.mouse.overlaps(quitText))
		{
			quitText.color = 0xFFFFFFFF;
			if (FlxG.mouse.justPressed)
			{
				Application.current.window.close();
			}
		}
		else
		{
			quitText.color = 0xFFaaaaaa;
		}
		#end

		if (FlxG.mouse.overlaps(songPlayButtonBG))
		{
			songPlayButtonBG.makeGraphic(40, 40, 0xFF7F007F);
			if (FlxG.mouse.justPressed)
			{
				trace('CLICK');
			}
		}
		else
		{
			songPlayButtonBG.makeGraphic(40, 40, 0xFF181827);
		}

		if (FlxG.mouse.overlaps(songSkipButtonBG))
		{
			songSkipButtonBG.makeGraphic(40, 40, 0xFF7F007F);
			if (FlxG.mouse.justPressed)
			{
				SongHandler.instance.currentPlayingStems.clear();
				SongHandler.instance.currentPlayingStems.destroy();
				playSongStems();
			}
		}
		else
		{
			songSkipButtonBG.makeGraphic(40, 40, 0xFF181827);
		}

		if (wavyShader != null)
		{
			// trace(wavyShader.time.value.length);
			// wavyShader.time.value[0] += elapsed; // Increment by 0.01 each frame
		}

		super.update(elapsed);
	}
}