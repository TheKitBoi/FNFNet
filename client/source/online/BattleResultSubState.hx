package online;

import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import online.PlayStateOnline.p1score;
import online.PlayStateOnline.p2score;
import online.ConnectingState.p1name;
import online.ConnectingState.p2name;
import online.PlayStateOnline.rooms;
class BattleResultSubState extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;
    var loseorwin:FlxText;
	var aktc:Alphabet;
	var stageSuffix:String = "";
	var lose:Bool = true;
	public function new(?x:Float, ?y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		super();
		if(ConnectingState.conmode == "host")lose = p2score > p1score;
		else if(ConnectingState.conmode == "join")lose = p1score > p2score;

		var loseorwintext = switch(lose){
			case false:
				'You won!';
			case true:
				'You lost...';
			default:
				'Draw';
		}

		
		var camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		bg.cameras = [camHUD];
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		aktc = new Alphabet(FlxG.width * 0.001, FlxG.height * 0.85, "Press space to continue", true);
		aktc.cameras = [camHUD];
        //if(Math.max(PlayStateOnline.p1score, PlayStateOnline.p2score))
		var low = new FlxText(FlxG.width * 0.65, FlxG.height * 0.25, loseorwintext, true);
		low.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT);
		low.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		low.color = switch(lose){
			case false:
				FlxColor.GREEN;
			case true:
				FlxColor.RED;
			default:
				FlxColor.ORANGE;
		}
		low.cameras = [camHUD];

        loseorwin = new FlxText(FlxG.width * 0.01, 60, '
		Final Score:

		$p1name: $p1score
		$p2name: $p2score
		' + PlayStateOnline.p2score, 32);
		loseorwin.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT);
		loseorwin.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		//loseorwin.font = Paths.font('fnf');
		Conductor.songPosition = 0;
		loseorwin.cameras = [camHUD];
		
		if(FlxG.save.data.loggedin){
			funnytext = new EzText(loseorwin.x + 300, loseorwin.y + 450, "Account Score: ", 40, 3);
			funnytext.cameras = [camHUD];
			scorecheck();
			add(funnytext);
		}
		add(loseorwin);
		add(aktc);
		add(low);
	
		FlxG.sound.playMusic(Paths.music('breakfast'));
		Conductor.changeBPM(100);
		if(FlxG.save.data.loggedin) scorecheck();
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		//FlxG.camera.scroll.set();
		//FlxG.camera.target = null;
	}
	var funnytext:EzText;

	public function scorecheck(){
        var request = new haxe.http.HttpRequest();
        request.method = "POST";
        request.url = new haxe.http.Url("http://"+Config.data.addr+":"+Config.data.port+"/login/");
        request.headers.set("Content-Type", "application/json");
		request.data = '{"username":"${FlxG.save.data.username}", "password":"${FlxG.save.data.password}", "action":"${lose?"lose":"win"}", "value": 0}';
        request.send({
          onData: function (data : String) {
			  var stuff = Json.parse(data);
			  var rs = stuff.score;
			  var pointthing = lose?1:5; //haxe dissapoints yet again
				funnytext.text = "Account Score: "+stuff.oldscore + " + " + pointthing + " = " + rs;
          },
          onError: function (error : String, ?data : String) {
			  
          },
          onStatus: function (code : Int) {
          }
        });
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			FlxG.sound.music.stop();
			rooms.leave();
			FlxG.switchState(new online.FNFNetMenu());
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;
}