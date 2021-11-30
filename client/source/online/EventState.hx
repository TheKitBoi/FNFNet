package online;
import Note;
import openfl.events.ProgressEvent;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.net.URLRequest;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
import openfl.utils.Future;
import openfl.display.BitmapData;
import flixel.FlxSprite;
using StringTools;
class EventState extends MusicBeatState 
{
    var eventDesc:String = "";
    var coolshit:FlxSprite;
    var coolshit2:FlxSprite;
    var ass:Int = 0;
    var difficultySelectors:FlxGroup;
    var descText:EzText;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
    var dykan:FlxSprite;
    override function create(){
        var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.color = 0xFFea71fd;
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;
        add(menuBG);
        
        coolshit = new FlxSprite(812, 263).makeGraphic(300, 100);
        coolshit.alpha = 0.5;
        add(coolshit);

        coolshit2 = new FlxSprite(914, 169).makeGraphic(100, 300);
        coolshit2.alpha = 0.5;
        add(coolshit2);

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");
		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftArrow = new FlxSprite(10 + 10, 100);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

        var eventdata = new haxe.Http("http://"+Config.data.resourceaddr+"/event/event.json");
        eventdata.onData = (data:Dynamic) -> {
            var datera = haxe.Json.parse(data);
            var title = new Alphabet(0, 0, datera.title, true);
            title.screenCenter(X);
            title.y = 25;
            add(title);
            BitmapData.loadFromFile("http://"+Config.data.resourceaddr+"/event/event.png").then((image:BitmapData) -> {
                var eventChar = new FlxSprite(724, 150);
                eventChar.pixels = image;
                add(eventChar);
                return Future.withValue(image);
            });
            
            endsat = new EzText(20, 600, "Ends at: ", 24, 2);
            add(endsat);
            descText = new EzText(20, 200, datera.description, 20, 1);
            add(descText);
            var targetTime = Date.fromTime(datera.deadline).getTime();
            timer = new haxe.Timer(1000);
            timer.run = function() {
              var now = Date.now().getTime();
              var remainingMs = targetTime - now;
        
              var days = Math.floor(remainingMs / dayInMs);
              var hours = Math.floor((remainingMs % dayInMs) / hourInMs);
              var minutes = Math.floor((remainingMs % hourInMs) / minuteInMs);
              var seconds = Math.floor((remainingMs % minuteInMs) / 1000);
        
              // Format ourselves for fun. We could have used `DateTools.format` here too
              var d = '$days'.lpad("0", 2);
              var h = '$hours'.lpad("0", 2);
              var m = '$minutes'.lpad("0", 2);
              var s = '$seconds'.lpad("0", 2);
              
              if (remainingMs > 0) {
                endsat.text = 'Ends in: $d days $h hours $m minutes $s seconds';
                trace('$d days - $h:$m:$s');
              } else {
                FlxG.switchState(new FNFNetMenu('event expired'));
                timer.stop();
              }
            }
        }
        eventdata.onError = (err:Dynamic) -> {
            var ap = new Alphabet(0, 0, "No event available.", true);
            ap.screenCenter(XY);
            add(ap);
            remove(coolshit);
            remove(coolshit2);
        }
        eventdata.request();
        dykan = new FlxSprite(100, 100).makeGraphic(300, 500);
        super.create();
    }
    var endsat:EzText;
    var timer:haxe.Timer;
    inline static var minuteInMs = 1000 * 60;
    inline static var hourInMs = minuteInMs * 60;
    inline static var dayInMs = hourInMs * 24;

    override function update(elapsed:Float){
        if(controls.RESET) FlxG.resetState();
        if(controls.BACK) {
            timer.stop();
            FlxG.switchState(new FNFNetMenu());
        }
        if(controls.ACCEPT){
            Note.single = true;
            FlxG.camera.flash();
            FlxG.sound.play(Paths.music("titleShoot"));
            var loadingtxt = new Alphabet(0, 0, "Loading Songs please wait...", true);
            loadingtxt.screenCenter(XY);
            add(loadingtxt);
            //var FUCK = new Sound(new URLRequest('http://'+Config.data.resourceaddr+'/event/Inst.ogg'));
            var modif = switch(curDifficulty){
                case 0:
                    "-easy";
                default:
                    "";
                case 2:
                    "-hard";
            }
            var http = new haxe.Http('http://'+Config.data.resourceaddr+'/event/chart$modif.json');
            GlobalSettings.songDir = "../event";
            //PlayState.modinst.addEventListener(ProgressEvent.PROGRESS, (e:Event) ->{trace("nigmode");});
            timer.stop();
            http.onData = function (data:String) {
                PlayState.modinst = new Sound();
                PlayState.modvoices = new Sound();
                PlayState.modinst.addEventListener(Event.COMPLETE, function(e:Event){
                    PlayState.modvoices.addEventListener(Event.COMPLETE, function(e:Event){
                        PlayState.SONG = Song.loadFromJson(data, "ass", true);
                        PlayState.isStoryMode = false;
                        PlayState.storyDifficulty = curDifficulty;
            
                        PlayState.storyWeek = 1;
                        //@:privateAccess
                        //sys.io.File.saveBytes("cock.ogg", PlayState.modinst.__buffer.data.buffer);
                        //LoadingOnline.loadAndSwitchState(new PlayStateOnline());
                        LoadingState.loadAndSwitchState(new PlayState());
                    
                    });
                    PlayState.modvoices.load(new URLRequest('http://'+Config.data.resourceaddr+'/event/Voices.ogg'));
                });
                
                PlayState.modinst.load(new URLRequest('http://'+Config.data.resourceaddr+'/event/Inst.ogg'));
            }
            http.onError = function (error) {
                FlxG.switchState(new MainMenuState());
            }
            http.request();
        }
        if (controls.RIGHT_P)
            changeDifficulty(1);
        if (controls.LEFT_P)
            changeDifficulty(-1);
        coolshit.angle++;
        coolshit2.angle++;
        super.update(elapsed);
    }
    var curDifficulty:Int = 1;

    function changeDifficulty(change:Int = 0):Void
        {
            curDifficulty += change;
    
            if (curDifficulty < 0)
                curDifficulty = 2;
            if (curDifficulty > 2)
                curDifficulty = 0;
    
            sprDifficulty.offset.x = 0;
    
            switch (curDifficulty)
            {
                case 0:
                    sprDifficulty.animation.play('easy');
                    sprDifficulty.offset.x = 20;
                case 1:
                    sprDifficulty.animation.play('normal');
                    sprDifficulty.offset.x = 70;
                case 2:
                    sprDifficulty.animation.play('hard');
                    sprDifficulty.offset.x = 20;
            }
    
            sprDifficulty.alpha = 0;
    
            // USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
            sprDifficulty.y = leftArrow.y - 15;
            
            FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
        }
}
/*
{
    "name": "test",
    "description": "doing your mom\ndoin doin your mom",
    "deadline": 177763490
}
*/