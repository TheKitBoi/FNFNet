package;
import flixel.FlxG;
import haxe.Json;
#if desktop
import sys.io.File.getContent;
#end
typedef ConfigData = {
    var width:Int;
    var height:Int;
    var fullscreen:Bool;
    var addr:String;
    var resourceaddr:String;
    var port:Int;
}
/**
 *Use the .data method to grab config data.
 
 @param width window width

 @param height window height

 @param fullscreen if fullscreen is enabled

 @param addr address for FNFNet
 
 @param port port for FNFNet
 */
class Config {
    #if desktop
    public static var s = getContent("config.json"); //#else "{width: 1280, height: 720, fullscreen: false, addr: 'net.fnf.general-infinity.tech', port: '9000'}"; #end
    public static var data:ConfigData = haxe.Json.parse(s);
    #else
    public static var s:String = '{
        "width": 1280,
        "height": 720,
        "addr": "127.0.0.1",
        "resourceaddr": "127.0.0.1",
        "port": 2567
    }';
    
    public static var data:ConfigData = haxe.Json.parse(s);
    #end
    public static function logout(){
        FlxG.save.data.loggedin = false;
        FlxG.save.data.username = null;
        FlxG.save.data.password = null;
    }
    public static function initsave(reset:Bool = false){
        if(!FlxG.save.data.played || reset){
            FlxG.save.data.played = true;
            FlxG.save.data.loadass = true;
            FlxG.save.data.framerate = 60;
            FlxG.save.data.pauseonunfocus = true;
            FlxG.save.data.fullscreen = false;
            FlxG.save.data.pgbar = false;
            FlxG.save.data.instres = false;
            FlxG.save.data.instvolume = 100;
            FlxG.save.data.vocalsvolume = 100;
            FlxG.save.data.loggedin = false;
            FlxG.save.data.downscroll = false;
            FlxG.save.data.kadeinput = true;
            FlxG.save.data.midscroll = false;
            FlxG.save.flush();
        }
        else{
            (FlxG.save.data.loadass == null) ? FlxG.save.data.loadass=true:FlxG.save.data.loadass == FlxG.save.data.loadass;
            if(FlxG.save.data.loggedin == null) FlxG.save.data.loggedin = false;
            if(FlxG.save.data.midscroll == null) FlxG.save.data.midscroll = false;
            if(FlxG.save.data.downscroll == null) FlxG.save.data.downscroll = false;
            FlxG.autoPause = FlxG.save.data.pauseonunfocus;
            FlxG.drawFramerate = FlxG.updateFramerate = FlxG.save.data.framerate;
        }
    }
}