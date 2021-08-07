package gwebdev;

import openfl.utils.Assets;
import openfl.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.BytesInput;
#if sys
import sys.FileSystem;
import sys.io.File;
import sys.FileStat;
import sys.io.FileInput;
#end
import openfl.utils.ByteArray;
import haxe.io.Path;

import haxe.crypto.Base64;

using StringTools;

class Crypter
{
	public static var keys:Array<Int> = [
	];
	
	public static function setKeys(keysArray:Array<Int>):Void
	{
		keys = keysArray;
	}
	
	public static function bytesToInput(inpBytes:Bytes):BytesInput
	{
		return new BytesInput(inpBytes);
	}
	
	#if sys
	public static function sysToInput(path:String):FileInput
	{
		return File.read(path, true);
	}
	#end
	
	public static function pathToInput(path:String, isBytes:Bool = false):BytesInput
	{
		if (isBytes)
			return new BytesInput(Assets.getBytes(path));
		else
			return new BytesInput(Bytes.ofString(Assets.getText(path)));
	}
	
	public static function crypt(inpData:Input, dataLength:Int, encryption:Bool = false):Bytes
	{
		var toRet:Bytes = null;
		if (inpData != null)
		{
			var byteArray:ByteArray = new ByteArray();
			for (i in 0...dataLength)
			{
				byteArray.writeByte(inpData.readByte());
			}
			if (encryption)
			{
				byteArray.compress(ZLIB);
				var bInput:BytesInput = new BytesInput(byteArray);
				dataLength = bInput.length;
				inpData = bInput;
				byteArray = new ByteArray();
			}
			else
			{
				byteArray = ByteArray.fromBytes(Base64.decode(byteArray.toString()));
				var bInput:BytesInput = new BytesInput(byteArray);
				dataLength = bInput.length;
				inpData = bInput;
				byteArray = new ByteArray();
			}
			for (i in 0...dataLength)
			{
				var daByte:Int = inpData.readByte();
				if (encryption)
				{
					for (i in 0...keys.length)
						daByte = daByte^keys[keys.length - (i + 1)];
					var keySum:Int = 0;
					for (i in 0...keys.length)
						if (i <= 1)
							keySum += keys[i];
					daByte = ~daByte + keySum;
				}
				else
				{
					var keySum:Int = 0;
					for (i in 0...keys.length)
						if (i <= 1)
							keySum += keys[i];
					daByte = ~daByte + keySum;
					for (i in 0...keys.length)
						daByte = daByte^keys[i];
				}
				byteArray.writeByte(daByte);
			}
			if (!encryption)
				byteArray.uncompress(ZLIB);
			else
				byteArray = ByteArray.fromBytes(Bytes.ofString(Base64.encode(byteArray)));
			toRet = byteArray;
		}
		return toRet;
	}
}