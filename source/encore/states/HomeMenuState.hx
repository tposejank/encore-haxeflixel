package encore.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
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

	override public function create()
	{
		super.create();

		backgroundTop = new FlxSprite(0, 0).makeGraphic(FlxG.width, 155, 0xFF12121d);
		add(backgroundTop);

		line1 = new FlxSprite(0, 155 - 3).makeGraphic(FlxG.width, 3, 0xFFFFFFFF);
		add(line1);

		backgroundBottom = new FlxSprite(0, FlxG.height - 125).makeGraphic(FlxG.width, 125, 0xFF12121d);
		add(backgroundBottom);

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
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.mouse.overlaps(playText))
		{
			playText.color = 0xFFFFFFFF;

			if (FlxG.mouse.justPressed)
			{
				trace('SOON');
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

		super.update(elapsed);
	}
}