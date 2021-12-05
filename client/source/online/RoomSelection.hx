package online;

import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUIList;
import flixel.FlxG;
import flixel.group.FlxGroup;
import io.colyseus.Client;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.addons.display.shapes.FlxShapeBox;
using StringTools;

class RoomSelection extends MusicBeatState
{
    var sprDifficulty:FlxSprite;
    var coly:Client;
    var curSelected:Int = 0;
    var shuf:Array<{clients:Int, id:String, user:String, song:String, difficulty:String, registered:Bool}> = [];
    var fuck:FlxTypedGroup<Alphabet>;
    var songname:EzText;
    override function create(){ //1280
        ConnectingState.modded = false;
        var box = new FlxSprite(850, 0).makeGraphic(430, 720, 0xFF000000);
        box.alpha = 0.5;
        //box.screenCenter(XY); 
        var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.color = 0xFFea71fd;
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;
        add(menuBG);
        fuck = new FlxTypedGroup<Alphabet>();
        add(fuck);
        add(box);
        songname = new EzText(box.x + 10, box.y, "\nSong:\n", 24, 2);
        add(songname);

        sprDifficulty = new FlxSprite(box.x + 10, 500);
		sprDifficulty.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
        add(sprDifficulty);
		var dumbText = new EzText(857, 687, "Press R to refresh the list.", 24, 2);
		add(dumbText);
        coly = new Client('ws://' + Config.data.addr + ':' + Config.data.port);
        coly.getAvailableRooms("battle", function(err, rooms) {
            if (err != null) {
              trace(err);
              return;
            }
            trace(rooms);
            var boom:Array<{clients:Int, id:String, user:String, song:String, difficulty:String, registered:Bool}> = [];
            for (room in rooms) {

                boom.push({
                    clients: room.clients,
                    id: room.roomId,
                    user: room.metadata.hoster,
                    song: room.metadata.song,
                    difficulty: room.metadata.difficulty,
                    registered: room.metadata.registered
                });
                //FlxG.switchState(new ConnectingState('battle', 'join'));
            }
            var values = [];
            for(i in 0...boom.length){
                var randval = FlxG.random.int(0, boom.length - 1);
                if(!values.contains(randval))shuf.push(boom[randval]);
                else{
                    while(values.contains(randval)){
                        randval = FlxG.random.int(0, boom.length - 1);
                    }
                    shuf.push(boom[randval]);
                }
                values.push(randval);
                trace(shuf);
                var us=shuf[i].user;
                var sng=shuf[i].song;
                var songtext = new Alphabet(0, (70 * i) + 30, us, true, false);
                songtext.x += 50;
                songtext.isMenuItem = true;
                songtext.targetY = i;
                fuck.add(songtext);

                if(i==10) break;
            }
            selection();
        });
    }

    override function update(elapsed:Float)
    {
        if(controls.ACCEPT) {
            trace(shuf[curSelected].registered);
            LobbyState.p1color = shuf[curSelected].registered?FlxColor.YELLOW:FlxColor.WHITE;
            FlxG.switchState(new ConnectingState('battle', 'code', shuf[curSelected].id));}
        if(controls.UP_P) selection(-1);
        if(controls.DOWN_P) selection(1);
        if(controls.BACK) FlxG.switchState(new FNFNetMenu());
        if(FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new FNFNetMenu());
        }
        if(controls.RESET){
            coly.getAvailableRooms("battle", function(err, rooms) {
                if (err != null) {
                  trace(err);
                  return;
                }
                trace(rooms);
                for (room in rooms) {
                    return FlxG.resetState();
                }
                return FlxG.switchState(new FNFNetMenu("no rooms found"));
            });
        }
    }
    
	function selection(change:Int = 0)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
    
            curSelected += change;
    
            if (curSelected < 0)
                curSelected = shuf.length - 1;
            if (curSelected >= shuf.length)
                curSelected = 0;
            // selector.y = (70 * curSelected) + 30;
            sprDifficulty.animation.play(shuf[curSelected].difficulty.toLowerCase());
            songname.text = "\n"+shuf[curSelected].song + "\n";
            songname.size = 48-shuf[curSelected].song.length;
            var bullShit:Int = 0;
    
    
            for (item in fuck.members)
            {
                item.targetY = bullShit - curSelected;
                bullShit++;
    
                item.alpha = 0.6;
                // item.setGraphicSize(Std.int(item.width * 0.8));
    
                if (item.targetY == 0)
                {
                    item.alpha = 1;
                    // item.setGraphicSize(Std.int(item.width));
                }
            }
        }
}