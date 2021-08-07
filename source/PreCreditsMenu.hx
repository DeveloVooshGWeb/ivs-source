package;

import haxe.io.Bytes;

import flixel.FlxG;
import flixel.FlxState;

import lime.app.Future;
import lime.app.Promise;

import openfl.utils.Assets;
import openfl.utils.AssetType;
import lime.graphics.Image;
import openfl.display.BitmapData;

import haxe.Json;

class PreCreditsMenu extends FlxState
{
	var finishedSwitches:Int = 0;

	override function create()
	{
		var text:Alphabet = new Alphabet(0, 0, "Adjusting For Credits", true);
		text.screenCenter();
		add(text);
	
		super.create();
		
		init();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	function switchState():Void
	{
		FlxG.switchState(new CreditsMenu());
	}
	
	function switchFinish():Void
	{
		finishedSwitches++;
		if (finishedSwitches >= 2)
		{
			switchState();
		}
	}
	
	function preSwitch():Void
	{
		switch1();
		switch2();
	}
	
	function setImage(png:Image):Void
	{
		CreditIcon.png = png;
		var encoded:Bytes = png.encode(PNG, 100);
		#if (sys && !mobile)
		sys.io.File.saveBytes('assets/images/credits/Spriteshit/sheet.png', encoded);
		#else
		Highscore.setId('sheet.png', encoded);
		#end
	}
	
	function setText(txt:String):Void
	{
		CreditIcon.txt = txt;
		#if (sys && !mobile)
		sys.io.File.saveBytes('assets/images/credits/Spriteshit/sheet.txt', Bytes.ofString(txt));
		#else
		Highscore.setId('sheet.txt', Bytes.ofString(txt));
		#end
	}
	
	function switchFix(isTxt:Bool = false):Void
	{
		if (!isTxt)
		{
			#if sys 
			if (sys.FileSystem.exists('assets/images/credits/Spriteshit/sheet.png'))
				setImage(Image.fromBytes(Requester.readFile('assets/images/credits/Spriteshit/sheet.png')));
			else
			#end
			if (Highscore.existsId('sheet.png'))
				setImage(Image.fromBytes(Highscore.getId('sheet.png')));
			else 
				setImage(Image.fromBitmapData(Assets.getBitmapData(Paths.image('credits/Spriteshit/sheet'))));
		}
		else
		{
			#if sys 
			if (sys.FileSystem.exists('assets/images/credits/Spriteshit/sheet.txt'))
				setText(Requester.readFile('assets/images/credits/Spriteshit/sheet.txt').toString());
			else
			#end
			if (Highscore.existsId('sheet.txt'))
				setText(Highscore.getId('sheet.txt').toString());
			else
				setText(Assets.getText(Paths.file('images/credits/Spriteshit/sheet.txt')));
		}
		switchFinish();
	}
	
	function switch2():Void
	{
		Requester.sendRequest('iconAtlas', 'https://raw.githubusercontent.com/GrowtopiaFli/ivs-source/main/CreditSpriteShit/sheet.txt', true).onComplete
		(
			function(ret:Bool)
			{
				if (ret || (!ret && Requester.requests.exists('iconAtlas')))
				{
					var daBytes:Bytes = Requester.requests.get('iconAtlas');
					setText(daBytes.toString());
					switchFinish();
				}
				else
					switchFix(true);
			}
		).onError
		(
			function(e:Dynamic)
			{
				switchFix();
			}
		);
	}
	
	function switch1():Void
	{
		Requester.sendRequest('iconData', 'https://raw.githubusercontent.com/GrowtopiaFli/ivs-source/main/CreditSpriteShit/sheet.png', true).onComplete
		(
			function(ret:Bool)
			{
				if (ret || (!ret && Requester.requests.exists('iconData')))
				{
					var daBytes:Bytes = Requester.requests.get('iconData');
					setImage(Image.fromBytes(daBytes));
					switchFinish();
				}
				else
					switchFix(false);
			}
		).onError
		(
			function(e:Dynamic)
			{
				switchFix();
			}
		);
	}
	
	function doShit(json:String):Void
	{
		var parsed:Dynamic = Json.parse(json);
		if (Reflect.hasField(parsed, 'array') && Std.is(parsed.array, Array))
		{
			CreditsMenu.credits = parsed.array;
			#if (sys && !mobile)
			sys.io.File.saveBytes('assets/data/credits.data', Bytes.ofString(json));
			#else
			Highscore.setId('credits', Bytes.ofString(json));
			#end
			preSwitch();
		}
		else
			preSwitch();
	}
	
	function repeated(daStr:String):Void
	{
		if (Requester.isJson(daStr))
			doShit(daStr);
		else
			preSwitch();
	}

	function init():Void
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
						preSwitch();
				}
			}
		).onError
		(
			function(e:Dynamic)
			{
				preSwitch();
			}
		);
	}
}