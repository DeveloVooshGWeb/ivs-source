package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

import haxe.io.Bytes;
import haxe.Json;

class ThankYouState extends FlxState
{
	var teamTxt:String = "Team:
	Crystal Blitz - Creator/Charter
	GWebDev - Mac Compiler/Coder (Who Literally Coded Everything)
	disky - Coder
	elikapika - Artist
	staromelo - BG Artist
	Fpeyro - Composer
	bee_hanii - Cutscenes
	Tama - Icons
	Sai - Bao's Vocals
	Somniatica - Artemis' Vocals
	fueg0 - Mac Builder\n";

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	function doShit(daStr:String):Void
	{
		var arr:Array<String> = [];
		var parsed:Dynamic = Json.parse(daStr);
		if (Reflect.hasField(parsed, 'people'))
		{
			var people:Dynamic = Reflect.getProperty(parsed, 'people');
			for (person in Reflect.fields(people))
				arr.push(person + ' - ' + Reflect.getProperty(people, person));
			arr.push("");
			teamTxt = arr.join("\n");
			#if (sys && !mobile)
			sys.io.File.saveBytes('assets/data/credits.data', Bytes.ofString(daStr));
			#else
			Highscore.setId('credits', Bytes.ofString(daStr));
			#end
		}
	}

	function repeated(daStr:String):Void
	{
		if (Requester.isJson(daStr))
		{
			doShit(daStr);
		}
		setup();
	}

	override function create()
	{
		Requester.sendRequest('team_data', 'https://raw.githubusercontent.com/GrowtopiaFli/ivs-source/main/credits.data', false).onComplete
		(
			function(ret:Bool)
			{
				if (ret || (!ret && Requester.requests.exists('team_data')))
				{
					var received:String = Requester.requests.get('team_data').toString();
					repeated(received);
				}
				else
				{
					#if sys
					if (sys.FileSystem.exists('assets/data/credits.data') && !sys.FileSystem.isDirectory('assets/data/credits.data'))
					{
						var fData:String = Requester.readFile('assets/data/credits.data').toString();
						repeated(fData);
					}
					else
					#end
					if (Highscore.existsId('credits'))
						repeated(Highscore.getId('credits').toString());
					else
						setup();
				}
			}
		).onError
		(
			function(e:Dynamic)
			{
				setup();
			}
		);
		
		super.create();
	}
	
	function setup():Void
	{
		var txt:String = "Thank you for playing the demo\n
		Follow @blitz_crystal for more Indie VTuber Showdown updates!\n";

		var thankyou:FlxText = new FlxText(0, 0, 0, txt, 25);
		thankyou.setFormat(Paths.font('animeace2_reg.ttf'), 25);
		thankyou.screenCenter(X);
		add(thankyou);
		
		var team:FlxText = new FlxText(0, 0, 0, teamTxt, 14);
		team.setFormat(Paths.font('animeace2_reg.ttf'), 14);
		team.y = FlxG.height - team.height;
		add(team);
		
		var pressEsc:FlxText = new FlxText(0, 0, 0, "Press ESC Or Backspace To Go Back...", 32);
		pressEsc.x = FlxG.width - pressEsc.width;
		add(pressEsc);
		
		thankyou.y = pressEsc.height;
		
		var bao:Character = new Character(0, 0, "bao");
		var baoScale:Float = 0.7;
		bao.scale.set(baoScale, baoScale);
		bao.updateHitbox();
		bao.x = FlxG.width - bao.width;
		bao.y = FlxG.height - bao.height;
		add(bao);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (controls.BACK)
		{
			FlxG.switchState(new StoryMenuState(true));
		}
	}
}