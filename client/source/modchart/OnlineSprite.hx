package modchart;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Future;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import GlobalSettings.songDir as songname;

class OnlineSprite extends FlxSprite
{
    public var loaded:Bool = false;

    public function new(?X:Float = 0, ?Y:Float = 0, name:String, animated:Bool = false, callback:Void -> Void){
        super(X, Y);
        BitmapData.loadFromFile('http://'+Config.data.resourceaddr+'/songs/$songname/$name.png').then(function(image){
            if(!animated){
                pixels = image;
                loaded = true;
                callback();
            }
            else{
                var xml = new haxe.Http('http://'+Config.data.resourceaddr+'/songs/$songname/$name.xml');
                xml.onData = (data:String)->{frames = FlxAtlasFrames.fromSparrow(image, data); loaded=true; callback();};
                xml.request();
            }
            return Future.withValue(image);
        });
    }
}