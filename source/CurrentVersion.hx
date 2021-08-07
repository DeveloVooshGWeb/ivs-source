package;

class CurrentVersion
{
	public static var ver:String = "";

	public static function get():String
	{
		return ver;
	}

	public static function init():Void
	{
		ver = Paths.getTextDec(Paths.gwebtxt('dafuniversion'));
	}
}