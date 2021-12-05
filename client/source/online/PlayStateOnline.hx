package online;

import lime.app.Future;
import openfl.display.BitmapData;
import flixel.util.typeLimit.OneOfTwo;
import openfl.media.Sound;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import haxe.Json;
import PauseSubState.pracMode;
import CoolUtil.dominantColor;
import Controls.KeyboardScheme;
import io.colyseus.Client;
import io.colyseus.Room;
import online.ConnectingState.options;
using StringTools;

typedef DadCharacter = OneOfTwo<online.CharacterOnline, Character>;

class PlayStateOnline extends MusicBeatState
{
    var coly:Client;
	public static var modinst:Sound;
	public static var modvoices:Sound;
	public static var rooms:Room<Stuff>;
	public static var gimmick:Bool = false;
	public static var otherfinished:Bool = false;
	public static var connected:Bool = false;
	public static var missedNotes:Int;
	public static var downscroll:Bool = false;
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var code:String;
	var halloweenLevel:Bool = false;
	private var vocals:FlxSound;
	public static var startedMatch:Bool = false;
	private var i:Int;
	private var dad:Dynamic;
	private var gf:Dynamic;
	public var boyfriend:BFOnline;
	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var dodging:Bool;
	private var strumLine:FlxSprite;
	public static var assing:Bool = false;

	public static var p1scoretext:FlxText;
	public static var p2scoretext:FlxText;

	var parser = new hscript.Parser();
	var interp = new hscript.Interp();

	public static var onlinemodetext:FlxText;
	public var dadanim:Bool = true;
	private var curSection:Int = 0;
	public static var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;
	public static var currentBeat:Int;
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";
	#if desktop
	private var fs:sys.io.File;
	#end
	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var progressBG:FlxSprite;
	private var healthBar:FlxBar;
	public static var leftText:FlxText;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public static var p1score:Int = 0;
	public static var playedgame:Bool = false;
	public static var p2score:Int = 0;
	public static var roomcode:FlxText;

	public static var iconP1:HealthIcon;
	public static var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var altprefix:String = "";
	public var progress:Float;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;


	public static var userleft:FlxText;
	var bgGirls:BackgroundGirls;
	var songtext:FlxText;
	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var missTxt:FlxText;
	var noteDiff:Float;
	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;
	public static var holymoly:Int = FlxG.random.int(0, 600);
	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	var cstage:FlxTypedGroup<FlxSprite>;
	var p1s:EzText;
	var p2s:EzText;
	#end
	var loadedstrums:Bool = false;
	public var midscroll:Bool = false;

