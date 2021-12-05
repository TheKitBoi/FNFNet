package test;

import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.graphics.frames.FlxAtlasFrames;
import sys.io.File;
import flixel.ui.FlxButton;
import lime.utils.Assets;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import openfl.display.BitmapData;
import haxe.Json;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.app.Future;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.math.FlxPoint;

class TestState extends MusicBeatState
{
    public static var songname = "zavodila";
	var zoomc:EzText;
    private var camGame:FlxCamera;
	public static var camFollow:FlxObject;
    private var camHUD:FlxCamera;
    public static var camPos:FlxPoint;
	public static var campaignScore:Int = 0;
	private var dad:test.CharacterTest;
	private var gf:test.CharacterTest;
	public var boyfriend:BFTest;

	var defaultCamZoom:Float = 1.05;
    
    override function create(){
		FlxG.mouse.visible = true;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		var resetstate = new FlxButton(1183, 16, "Reload", function(){
			FlxG.resetState();
		});
		resetstate.cameras = [camHUD];
		add(resetstate);
		camFollow = new FlxObject(400, 130, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON);
        var cstage = new FlxTypedGroup<FlxSprite>();
		add(cstage);
		var stages = File.getContent("./test/stage.json");
		FlxG.camera.focusOn(camFollow.getPosition());
		gf = new test.CharacterTest(400, 130, "gf");
		gf.scrollFactor.set(0.95, 0.95);
		dad = new test.CharacterTest(100, 100, "dad", false);

		boyfriend = new BFTest(770, 450, "bf");

		var assets = Json.parse(stages);
			var stageassets:Array<Dynamic> = assets.assets; // THIS IS TO TRICK THE COMPILER INTO THINKING THIS IS AN DYNAMIC ARRAY, DO NOT REMOVE! 
			for(i in 0...assets.assets.length){
				var assetdecide = assets.version>=2?assets.assets[i].name:assets.assets[i][0];
				BitmapData.loadFromFile("./test/"+assetdecide+".png").then(function(image){
					trace("gaming");
					if(assets.version >= 2){
						var stageasset:FlxSprite = new FlxSprite(assets.assets[i].x, assets.assets[i].y);
						stageasset.pixels = image;
						stageasset.antialiasing = assets.antialiasing;
						stageasset.scrollFactor.set(assets.assets[i].scrollX, assets.assets[i].scrollY);
						stageasset.setGraphicSize(assets.assets[i].width, assets.assets[i].height);
						stageasset.updateHitbox();
						if(assets.assets[i].animated){
							stageasset.frames = FlxAtlasFrames.fromSparrow(image, File.getContent("./test/"+assets.assets[i].name+".xml"));
							for(anim in 0...assets.assets[i].animations.length){
								stageasset.animation.addByPrefix(assets.assets[i].animations[anim], assets.assets[i].animations[anim], 24);
							}
							stageasset.animation.play(assets.assets[i].animations[0]);
						}
						cstage.add(stageasset);
					}
					else
					{
						var stageasset:FlxSprite = new FlxSprite(assets.assets[i][1], assets.assets[i][2]);
						stageasset.pixels = image;
						stageasset.antialiasing = true;
						stageasset.scrollFactor.set(assets.assets[i][3], assets.assets[i][4]);
						stageasset.setGraphicSize(assets.assets[i][5], assets.assets[i][6]);
						stageasset.updateHitbox();
						cstage.add(stageasset);
					}
					/*if(assets.assets[i][7]) {
						stageasset.animation.addByPrefix('idle', assets.assets[i][8], 24, true);
						stageasset.animation.play('idle');
					}*/
					return Future.withValue(image);
				});
			}

			dad.x = assets.characters.dad.x;
			gf.x = assets.characters.gf.x;
			boyfriend.x = assets.characters.bf.x;

			dad.y = assets.characters.dad.y;
			gf.y = assets.characters.gf.y;
			boyfriend.y = assets.characters.bf.y;
			defaultCamZoom = assets.options.zoom;

        add(gf);
        add(dad);
        add(boyfriend);
		
		zoomc = new EzText(16,16,"Zoom: "+defaultCamZoom, 24, 1);
		zoomc.cameras = [camHUD];
		add(zoomc);
		var shifty = new EzText(16,48,"Hold Shift to modify scroll speed.", 24, 1);
		shifty.cameras = [camHUD];
		add(shifty);
		
		btfo = new FlxShapeCircle(boyfriend.getMidpoint().x - 100 + boyfriend.camPos.x,boyfriend.getMidpoint().y - 100 + boyfriend.camPos.y, 3, {
			thickness: 20,
			color: FlxColor.BLUE
		},
		FlxColor.RED);
		add(btfo);
	
		btfo2 = new FlxShapeCircle(dad.getMidpoint().x + 150 + dad.camPos.x, dad.getMidpoint().y - 100 + dad.camPos.y, 3, {
			thickness: 20,
			color: FlxColor.RED
		},
		FlxColor.RED);
		add(btfo2);
        super.create();
    }
	var btfo:FlxShapeCircle;
	var btfo2:FlxShapeCircle;
    override function update(elapsed:Float){
		//gf.dance();
		btfo.x = boyfriend.getMidpoint().x - 100 + boyfriend.camPos.x;
		btfo.y = boyfriend.getMidpoint().y - 100 + boyfriend.camPos.y;

		btfo2.x = dad.getMidpoint().x + 150 + dad.camPos.x;
		btfo2.y = dad.getMidpoint().y - 100 + dad.camPos.y;
		
        if(FlxG.mouse.wheel != 0){
            if(FlxG.mouse.wheel == 1){
                defaultCamZoom += FlxG.keys.pressed.SHIFT?0.1:0.01;
            }
            if(FlxG.mouse.wheel == -1 && defaultCamZoom > 0.01){
                defaultCamZoom -= FlxG.keys.pressed.SHIFT?0.1:0.01;
            }
        }
        if(defaultCamZoom <= 0) defaultCamZoom = 0.01;
		zoomc.text = "Zoom: "+defaultCamZoom;
        if(FlxG.keys.justPressed.W) dad.playAnim("singUP");
        if(FlxG.keys.justPressed.A) dad.playAnim("singLEFT");
        if(FlxG.keys.justPressed.S) dad.playAnim("singDOWN");
        if(FlxG.keys.justPressed.D) dad.playAnim("singRIGHT");

		if(FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new OptionsMenu());

		if(FlxG.keys.pressed.SPACE) dad.dance();
		if(FlxG.keys.justPressed.R) {
			gf.dance();
		}
        if(FlxG.keys.pressed.UP) camFollow.y -=  FlxG.keys.pressed.SHIFT?5:1;
        if(FlxG.keys.pressed.DOWN) camFollow.y +=  FlxG.keys.pressed.SHIFT?5:1;
        if(FlxG.keys.pressed.LEFT) camFollow.x -=  FlxG.keys.pressed.SHIFT?5:1;
        if(FlxG.keys.pressed.RIGHT) camFollow.x +=  FlxG.keys.pressed.SHIFT?5:1;

		if(FlxG.keys.pressed.I) boyfriend.playAnim("singUP");
        if(FlxG.keys.pressed.K) boyfriend.playAnim("singDOWN");
        if(FlxG.keys.pressed.J)	boyfriend.playAnim("singLEFT");
        if(FlxG.keys.pressed.L) boyfriend.playAnim("singRIGHT");
        FlxG.camera.zoom = defaultCamZoom;
        super.update(elapsed);
    }
}