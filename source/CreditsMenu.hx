package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.addons.transition.FlxTransitionableState;

import Discord.DiscordClient;
#if visualControls
import ui.FlxVirtualPad;
#end

using StringTools;

class CreditsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	
	private var iconArray:Array<CreditIcon> = [];
	
	public static var credits:Array<String> = [
	'Crystal Blitz',
	'GWebDev',
	'disky',
	'elikapika',
	'staromelo',
	'Fpeyro',
	'bee_hanii',
	'Tama',
	'fueg0'
	];

	var mainCam:FlxCamera;
	var higherCam:FlxCamera;
	
	#if visualControls
	var _pad:FlxVirtualPad;
	#end

	override function create()
	{
		#if visualControls
		mainCam = new FlxCamera();
		higherCam = new FlxCamera();
		higherCam.bgColor.alpha = 0;
		
		FlxG.cameras.reset(mainCam);
		FlxG.cameras.add(higherCam);
		
		FlxCamera.defaultCameras = [mainCam];
		
		_pad = new FlxVirtualPad(UP_DOWN, A_B);
		_pad.alpha = 0.65;
		add(_pad);
		_pad.cameras = [higherCam];
		#end
	
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.inst('whale-waltz'));
		}
		
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Inside The Credits Menu...", null);
	
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...credits.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, new EReg('_', 'g').replace(new EReg('0', 'g').replace(credits[i], 'O'), ' '), true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:CreditIcon = new CreditIcon(credits[i]);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		changeSelection();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP:Bool = false;
		var downP:Bool = false;
		var accepted:Bool = false;
		var backed:Bool = false;
		
		#if visualControls
		upP = controls.UP_P || _pad.buttonUp.justPressed;
		downP = controls.DOWN_P || _pad.buttonDown.justPressed;
		accepted = controls.ACCEPT || _pad.buttonA.justPressed;
		backed = controls.BACK || _pad.buttonB.justPressed;
		#if android
		if (FlxG.android.justReleased.BACK)
		{
		backed = true;
		}
		#end
		#else
		upP = controls.UP_P;
		downP = controls.DOWN_P;
		accepted = controls.ACCEPT;
		backed = controls.BACK;
		#end

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		
		if (Highscore.getInput() && FlxG.mouse.wheel != 0)
		{
			changeSelection(FlxG.mouse.wheel * -1);
		}

		if (backed)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			FlxG.switchState(new MediaMenu(credits[curSelected]));
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = credits.length - 1;
		if (curSelected >= credits.length)
			curSelected = 0;

		var bullShit:Int = 0;
		
		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}