package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

import haxe.ValueException;

import haxe.io.BytesInput;

import haxe.Unserializer;
import haxe.Json;

import gwebdev.Crypter;

class Paths
{
	public static var useBak:Bool = #if debugShit true #else false #end;

	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}
	
	static public function exists(file:String)
	{
		return OpenFlAssets.exists(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}
	
	inline static public function getTextDec(path:String):String
	{
		var toRet:String = "";
		try
		{
			var received:BytesInput = Crypter.pathToInput(path);
			toRet = Crypter.crypt(received, received.length, false).toString();
			if (toRet == "")
				throw new ValueException("");
		}
		catch (e:Dynamic)
		{
			try
			{
				toRet = OpenFlAssets.getText(path);
			}
			catch (e:Dynamic) { }
		}
		try
		{
			var unserializer:Unserializer = new Unserializer(toRet);
			var toRet2:String = unserializer.unserialize();
			toRet = Json.stringify(toRet2);
		}
		catch (e:Dynamic) { }
		return toRet;
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}
	
	inline static public function gwebtxt(key:String, ?library:String)
	{
		var daPath:String = 'data/$key.';
		if (useBak)
			if (key == 'dafuniversion')
				daPath += 'vershit';
			else
				daPath += 'json';
		else
			daPath += 'gwebtxt';
		trace(daPath);
		return getPath(daPath, TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}
	
	inline static public function voices2(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices2.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
