package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.FlxSprite;

import lime.graphics.Image;
import openfl.display.BitmapData;

class CreditIcon extends FlxSprite
{
	public static var png:Image;
	public static var txt:String;

	public var sprTracker:FlxSprite;

	public function new(char:String = 'Crystal Blitz', isPlayer:Bool = false)
	{
		super();
		
		frames = FlxAtlasFrames.fromSpriteSheetPacker(BitmapData.fromImage(CreditIcon.png), CreditIcon.txt);

		for (person in CreditsMenu.credits)
		{
			animation.addByPrefix(person, person + " Tile", 0, false, isPlayer);
		}
		
		setGraphicSize(150, 150);
		updateHitbox();

		antialiasing = true;
		animation.play(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
