package;

import lime.app.Application;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import flixel.FlxGame;
import flixel.FlxG;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
#if !js
import Config.data;
import sys.io.File.getContent;
#end //thank you now shut up visual studio code
/*
typedef ConfigData = {
	var width:Int;
	var height:Int;
	var fullscreen:Bool;
}
*/
class Main extends Sprite
{
	var gameWidth:Int; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool; // Whether to start the game in fullscreen on desktop targets
	
	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}
	public function traceSomethingDependingOnPlatform(something:String){
		#if cpp
		cpp.Lib.println(something);
		#elseif js
		js.Lib.console.log(something);
		#elseif php
		php.Lib.println(something);
		#end
	}
	public function new()
	{
//		var s = getContent("config.json");
//		var config:ConfigData = haxe.Json.parse(s);
//		var gameWidth:Int = config.width; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
//		var gameHeight:Int = config.height; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		framerate = 60;
		#if desktop
		//var s = getContent("config.json");
		//var config:ConfigData = haxe.Json.parse(s);
		gameWidth = data.width; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
		gameHeight = data.height; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		startFullscreen = data.fullscreen;
		#else
		gameWidth = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
		gameHeight = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		startFullscreen = false;
		#end
		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
		
		#if !debug
		initialState = TitleState;
		#end
		GlobalSettings.init();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
		#if debug
		flixel.addons.studio.FlxStudio.create();
		#end
		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
