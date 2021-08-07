package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

import haxe.Http;
import haxe.io.Bytes;

#if visualControls
import ui.FlxVirtualPad;
#end

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var daVer:String = "I DONT KNOW";
	
	#if visualControls
	public var _pad:FlxVirtualPad;
	#end

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var ver = "v" + Application.current.meta.get('version');
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"So\n" +
			"Your Version Of IVS Is Outdated...\n" +
			"You Have Version " + CurrentVersion.get() + "\n" +
			"The Latest Version Out There Is " + daVer + "\n" +
			"What Are You Waiting For...\n\n" +
			"PRESS ENTER If You Want To Go To The Gamebanana Page!\n",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
		
		#if visualControls
		_pad = new FlxVirtualPad(NONE, A);
		_pad.alpha = 0.75;
		add(_pad);
		#end
	}

	override function update(elapsed:Float)
	{
		var accepted:Bool = false;
		#if visualControls
		accepted = controls.ACCEPT || _pad.buttonA.justPressed;
		#else
		accepted = controls.ACCEPT;
		#end
	
		if (accepted)
		{
			Requester.sendRequest('gamebanana_link', "https://raw.githubusercontent.com/GrowtopiaFli/ivs-source/main/current.gamebanana", false).onComplete
			(
				function(ret:Bool)
				{
					if (ret || (!ret && Requester.requests.exists('gamebanana_link')))
						openUrl(Requester.requests.get('gamebanana_link').toString());
					#if sys
					else if (sys.FileSystem.exists('assets/gb_link.txt') && !sys.FileSystem.isDirectory('assets/gb_link.txt'))
							openUrl(Requester.readFile('assets/gb_link.txt').toString());
					#end
					else if (Highscore.existsId('gb_link'))
						openUrl(Highscore.getId('gb_link').toString());
				}
			);
		}
		/*if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}*/
		super.update(elapsed);
	}
	
	function openUrl(url:String):Void
	{
		#if (sys && !mobile)
		sys.io.File.saveBytes('assets/gb_link.txt', Bytes.ofString(url));
		#else
		Highscore.setId('gb_link', Bytes.ofString(url));
		#end

		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}
}
