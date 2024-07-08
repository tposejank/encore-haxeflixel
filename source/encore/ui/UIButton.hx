package encore.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

class UIButton extends FlxTypedGroup<FlxSprite>
{
	public var backgroundBorder:FlxSprite;
	public var background:FlxSprite;
	public var icon:FlxSprite;

	public var borderColor:FlxColor = FlxColor.WHITE;
	public var innerStaticColor:FlxColor = 0xFF181827;
	public var innerHoverColor:FlxColor = 0xFF7F007F;
	public var innerHoldColor:FlxColor = 0xFFb200b2;

	public var width:Int = 0;
	public var height:Int = 0;
	public var yPos:Float = 0;
	public var xPos:Float = 0;
	public var padding:Int = 0;

	public function new(x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, border:Bool = true)
	{
		super();

		var innerX = 2;
		if (!border)
			innerX = 0;

		backgroundBorder = new FlxSprite(x, y);
		backgroundBorder.makeGraphic(width, height, borderColor);
		backgroundBorder.alpha = border ? 1 : 0;

		background = new FlxSprite(x + innerX, y + innerX);
		background.makeGraphic(width - innerX, height - innerX, innerStaticColor);

		add(backgroundBorder);
		add(background);

		this.width = width;
		this.height = height;
		this.padding = innerX;
		// xPos = x;
		// yPos = y;

		icon = new FlxSprite(x + innerX, y + innerX);
	}

	public dynamic function onClick():Void {}

	public function addIcon()
	{
		add(icon);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(backgroundBorder))
		{
			background.makeGraphic(width - padding, height - padding, innerHoverColor);

			if (FlxG.mouse.pressed)
			{
				background.makeGraphic(width - padding, height - padding, innerHoldColor);
			}

			if (FlxG.mouse.justReleased)
			{
				onClick();
			}
		}
		else
		{
			background.makeGraphic(width - padding, height - padding, innerStaticColor);
		}
	}
}