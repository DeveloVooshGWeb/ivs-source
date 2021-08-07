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

import haxe.Json;
import openfl.utils.Assets;

import Discord.DiscordClient;
#if visualControls
import ui.FlxVirtualPad;
#end

import haxe.io.Bytes;

using StringTools;

class MediaMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	
	var medias:Array<String> = [];
	var mediaLinks:Array<String> = [];
	
	public var person:String;
	
	var mainCam:FlxCamera;
	var higherCam:FlxCamera;
	
	#if visualControls
	var _pad:FlxVirtualPad;
	#end
	
	public function new(person:String)
	{
		super();
		this.person = person;
	}

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
		DiscordClient.changePresence("Inside The Media Menu Of" + person + "...", null);
	
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);
		
		var personText:FlxText = new FlxText(0, 0, FlxG.width, person, 32);
		personText.setFormat('Nokia Cellphone FC Small', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		personText.screenCenter(X);
		add(personText);
		
		var smText:FlxText = new FlxText(0, 0, FlxG.width, "SOCIAL MEDIAS", 32);
		smText.setFormat('Nokia Cellphone FC Small', 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		smText.screenCenter(X);
		smText.y = personText.y + personText.height;
		add(smText);
		
		Requester.sendRequest('team_media', 'https://raw.githubusercontent.com/GrowtopiaFli/ivs-source/main/characters.media', false).onComplete
		(
			function(ret:Bool)
			{
				if (ret || (!ret && Requester.requests.exists('team_media')))
				{
					var ret:String = Requester.requests.get('team_media').toString();
					if (Requester.isJson(ret))
						fallback2(Json.parse(ret));
					else
						fallback();
				}
				else
					fallback();
			}
		).onError
		(
			function(e:Dynamic)
			{
				fallback();
			}
		);

		super.create();
	}
	
	function fallback():Void
	{
		#if (sys && !mobile)
		if (sys.FileSystem.exists('assets/data/characters.media') && !sys.FileSystem.isDirectory('assets/data/characters.media'))
		{
			var fBytes:Bytes = Requester.readFile('assets/data/characters.media');
			fallbackPre2(fBytes.toString());
		}
		else
		#end
		if (Highscore.existsId('characters.media'))
			fallbackPre2(Highscore.getId('characters.media').toString());
		else
			fallbackPre2('RANDOM');
	}
	
	function fallback3():Void
	{
		fallback2(Json.parse(Assets.getText(Paths.file('data/characters.media'))));
	}
	
	function fallbackPre2(daStr:String):Void
	{
		if (Requester.isJson(daStr))
			fallback2(Json.parse(daStr));
		else
			fallback3();
	}
	
	function fallback2(parsed:Dynamic):Void
	{
		if (Reflect.hasField(parsed, person))
		{
			#if (sys && !mobile)
			sys.io.File.saveBytes('assets/data/characters.media', Bytes.ofString(Json.stringify(parsed)));
			#else
			Highscore.setId('characters.media', Bytes.ofString(Json.stringify(parsed)));
			#end
			var parsed2:Dynamic = Reflect.getProperty(parsed, person);
			for (media in Reflect.fields(parsed2))
			{
				medias.push(media);
				mediaLinks.push(Reflect.getProperty(parsed2, media));
			}
		}
		doCrap();
	}
	
	function doCrap():Void
	{
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...medias.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, medias[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

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
			FlxG.switchState(new CreditsMenu());
		}

		if (accepted && mediaLinks.length > 0)
		{
			#if linux
			Sys.command('/usr/bin/xdg-open', [mediaLinks[curSelected], "&"]);
			#else
			FlxG.openURL(mediaLinks[curSelected]);
			#end
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = medias.length - 1;
		if (curSelected >= medias.length)
			curSelected = 0;

		var bullShit:Int = 0;

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