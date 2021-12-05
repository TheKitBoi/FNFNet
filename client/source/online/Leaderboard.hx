package online;

import openfl.display.BitmapData;
import flixel.FlxG;
import openfl.utils.Future;
import flixel.FlxSprite;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.util.FlxColor;
import haxe.Json;
import flixel.group.FlxGroup;

class Leaderboard extends MusicBeatState
{
    override function create(){
        var shut = new FlxGroup();
        add(new FlxSprite().loadGraphic(Paths.image("menuBG")));
        var request = new haxe.http.HttpRequest();
        request.method = "POST";
        request.url = new haxe.http.Url("http://"+Config.data.addr+":"+Config.data.port+"/leaderboard/");
        request.headers.set("Content-Type", "application/json");

        request.send({
          onData: function (data : String) {
              add(shut);
                var accdata = Json.parse(data);
                accdata.data[0];
                for(i in 0...accdata.data.length){
                    var box = new FlxShapeBox(50, 25 + (i * 100), 50, 50, {thickness: 5, color: FlxColor.BLACK}, FlxColor.TRANSPARENT);
                    shut.add(box);
                    var ass = i+1;
                    var number = new EzText(0, 25 + (i * 100), ""+ass, 32, 2, switch(ass){
                        case 1: FlxColor.YELLOW;
                        case 2: FlxColor.GRAY;
                        case 3: FlxColor.BROWN;
                        default: FlxColor.WHITE;
                    });

                    shut.add(number);

                    BitmapData.loadFromFile(accdata.data[i].pfp).then((image)->{
                        trace('based');
                        var pfp = new FlxSprite(50, 25 + (i * 100)).loadGraphic(image); 
                        //pfp.pixels = image
                        pfp.setGraphicSize(50, 50); 
                        pfp.updateHitbox();
                        shut.add(pfp);
                        return Future.withValue(image);
                    });

                    var name = new EzText(0, 0, accdata.data[i].username + ' | ID: ${accdata.data[i].id}', 32, 2);
                    //name.color = accdata.admin==1?FlxColor.RED:FlxColor.WHITE;
                    name.x = 450;
                    name.y = 25 + (i * 100);
                    shut.add(name);
                    

                    var win = new EzText(110, 25 + (i *100), "\nWins: "+accdata.data[i].wins+"\nLoses: "+accdata.data[i].loses+"\n", 20, 2);
                    shut.add(win);

                    var points = new EzText(110, 25 + (i * 100), "Points: "+accdata.data[i].points, 20, 2);
                    shut.add(points);
                }

          },
          onError: function (error : String, ?data : String) {
              trace(error);
              var errore = new Alphabet(0, 0, Json.parse(data).message, true);
              errore.screenCenter(XY);
              add(errore);
          },
          onStatus: function (code : Int) {
              trace("Status " + code);
          }
        });
        super.create();
    }

    override function update(elapsed:Float){
        if(FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new Account());
        super.update(elapsed);
    }
}