	override public function create()
	{
		if(options.actualVsMode){
			if(ConnectingState.conmode == "host") options.vsMode = !true;
			else options.vsMode = !false;
		}else options.vsMode = false;
		rooms.onMessage('hitnote', function(message){
			if(!options.actualVsMode || !loadedstrums) return;
			/*if(message.player == 1){
				switch(message.strum){
					case 0:
						ConnectingState.p1keys.left = !ConnectingState.p1keys.left;
						if(options.vsMode)boyfriend.playAnim("singLEFT", true);
					case 3:
						ConnectingState.p1keys.right = !ConnectingState.p1keys.right;
						if(options.vsMode)boyfriend.playAnim("singRIGHT", true);
					case 2:
						ConnectingState.p1keys.up = !ConnectingState.p1keys.up;
						if(options.vsMode)boyfriend.playAnim("singUP", true);
					case 1:
						ConnectingState.p1keys.down = !ConnectingState.p1keys.down;
						if(options.vsMode)boyfriend.playAnim("singDOWN", true);
				}
			}
			if(message.player == 2){
				switch(message.strum){
					case 0:
						ConnectingState.p2keys.left = !ConnectingState.p2keys.left;
						dad.playAnim("singLEFT" + altprefix, true);
					case 3:
						ConnectingState.p2keys.right = !ConnectingState.p2keys.right;
						dad.playAnim("singRIGHT" + altprefix, true);
					case 2:
						ConnectingState.p2keys.up = !ConnectingState.p2keys.up;
						dad.playAnim("singUP" + altprefix, true);
					case 1:
						ConnectingState.p2keys.down = !ConnectingState.p2keys.down;
						dad.playAnim("singDOWN" + altprefix, true);
				}
			}*/ //disabled for now lmao
			if(options.vsMode){
				if(message.player == 1){
					if(message.held)enemyStrums.members[message.strum].animation.play("pressed");
					else enemyStrums.members[message.strum].animation.play("static");
				}
			}
			else {
				if(message.player == 2){
					if(message.held)enemyStrums.members[message.strum].animation.play("pressed");
					else enemyStrums.members[message.strum].animation.play("static");
				}
			}
			dadanim = message.held;
		});
		p1s = new EzText(0,0,""+2, 24, 1); 
		p2s = new EzText(0,0,""+2, 24, 1);
		p1score = 0;
		p2score = 0;
		FlxG.autoPause = false;
		downscroll = FlxG.save.data.downscroll;
		midscroll = FlxG.save.data.midscroll;

		switch(FlxG.save.data.ks){
			case null:
				
			case "WASD":
				controls.setKeyboardScheme(KeyboardScheme.Solo);
			case "DFJK":
				controls.setKeyboardScheme(KeyboardScheme.Custom);
		}

		var isDebug:Bool = false;
		missedNotes = 0;
		#if debug
		isDebug = true;
		#end
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
		var bg:FlxSprite;
		var stageFront:FlxSprite;
		var stageCurtains:FlxSprite;
		if (SONG.song.toLowerCase() == 'spookeez' || SONG.song.toLowerCase() == 'monster' || SONG.song.toLowerCase() == 'south')
		{
			curStage = "spooky";
			halloweenLevel = true;

			var hallowTex = Paths.getSparrowAtlas('halloween_bg');

			halloweenBG = new FlxSprite(-200, -100);
			halloweenBG.frames = hallowTex;
			halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
			halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
			halloweenBG.animation.play('idle');
			halloweenBG.antialiasing = true;
			add(halloweenBG);

			isHalloween = true;
		}
		else if (SONG.song.toLowerCase() == 'pico' || SONG.song.toLowerCase() == 'blammed' || SONG.song.toLowerCase() == 'philly')
		{
			curStage = 'philly';

			var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
			bg.scrollFactor.set(0.1, 0.1);
			add(bg);

			var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
			city.scrollFactor.set(0.3, 0.3);
			city.setGraphicSize(Std.int(city.width * 0.85));
			city.updateHitbox();
			add(city);

			phillyCityLights = new FlxTypedGroup<FlxSprite>();
			add(phillyCityLights);

			for (i in 0...5)
			{
				var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
				light.scrollFactor.set(0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				light.antialiasing = true;
				phillyCityLights.add(light);
			}

			var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
			add(streetBehind);

			phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
			add(phillyTrain);

			trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
			FlxG.sound.list.add(trainSound);

			// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

			var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
			add(street);
		}
		else if (SONG.song.toLowerCase() == 'milf' || SONG.song.toLowerCase() == 'satin-panties' || SONG.song.toLowerCase() == 'high')
		{
			curStage = 'limo';
			defaultCamZoom = 0.90;

			var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
			skyBG.scrollFactor.set(0.1, 0.1);
			add(skyBG);

			var bgLimo:FlxSprite = new FlxSprite(-200, 480);
			bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
			bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
			bgLimo.animation.play('drive');
			bgLimo.scrollFactor.set(0.4, 0.4);
			add(bgLimo);

			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}

			var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
			overlayShit.alpha = 0.5;
			// add(overlayShit);

			// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

			// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

			// overlayShit.shader = shaderBullshit;

			var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

			limo = new FlxSprite(-120, 550);
			limo.frames = limoTex;
			limo.animation.addByPrefix('drive', "Limo stage", 24);
			limo.animation.play('drive');
			limo.antialiasing = true;

			fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
			// add(limo);
		}
		else if (SONG.song.toLowerCase() == 'cocoa' || SONG.song.toLowerCase() == 'eggnog')
		{
			curStage = 'mall';

			defaultCamZoom = 0.80;

			var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			upperBoppers = new FlxSprite(-240, -90);
			upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
			upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
			upperBoppers.antialiasing = true;
			upperBoppers.scrollFactor.set(0.33, 0.33);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
			upperBoppers.updateHitbox();
			add(upperBoppers);

			var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
			bgEscalator.antialiasing = true;
			bgEscalator.scrollFactor.set(0.3, 0.3);
			bgEscalator.active = false;
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
			bgEscalator.updateHitbox();
			add(bgEscalator);

			var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
			tree.antialiasing = true;
			tree.scrollFactor.set(0.40, 0.40);
			add(tree);

			bottomBoppers = new FlxSprite(-300, 140);
			bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
			bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
			bottomBoppers.antialiasing = true;
			bottomBoppers.scrollFactor.set(0.9, 0.9);
			bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
			bottomBoppers.updateHitbox();
			add(bottomBoppers);

			var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
			fgSnow.active = false;
			fgSnow.antialiasing = true;
			add(fgSnow);

			santa = new FlxSprite(-840, 150);
			santa.frames = Paths.getSparrowAtlas('christmas/santa');
			santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
			santa.antialiasing = true;
			add(santa);
		}
		else if (SONG.song.toLowerCase() == 'winter-horrorland')
		{
			curStage = 'mallEvil';
			var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
			evilTree.antialiasing = true;
			evilTree.scrollFactor.set(0.2, 0.2);
			add(evilTree);

			var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
			evilSnow.antialiasing = true;
			add(evilSnow);
		}
		else if (SONG.song.toLowerCase() == 'senpai' || SONG.song.toLowerCase() == 'roses')
		{
			curStage = 'school';

			// defaultCamZoom = 0.9;

			var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
			bgSky.scrollFactor.set(0.1, 0.1);
			add(bgSky);

			var repositionShit = -200;

			var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
			bgSchool.scrollFactor.set(0.6, 0.90);
			add(bgSchool);

			var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
			bgStreet.scrollFactor.set(0.95, 0.95);
			add(bgStreet);

			var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
			fgTrees.scrollFactor.set(0.9, 0.9);
			add(fgTrees);

			var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
			var treetex = Paths.getPackerAtlas('weeb/weebTrees');
			bgTrees.frames = treetex;
			bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
			bgTrees.animation.play('treeLoop');
			bgTrees.scrollFactor.set(0.85, 0.85);
			add(bgTrees);

			var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
			treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
			treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
			treeLeaves.animation.play('leaves');
			treeLeaves.scrollFactor.set(0.85, 0.85);
			add(treeLeaves);

			var widShit = Std.int(bgSky.width * 6);

			bgSky.setGraphicSize(widShit);
			bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);
			bgTrees.setGraphicSize(Std.int(widShit * 1.4));
			fgTrees.setGraphicSize(Std.int(widShit * 0.8));
			treeLeaves.setGraphicSize(widShit);

			fgTrees.updateHitbox();
			bgSky.updateHitbox();
			bgSchool.updateHitbox();
			bgStreet.updateHitbox();
			bgTrees.updateHitbox();
			treeLeaves.updateHitbox();

			bgGirls = new BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);

