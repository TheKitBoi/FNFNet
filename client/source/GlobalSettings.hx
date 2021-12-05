package;

class GlobalSettings
{
    public static var curAddress:String;
    public static var songDir:String;

    public static function init(){
        curAddress = Config.data.resourceaddr;
        songDir = "";
    }
}