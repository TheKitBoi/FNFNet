package;

import haxe.io.Bytes;
import openfl.net.FileReference;
import flash.events.DataEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import openfl.net.URLStream as FileStream;
import openfl.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;

class Downloader extends EventDispatcher
{

    private var file:Dynamic;
    public static var fileStream:FileReference;
    private var url:String;
    private var urlStream:URLStream;

    private var waitingForDataToWrite:Bool = false;

    public static function cache(song:String){
        Downloader.fileStream = new FileReference();
        Downloader.fileStream.addEventListener(Event.COMPLETE, (e:Event)->{
            Downloader.fileStream.save(fileStream.data);
        });
        Downloader.fileStream.download(new URLRequest('http://'+Config.data.resourceaddr+'/event/Inst.ogg'));
    }
}