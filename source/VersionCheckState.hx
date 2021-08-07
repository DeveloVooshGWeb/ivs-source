package;

import flixel.FlxG;
import flixel.FlxState;

import haxe.io.Bytes;

class VersionCheckState extends FlxState
{
	override function create()
	{
		var text:Alphabet = new Alphabet(0, 0, "Checking Version", true);
		text.screenCenter();
		add(text);
		
		super.create();
		
		init();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	function init():Void
	{
		Requester.sendRequest('github_version', "https://raw.githubusercontent.com/GrowtopiaFli/ivs-source/main/current.version", false).onComplete
		(
			function(ret:Bool)
			{
				if (ret || (!ret && Requester.requests.exists('github_version')))
					compare(Requester.requests.get('github_version').toString());
				else
				{
					#if sys
					if (sys.FileSystem.exists('assets/latest_ver.txt'))
						compare(Requester.readFile('assets/latest_ver.txt').toString());
					else
					#end
					if (Highscore.existsId('latest_ver'))
						compare(Highscore.getId('latest_ver').toString());
					else
						menuSwitch();
				}
			}
		).onError
		(
			function(e:Dynamic)
			{
				menuSwitch();
			}
		);
	}
	
	function compare(data:String):Void
	{
		#if (sys && !mobile)
		sys.io.File.saveBytes('assets/latest_ver.txt', Bytes.ofString(data));
		#else
		Highscore.setId('latest_ver', Bytes.ofString(data));
		#end
		OutdatedSubState.daVer = data;
		UpdatedSubState.daVer = data;
		if (VersionParser.parse(CurrentVersion.get()) < VersionParser.parse(data) && !OutdatedSubState.leftState)
			FlxG.switchState(new OutdatedSubState());
		else if (VersionParser.parse(CurrentVersion.get()) >  VersionParser.parse(data) && !UpdatedSubState.leftState)
			FlxG.switchState(new UpdatedSubState());
		else
			menuSwitch();
	}
	
	function menuSwitch():Void
	{
		FlxG.switchState(new MainMenuState());
	}
}