			if (SONG.song.toLowerCase() == 'roses')
			{
				bgGirls.getScared();
			}

			bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
			bgGirls.updateHitbox();
			add(bgGirls);
		}
		else if (SONG.song.toLowerCase() == 'thorns')
		{
			curStage = 'schoolEvil';

			var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
			var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

			var posX = 400;
			var posY = 200;

			var bg:FlxSprite = new FlxSprite(posX, posY);
			bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
			bg.animation.addByPrefix('idle', 'background 2', 24);
			bg.animation.play('idle');
			bg.scrollFactor.set(0.8, 0.9);
			bg.scale.set(6, 6);
			add(bg);

			/* 
				var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
				bg.scale.set(6, 6);
				// bg.setGraphicSize(Std.int(bg.width * 6));
				// bg.updateHitbox();
				add(bg);

				var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
				fg.scale.set(6, 6);
				// fg.setGraphicSize(Std.int(fg.width * 6));
				// fg.updateHitbox();
				add(fg);

				wiggleShit.effectType = WiggleEffectType.DREAMY;
				wiggleShit.waveAmplitude = 0.01;
				wiggleShit.waveFrequency = 60;
				wiggleShit.waveSpeed = 0.8;
			 */

			// bg.shader = wiggleShit.shader;
			// fg.shader = wiggleShit.shader;

			/* 
				var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
				var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

				// Using scale since setGraphicSize() doesnt work???
				waveSprite.scale.set(6, 6);
				waveSpriteFG.scale.set(6, 6);
				waveSprite.setPosition(posX, posY);
				waveSpriteFG.setPosition(posX, posY);

				waveSprite.scrollFactor.set(0.7, 0.8);
				waveSpriteFG.scrollFactor.set(0.9, 0.8);

				// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
				// waveSprite.updateHitbox();
				// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
				// waveSpriteFG.updateHitbox();

				add(waveSprite);
				add(waveSpriteFG);
			 */
		}
		else
		{
			defaultCamZoom = 0.9;
			curStage = 'stage';
			bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);

			stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);

			stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;

			add(stageCurtains);
		}

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		if(!ConnectingState.modded)gf = new Character(400, 130, gfVersion);
		else if(FlxG.save.data.loadass) {
			gf = new online.CharacterOnline(430, 130, 'gf', false);
		}else gf = new Character(430, 130, 'gf', false);
		gf.scrollFactor.set(0.95, 0.95);
		
		if(!ConnectingState.modded)dad = new Character(100, 100, SONG.player2, false);
		else if(FlxG.save.data.loadass) {
			dad = new online.CharacterOnline(100, 100, 'dad', false);
		}else dad = new Character(100, 100, 'dad', false);

		boyfriend = new BFOnline(770, 450, SONG.player1);

				/* = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		if(!ConnectingState.modded)dad = new Character(100, 100, SONG.player2, false);
		else if(FlxG.save.data.loadass) {
			dad = new online.CharacterOnline(100, 100, 'dad', false);
		}else dad = new Character(100, 100, 'dad', false);

		boyfriend = new Boyfriend(770, 450, "bf");
-------------------------------------------------------------------
				if(!ConnectingState.modded)gf = new Character(400, 130, gfVersion);
		else if(FlxG.save.data.loadass) {
			gf = new online.CharacterOnline(100, 100, 'gf', false);
		}else gf = new Character(100, 100, 'gf', false);
		gf.scrollFactor.set(0.95, 0.95);
		
		if(!ConnectingState.modded)dad = new Character(100, 100, SONG.player2, false);
		else if(FlxG.save.data.loadass) {
			dad = new online.CharacterOnline(100, 100, 'dad', false);
		}else dad = new Character(100, 100, 'dad', false);

		if(!ConnectingState.modded)boyfriend = new Boyfriend(770, 450, SONG.player1);
		else if(FlxG.save.data.loadass) {
			boyfriend = new BFOnline(770, 450, "bf");
		}else boyfriend = new Boyfriend(770, 450, "bf"); 
		*/
		cstage = new FlxTypedGroup<FlxSprite>();
		add(cstage);

		#if !js sys.thread.Thread.create(()->{ #end
			var stages = new haxe.Http("http://"+GlobalSettings.curAddress+"/songs/"+SONG.song.toLowerCase()+"/stage.json");
			stages.onData = function(data:String){
				var assets = Json.parse(data);
				var stageassets:Array<Dynamic> = assets.assets; // THIS IS TO TRICK THE COMPILER INTO THINKING THIS IS AN DYNAMIC ARRAY, DO NOT REMOVE! 

				bg.alpha = 0;
				stageFront.alpha = 0;
				stageCurtains.alpha = 0;




				dad.x = assets.characters.dad.x;
				gf.x = assets.characters.gf.x;
				boyfriend.x = assets.characters.bf.x;

				dad.y = assets.characters.dad.y;
				gf.y = assets.characters.gf.y;
				boyfriend.y = assets.characters.bf.y;

				defaultCamZoom = assets.options.zoom;
				for(i in 0...assets.assets.length){
					var assetdecide = assets.version>=2?assets.assets[i].name:assets.assets[i][0];
					//Sys.sleep(1);
					BitmapData.loadFromFile("http://"+GlobalSettings.curAddress+"/songs/"+SONG.song.toLowerCase()+"/"+assetdecide+".png").then(function(image){
						trace("gaming");
						if(assets.version >= 2){
							var stageasset:FlxSprite = new FlxSprite(assets.assets[i].x, assets.assets[i].y);
							stageasset.pixels = image;
							stageasset.antialiasing = assets.antialiasing;
							stageasset.scrollFactor.set(assets.assets[i].scrollX, assets.assets[i].scrollY);
							stageasset.setGraphicSize(assets.assets[i].width, assets.assets[i].height);
							if(assets.assets[i].scale != null) stageasset.scale.set(assets.assets[i].scale.x, assets.assets[i].scale.y);
							stageasset.updateHitbox();
							if(assets.assets[i].animated){
								var animasset = new haxe.Http("http://"+GlobalSettings.curAddress+"/songs/"+SONG.song.toLowerCase()+"/"+assetdecide+".xml");
								animasset.onData = function(xmls:String){
									stageasset.frames = FlxAtlasFrames.fromSparrow(image, xmls);
									for(anim in 0...assets.assets[i].animations.length){
										stageasset.animation.addByPrefix(assets.assets[i].animations[anim], assets.assets[i].animations[anim], 24);
									}
									stageasset.animation.play(assets.assets[i].animations[0]);
								}
								animasset.request();
							}
							stageasset.ID = i;
							cstage.add(stageasset);
							cstage.sort((Order:Int, Obj1:FlxObject, Obj2:FlxObject)->
							{
								return FlxSort.byValues(Order, Obj1.ID, Obj2.ID);
							});
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
						new FlxTimer().start(5, (tmr:FlxTimer)->{
							cstage.sort((Order:Int, Obj1:FlxObject, Obj2:FlxObject)->
							{
								return FlxSort.byValues(Order, Obj1.ID, Obj2.ID);
							});
						});
						/*if(assets.assets[i][7]) {
							stageasset.animation.addByPrefix('idle', assets.assets[i][8], 24, true);
							stageasset.animation.play('idle');
						}*/
						return Future.withValue(image);
					});

				}
			};
			stages.request();
		#if !js
		});
		#end

		onlinemodetext = new FlxText(0, 0, 0, "Waiting for other player...", 60);
		onlinemodetext.screenCenter(XY);
		onlinemodetext.cameras = [camHUD];

		onlinemodetext.setFormat(Paths.font("vcr.ttf"), 60, FlxColor.WHITE, RIGHT);
		onlinemodetext.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		onlinemodetext.antialiasing = true;

		leftText = new FlxText(0, 30, 0, "", 60);
		leftText.screenCenter(XY);
		leftText.y = 30;
		leftText.cameras = [camHUD];

		leftText.setFormat(Paths.font("vcr.ttf"), 60, FlxColor.WHITE, RIGHT);
		leftText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case "bf-pixel":
				dad.y += 500;
				dad.x += 200;
			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}
		if(ConnectingState.modded) camPos.x += 400;
		//if(!ConnectingState.modded)boyfriend = new Boyfriend(770, 450, SONG.player1);
		//else boyfriend = new Boyfriend(770, 450, "bf");
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		add(gf);
		
		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		//var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		//doof.scrollFactor.set();
		//doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;
		if(downscroll) strumLine = new FlxSprite(0, FlxG.height - 180).makeGraphic(FlxG.width, 10);  // 180
		else strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		//add(strumLine);
		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();
		// startCountdown();

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if(downscroll)progressBG = new FlxSprite(0, FlxG.height * 0.95).loadGraphic(Paths.image('healthBar'));
		else progressBG = new FlxSprite(0, FlxG.height - FlxG.height + 10).loadGraphic(Paths.image('healthBar'));
		progressBG.screenCenter(X);
		progressBG.scrollFactor.set();
		if(FlxG.save.data.pgbar) add(progressBG);


		var pgBar = new FlxBar(progressBG.x + 4, progressBG.y + 4, LEFT_TO_RIGHT, Std.int(progressBG.width - 8), Std.int(progressBG.height - 8), this,
		'progress', 0, FlxG.sound.music.length);
		pgBar.scrollFactor.set();
		// healthBar
		if(FlxG.save.data.pgbar) add(pgBar);
		if(downscroll)healthBarBG = new FlxSprite(0, FlxG.height * 0.1).loadGraphic(Paths.image('healthBar'));
		else healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();

		//p1scoretext = new FlxText(FlxG.width * 0.001, healthBar.y - 40, 0, ConnectingState.p1name + " Score: " + p1score, 16);
		//p2scoretext = new FlxText(FlxG.width * 0.8 - ConnectingState.p2name.length, healthBar.y - 20, 0, ConnectingState.p2name + " Score: " + p2score, 16);
		p1scoretext = new FlxText(boyfriend.x, boyfriend.height, ConnectingState.p1name + " Score: " + p1score, 16);
		p2scoretext = new FlxText(dad.x, dad.height, ConnectingState.p2name + " Score: " + p2score, 16);

		p1scoretext.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		p1scoretext.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

		p2scoretext.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		p2scoretext.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

		p1scoretext.cameras = [camHUD];
		p2scoretext.cameras = [camHUD];

		if(!ConnectingState.modded)iconP1 = new HealthIcon(SONG.player1, true);
		else iconP1 = new HealthIcon("bf", true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		if(!ConnectingState.modded)iconP2 = new HealthIcon(SONG.player2, false);
		else iconP2 = new HealthIcon("dad", false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		healthBar.createFilledBar(dominantColor(iconP2), dominantColor(iconP1)); //0xFFFF0000, 0xFF66FF33
		// healthBar
		add(healthBar);
		add(iconP1);
		add(iconP2);
		var songtext = new FlxText(healthBarBG.x + (healthBarBG.width / 2) - 20, healthBarBG.y, 0, SONG.song, 16);
		songtext.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		songtext.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		songtext.scrollFactor.set();
		songtext.cameras = [camHUD];
		add(songtext);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		scoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		missTxt = new FlxText(healthBarBG.x + healthBarBG.width - 330, healthBarBG.y + 30, 0, "", 20);
		missTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		missTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		missTxt.scrollFactor.set();
		add(missTxt);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		progressBG.cameras = [camHUD];
		pgBar.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];

		scoreTxt.cameras = [camHUD];
		missTxt.cameras = [camHUD];
		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			if(PauseSubState.PauseSubState.skipped) {
				PauseSubState.skipped = false;
				endSong();
			}
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					//startCountdown();
			}
		}
			add(onlinemodetext);
			roomcode = new FlxText(5, FlxG.height - 38, 0, "Room code: " + code, 12);
			roomcode.scrollFactor.set();
			roomcode.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			roomcode.cameras = [camHUD];
		add(leftText);
		new FlxTimer().start(options.actualVsMode?5:1, (tmr:FlxTimer)->rooms.send("loaded"));
		var hscripts = new haxe.Http("http://"+GlobalSettings.curAddress+"/songs/"+SONG.song.toLowerCase()+"/chart.hx");
		hscripts.onData = (data)->{
			try{
				var program = parser.parseString(data);
				hscriptshit(program);
			}
		}
		if(FlxG.save.data.loadass)hscripts.request();
		super.create();
	}

	function hscriptshit(program:hscript.Expr){
		if(!FlxG.save.data.loadass) return;
		interp.variables.set("game",this);
		interp.variables.set("add",this.add);
		interp.variables.set("remove",this.remove);
		interp.variables.set("FlxG",FlxG);
		interp.variables.set("Sys",Sys);
		interp.variables.set("Math",Math);
		interp.variables.set("FlxSprite",FlxSprite);
		interp.variables.set("FlxObject",FlxObject);
		interp.variables.set("Sys",Sys);
		interp.variables.set("Character",Character);
		interp.variables.set("CharacterOnline",CharacterOnline);
		interp.variables.set("FlxTimer",FlxTimer);
		interp.variables.set("FlxSprite",FlxSprite);
		interp.variables.set("FlxTween",FlxTween);
		interp.variables.set("FlxEase",FlxEase);
		interp.variables.set("FlxText",FlxText);
		interp.variables.set("Alphabet",Alphabet);
		interp.variables.set("MusicBeatState",MusicBeatState);
		interp.variables.set("MusicBeatState",MusicBeatState);
		interp.variables.set("camFollow",camFollow);
		interp.variables.set("curBeat",currentBeat);
		interp.variables.set("iconP1",iconP1);
		interp.variables.set("iconP2",iconP2);
		interp.variables.set("playerStrums",playerStrums);
		interp.variables.set("enemyStrums",enemyStrums);
		interp.variables.set("FlxCamera",FlxCamera);
		interp.variables.set("defaultCamZoom",defaultCamZoom);
		interp.variables.set("notes",notes);
		interp.variables.set("stage",cstage);
		interp.variables.set("health",health);
		interp.variables.set("healthBar",healthBar);
		interp.variables.set("boyfriend",boyfriend);
		interp.variables.set("gf",gf);
		interp.variables.set("dad",dad);
		interp.variables.set("camHUD",camHUD);
		interp.variables.set("BitmapData",BitmapData);
		interp.variables.set("OnlineSprite",modchart.OnlineSprite);
		shouldrun = true;
		interp.execute(program);
		interp.variables.get('onStart')();
	}

	private var enemyStrums:FlxTypedGroup<FlxSprite>;
	var shouldrun:Bool = false;

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	function startCountdown():Void
	{
		inCutscene = false;
		playedgame = true;
		generateStaticArrows(0);
		generateStaticArrows(1);
		loadedstrums = true;
		if(midscroll){
			enemyStrums.forEach((spr:FlxSprite)->{
				spr.x -= 3000;
			});
			
			playerStrums.forEach((spr:FlxSprite)->{
				spr.x -= 275;
			});
			
		}
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
							if(shouldrun) interp.variables.get('onCountdown')();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused){
			if(ConnectingState.modded)FlxG.sound.playMusic(modinst, 1, false); //Paths.inst(SONG.song)
			else FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
		}
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices){
			if(ConnectingState.modded)vocals = new FlxSound().loadEmbedded(modvoices); //Paths.voices(SONG.song)
			else vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
		}else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					if(downscroll) {
						sustainNote.flipY = true;
					}
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = options.vsMode ? !gottaHitNote : gottaHitNote;

					if (sustainNote.mustPress)
						{
							sustainNote.x += options.vsMode ? 0 : FlxG.width / 2; // general offset
							if(midscroll){
								if(options.vsMode) sustainNote.x = FlxG.width / 2 - 275;
								else swagNote.x -= 275;
							}
						}
						else{
							if(options.vsMode) sustainNote.x += FlxG.width / 2;
							if(midscroll)sustainNote.x -= 2035;
						}
				}

				swagNote.mustPress = options.vsMode ? !gottaHitNote : gottaHitNote;

				if (swagNote.mustPress)
					{
						swagNote.x += options.vsMode ? 0 : FlxG.width / 2; // general offset
						if(midscroll){
							if(options.vsMode) swagNote.x = FlxG.width / 2 - 275;
							else swagNote.x -= 275;
						} // midscroll
					}
					else{
						if(options.vsMode) swagNote.x += FlxG.width / 2;
						if(midscroll)swagNote.x -= 2035;
					}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, 0); //y was strumLine.y
			if (downscroll) {
				babyArrow.y += 550; // 10
				//strumLine.y += 74;
				//add(strumLine);
			}
			else {
				babyArrow.y = strumLine.y;
				babyArrow.y -= 10;
			}
			//babyArrow.screenCenter(X);
			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}else
			{
				enemyStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			var pl = player;
			if(options.vsMode && player == 1)
				{
					pl = 0;
				}
				else if(options.vsMode && player == 0)
					{
						pl = 1;
					}
			babyArrow.x += ((FlxG.width / 2) * pl);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}
	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		if(controls.BACK && !startedMatch) {
			startedMatch = false;
			rooms.leave();
			FlxG.switchState(new FNFNetMenu());
		}
		if(assing){
			remove(onlinemodetext);
			remove(roomcode);
			add(p1scoretext);
			add(p2scoretext);
			remove(roomcode);
			startCountdown();
			assing = false;
		}
		if(otherfinished) {
			otherfinished = false;
			remove(onlinemodetext);
			openSubState(new online.BattleResultSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
		currentBeat = curBeat;
		#if !debug
		perfectMode = false;
		#end
		progress = Conductor.songPosition;
		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.changeIcon(SONG.player1, true);
			else
				iconP1.changeIcon('bf-old', true);
		}
		if(shouldrun) interp.variables.get('update')(elapsed);
		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);
		p2scoretext.x = 0;
		p2scoretext.y = 700;

		p1scoretext.x = 870;
		p1scoretext.y = 700;

		scoreTxt.text = "Score:" + songScore;
		missTxt.text = "Missed:" + missedNotes;
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			trace("pissing");
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if(iconP1.loaded){
			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;
			if(iconP1.recalc){
				healthBar.createFilledBar(dominantColor(iconP2), dominantColor(iconP1));
				iconP1.recalc = false;
			}
		}

		if(iconP2.loaded)
		{
			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;
			if(iconP2.recalc){
				healthBar.createFilledBar(dominantColor(iconP2), dominantColor(iconP1));
				iconP2.recalc = false;
			}
		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */


		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150 + dad.camPos.x, dad.getMidpoint().y - 100 + dad.camPos.y);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + boyfriend.camPos.x, boyfriend.getMidpoint().y - 100 + boyfriend.camPos.y);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		FlxG.watch.addQuick("theRNGnumber", holymoly);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = false;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}
		try{
			if(options.actualVsMode){
			if(controls.UP_P) rooms.send('hitnote', {strum: 2, held: true});
			if(controls.UP_R) rooms.send('hitnote', {strum: 2, held: false});
			if(controls.DOWN_P) rooms.send('hitnote', {strum: 1, held: true});
			if(controls.DOWN_R) rooms.send('hitnote', {strum: 1, held: false});
			if(controls.LEFT_P) rooms.send('hitnote', {strum: 0, held: true});
			if(controls.LEFT_R) rooms.send('hitnote', {strum: 0, held: false});
			if(controls.RIGHT_P) rooms.send('hitnote', {strum: 3, held: true});
			if(controls.RIGHT_R) rooms.send('hitnote', {strum: 3, held: false});
			}
		}
		// CHEAT = brandon's a pussy
		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}
				if(downscroll) daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(SONG.speed, 2))); //thanks to the contributors of kade engine and the funkin android port for not making me destroy my pc in rage!
				else daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				//daNote.y = (strumLine.y - 1000 * (0.45 / FlxMath.roundDecimal(SONG.speed, 2)));

				//daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					camZooming = false;
					var altAnim:String = "";
					var alter:Bool = false;
					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim){
							altAnim = '-alt';
							altprefix = '-alt';
							alter = true;
						}
					}
					if(!options.vsMode)
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
						}
					else
						switch(Math.abs(daNote.noteData))
						{
							case 0:
								boyfriend.playAnim('singLEFT', true);
							case 1:
								boyfriend.playAnim('singDOWN', true);
							case 2:
								boyfriend.playAnim('singUP', true);
							case 3:
								boyfriend.playAnim('singRIGHT', true);
						}
					if(shouldrun) interp.variables.get('dadNoteHit')(Math.abs(daNote.noteData), alter);
					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
				
				if (daNote.y < -daNote.height && !downscroll || (daNote.y >= strumLine.y + 106) && downscroll)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						missedNotes++;
						health -= 0.0475;
						combo = 0;
						vocals.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();
	}

	public function endSong():Void
	{
		startedMatch = false;
		onlinemodetext.text = "Waiting for other player to finish...";
		onlinemodetext.screenCenter(XY);
		add(onlinemodetext);
        //rooms.leave();

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		boyfriend.stunned = true;

		//persistentUpdate = false;
		//persistentDraw = false;
		paused = true;

		vocals.stop();
		FlxG.sound.music.stop();
		Highscore.saveScore(SONG.song.toLowerCase(), Math.round(songScore), storyDifficulty);
		rooms.send("finished");
		//openSubState(new online.BattleResultSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}
        rooms.send("message", {rating: daRating});
		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				// trace(daNote.noteData);
				/* 
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}

					//this is already done in noteCheck / goodNoteHit
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				 */
			}
			else
			{
				badNoteCheck();
			}
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (leftR)
						spr.animation.play('static');
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
						spr.animation.play('static');
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (upR)
						spr.animation.play('static');
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
						spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			if(noteDiff < Conductor.safeZoneOffset * 1 && FlxG.save.data.kadeinput){
				return;
			}
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!pracMode) songScore -= 10;
			missedNotes++;
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			if(options.vsMode)
				switch (Math.abs(note.noteData))
				{
					case 0:
						dad.playAnim('singLEFT', true);
					case 1:
						dad.playAnim('singDOWN', true);
					case 2:
						dad.playAnim('singUP', true);
					case 3:
						dad.playAnim('singRIGHT', true);
				}
			else
				switch(Math.abs(note.noteData))
				{
					case 0:
						boyfriend.playAnim('singLEFT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
				}
			if(shouldrun) interp.variables.get('bfNoteHit')(Math.abs(note.noteData));
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();

		if(shouldrun){
			interp.variables.set("curStep",curStep);
			interp.variables.get('stepHit')();
		}

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if(shouldrun){
			interp.variables.set("curBeat",curBeat);
			interp.variables.get('beatHit')();
		}
		
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				if(dadanim)dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);

			if (SONG.song == 'Tutorial' && dad.curCharacter == 'gf')
			{
				dad.playAnim('cheer', true);
			}
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
