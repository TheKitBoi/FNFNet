package online;

import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import openfl.utils.Future;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.tweens.motion.QuadMotion;
import flixel.FlxSprite;
import haxe.Json;
import flixel.FlxG;

class Account extends MusicBeatState
{
    var lerank:EzText;
    var id:Int;

    public function new(id:Int = 0){
        if(id == 0) this.id = 0;
        else this.id = id;
        super();
    }

    override function create(){
        var bg = new FlxSprite().loadGraphic(Paths.image("menuBG"));
        add(bg);
        var request = new haxe.http.HttpRequest();
        request.method = "POST";
        request.url = new haxe.http.Url("http://"+Config.data.addr+":"+Config.data.port+(id==0?"/login/":"/info/"));
        request.headers.set("Content-Type", "application/json");
        var shit = (id==0?'{"username":"${FlxG.save.data.username}", "password":"${FlxG.save.data.password}"':'{"id": $id');
        request.data = shit +', "action": "accinfo", "value": 0}';
        request.send({
          onData: function (data : String) {
                var accdata = Json.parse(data);
                if(accdata.banned == 1){
                     var errore = new Alphabet(0, 0, id==0?"Your account has been banned.":"This account has been banned.", true);
                     errore.screenCenter(XY);
                     add(errore);
                     return;
                }

                var box = new FlxShapeBox(50, 25, 200, 200, {thickness: 10, color: FlxColor.BLACK}, FlxColor.TRANSPARENT);
                add(box);



                BitmapData.loadFromFile(accdata.pfp).then((image)->{
                    trace('based');
                    var pfp = new FlxSprite(50, 25).loadGraphic(image); 
                    //pfp.pixels = image
                    pfp.setGraphicSize(200, 200); 
                    pfp.updateHitbox();
                    pfp.antialiasing = true;
                    add(pfp);
                    return Future.withValue(image);
                });

                BitmapData.loadFromFile(accdata.bg).then((image)->{
                    trace('based');
                    //pfp.pixels = image
                    bg.loadGraphic(image);
                    bg.setGraphicSize(1280, 720); 
                    bg.antialiasing = true;
                    bg.updateHitbox();
                    return Future.withValue(image);
                });
                var idtext = new EzText(100, 398, "ID:" + accdata.id, 24, 2);
                add(idtext);
                var name = new Alphabet(0, 0, accdata.username, true);
                name.color = accdata.admin==1?FlxColor.RED:FlxColor.WHITE;
                name.x = 300;
                name.y = 25;
                add(name);
                
                var phrase = new EzText(300, 100, accdata.phrase, 26, 2);
                add(phrase);

                var win = new EzText(100, 255, "\nWins: "+accdata.wins+"\nLoses: "+accdata.loses+"\n", 40, 2);
                add(win);

                var rank = new EzText(100, 450, "Rank: ", 40, 2);
                add(rank);

                deciderank(accdata.points);

                var press = new EzText(400, 600, "Press [S] to search for ID.", 32, 2);
                add(press);

                var press2 = new EzText(400, 640, "Press [L] for leaderboard.", 32, 2);
                add(press2);

                var press3 = new EzText(400, 680, "Press [R] to edit your profile.", 32, 2);
                if(id==0)add(press3);


                var creationdate = new EzText(100, 530, "Created on: "+accdata.creation, 26, 2);
                add(creationdate);

                var points = new EzText(100, 500, "Points: "+accdata.points, 32, 2);
                add(points);

          },
          onError: function (error : String, ?data : String) {
              var errore = new Alphabet(0, 0, error != "EOF"?Json.parse(data).message:"Could not connect to server", true);
              errore.screenCenter(XY);
              add(errore);
          },
          onStatus: function (code : Int) {
              trace("Status " + code);
          }
        });
    }

    override function update(elapsed:Float){
        if(FlxG.keys.justPressed.ESCAPE) {
            FlxG.mouse.visible = false;
            FlxG.switchState(new MainMenuState());
        }
        if(FlxG.keys.justPressed.R) FlxG.openURL("http://"+Config.data.addr+":"+Config.data.port+"/edit.html");
        if(FlxG.keys.justPressed.L){FlxG.switchState(new Leaderboard());}
        if(FlxG.keys.justPressed.S){
            FlxG.mouse.visible = true;
            var bar = new FlxInputText(400, 0, 150, "", 14);
            bar.screenCenter(Y);
            add(bar);

            var button = new FlxButton(550, bar.y, "Search", ()->{
                if(bar.text == "") return;
                var id = Std.parseInt(bar.text);
                if(id == null) return;
                
                FlxG.mouse.visible = false;
                FlxG.switchState(new Account(id)); 
            });
            button.antialiasing = true;
            button.scale.set(1.1, 1.2);
            add(button);
        }
        super.update(elapsed);
    }

    function deciderank(points:Int){
        lerank = new EzText(218, 450, 40, 2);
        if(points == 0){
            lerank.text = "Newfriend";
            lerank.color = FlxColor.GRAY;
        }
        if(points > 1 && points <= 3){
            lerank.text = "Getting Started";
            lerank.color = FlxColor.WHITE;
        }
        if(points > 3 && points <= 10){
            lerank.text = "Gaming";
            lerank.color = FlxColor.YELLOW;
        }
        if(points > 10 && points <= 50){
            lerank.text = "Funky";
            lerank.color = FlxColor.RED;
        }
        if(points > 50 && points <= 150){
            lerank.text = points==69?"haha funny sex number":"[[BIG SHOT]]";
            lerank.color = FlxColor.BLUE;
        }
        if(points > 150 && points <= 250){
            lerank.text = "Based";
            lerank.color = FlxColor.CYAN;
        }
        if(points > 250 && points <= 350){
            lerank.text = "Keyed";
            lerank.color = FlxColor.LIME;
        }
        if(points > 1000){
            lerank.text = "Addicted";
            lerank.color = FlxColor.PURPLE;
        }
        if(points > 10000){
            lerank.text = "holy shit go outside";
            lerank.color = FlxColor.PURPLE;
        }
        add(lerank);
    }
}