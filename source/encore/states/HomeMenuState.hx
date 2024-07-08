package encore.states;

import encore.backend.AssetPaths.Paths;
import encore.backend.CrashHandler;
import encore.backend.audio.StemGroup.StemPaths;
import encore.backend.audio.StemGroup;
import encore.backend.shaders.MenuBlur;
import encore.backend.songs.SongHandler;
import encore.ui.UIButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import lime.app.Application;

/**
 * Home menu state
 */
class HomeMenuState extends GameState
{
	var encoreLogo:FlxSprite;
	var backgroundTop:FlxSprite;
	var line1:FlxSprite;
	var playProgressBar:FlxSprite;

	var backgroundBottom:FlxSprite;
	var line2:FlxSprite;

	var splashTextBackground:FlxSprite;
	var splashText:FlxText;

	var playText:FlxText;
	var optionsText:FlxText;
	var quitText:FlxText;

	var songPlayButton:UIButton;
	var songSkipButton:UIButton;
	var githubButton:UIButton;
	var discordButton:UIButton;

	var currentSongPlayingTitle:FlxText;
	var currentSongPlayingArtist:FlxText;

	override public function create()
	{
		super.create();

		SongHandler.instance = new SongHandler();

		currentSongPlayingTitle = new FlxText(1120, 48, 0, '');
		currentSongPlayingTitle.setFormat('assets/fonts/Rubik-BoldItalic.ttf', 18, FlxColor.WHITE, RIGHT);

		currentSongPlayingArtist = new FlxText(1120, 72, 0, '');
		currentSongPlayingArtist.setFormat('assets/fonts/Rubik-Italic.ttf', 18, FlxColor.WHITE, RIGHT);

		playSongStems();

		add(albumArtImage);

		backgroundTop = new FlxSprite(0, 0).makeGraphic(FlxG.width, 155, 0xFF12121d);
		add(backgroundTop);

		line1 = new FlxSprite(0, 155 - 3).makeGraphic(FlxG.width, 3, 0xFFFFFFFF);
		add(line1);

		playProgressBar = new FlxSprite(0, 155 - 6).makeGraphic(FlxG.width, 3, 0xFF66bfff);
		add(playProgressBar);

		backgroundBottom = new FlxSprite(0, FlxG.height - 125).makeGraphic(FlxG.width, 125, 0xFF12121d);
		add(backgroundBottom);

		line2 = new FlxSprite(0, backgroundBottom.y).makeGraphic(FlxG.width, 3, 0xFFFFFFFF);
		add(line2);

		splashText = new FlxText(75, line2.y - 26, 0, 'No splash line here!!! Lmao', 20);
		splashText.setFormat('assets/fonts/JosefinSans-Italic.ttf', 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.NONE, FlxColor.TRANSPARENT);
		var splashLine = Paths.getRandomSplashLine();
		splashText.text = splashLine;

		splashTextBackground = FlxGradient.createGradientFlxSprite(Math.floor(115 + splashText.width), 30, [FlxColor.TRANSPARENT, 0xFF6a1c6f], 1, 180);
		add(splashTextBackground);
		splashTextBackground.y = line2.y - 30;
		add(splashText);

		// trace('Splash line: ${splashLine}');;

		encoreLogo = new FlxSprite(80, 25);
		encoreLogo.loadGraphic('assets/images/ui/encore-white.png');
		encoreLogo.scale.set(0.3, 0.3);
		encoreLogo.updateHitbox();
		encoreLogo.antialiasing = true;
		add(encoreLogo);

		playText = new FlxText(80, 235, 0, 'Play', 50);
		playText.setFormat('assets/fonts/RedHatDisplay-Black.ttf', 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.GRAY);
		add(playText);

		optionsText = new FlxText(80, 305, 0, 'Options', 50);
		optionsText.setFormat('assets/fonts/RedHatDisplay-Black.ttf', 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.GRAY);
		add(optionsText);

		#if sys
		quitText = new FlxText(80, 375, 0, 'Quit', 50);
		quitText.setFormat('assets/fonts/RedHatDisplay-Black.ttf', 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.GRAY);
		add(quitText);
		#end
		songPlayButton = new UIButton(1130, 50, 40, 40, false);
		add(songPlayButton);

		songPlayButton.icon.loadGraphic('assets/images/ui/ui-buttonicons.png', true, 40, 40);
		songPlayButton.icon.animation.add('1', [0], 0, false); // PLAY (when paused)
		songPlayButton.icon.animation.add('2', [1], 0, false); // PAUSE (when playing)
		songPlayButton.icon.animation.play('2'); // PAUSE
		songPlayButton.addIcon();

		songPlayButton.onClick = function()
		{
			SongHandler.instance.currentPlayingStems.paused = SongHandler.instance.currentPlayingStems.playing;
			songPlayButton.icon.animation.play(SongHandler.instance.currentPlayingStems.playing ? '2' : '1');
			resyncStems();
		}

		songSkipButton = new UIButton(1170, 50, 40, 40, false);
		add(songSkipButton);
		songSkipButton.icon.loadGraphic('assets/images/ui/ui-buttonicons.png', true, 40, 40);
		songSkipButton.icon.animation.add('1', [2], 0, false); // SKIP
		songSkipButton.icon.animation.play('1'); // SKIP
		songSkipButton.addIcon();

		songSkipButton.onClick = function()
		{
			SongHandler.instance.currentPlayingStems.clear();
			SongHandler.instance.currentPlayingStems.destroy();
			playSongStems();
			songPlayButton.icon.animation.play(SongHandler.instance.currentPlayingStems.playing ? '2' : '1');
		}

		githubButton = new UIButton(FlxG.width - 60, line2.y - 60, 60, 60, true);
		add(githubButton);
		githubButton.icon.loadGraphic('assets/images/ui/brand-icons.png', true, 56, 56);
		githubButton.icon.animation.add('1', [1], 0, false); // GITHUB ICONS
		githubButton.icon.animation.play('1'); // GITHUB ICONS
		githubButton.addIcon();

		githubButton.onClick = function()
		{
			openWeb('https://www.github.com/Encore-Developers/Encore');
		}

		discordButton = new UIButton(FlxG.width - 120, line2.y - 60, 60, 60, true);
		add(discordButton);
		discordButton.icon.loadGraphic('assets/images/ui/brand-icons.png', true, 56, 56);
		discordButton.icon.animation.add('1', [0], 0, false); // DISCORD ICONS
		discordButton.icon.animation.play('1'); // DISCORD ICONS
		discordButton.addIcon();

		discordButton.onClick = function()
		{
			openWeb('https://discord.gg/GhkgVUAC9v');
		}

		add(currentSongPlayingTitle);
		add(currentSongPlayingArtist);
	}

	public function calculatePlayProgressBar()
	{
		if (SongHandler.instance.currentPlayingStems != null)
		{
			var percentagePlayed:Float = SongHandler.instance.currentPlayingStems.time / SongHandler.instance.currentPlayingStems.duration;

			var theoricalXPos:Float = FlxG.width * percentagePlayed;
			var realXPos:Float = theoricalXPos - playProgressBar.width;

			playProgressBar.x = realXPos;
		}
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

		updateAlbumArt(sampleSong.path + sampleSong.data.art);

		var stemPaths:StemPaths = new StemPaths(sampleSong.data.stems);
		trace('Playing ' + sampleSong.path);
		var stems:StemGroup = new StemGroup(sampleSong.path, stemPaths);
		SongHandler.instance.currentPlayingStems = stems;

		stems.loadAll();
		stems.playAll();
		// reset the on complete
		SongHandler.instance.currentPlayingStems.onComplete = playSongStems;

		return sampleSong;
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.mouse.overlaps(playText))
		{
			playText.color = 0xFFFFFFFF;

			if (FlxG.mouse.justPressed)
			{
				// trace('SOON');
				FlxG.switchState(new SongListState());
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

		calculatePlayProgressBar();

		super.update(elapsed);
	}
}