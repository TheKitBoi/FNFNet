package online;

import haxe.Json;
import haxe.Http;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxInputText;
import flixel.FlxSprite;

class Login extends MusicBeatState
{
    var userbar:FlxInputText;
    var passbar:FlxInputText;
    var ui:FlxTypedGroup<FlxSprite>;
    var buttons = ['login', 'register'];
    var errtext:EzText;
    var control:Bool = true;
    var rq:Http;
    var curselected:Int = 0;
    override function create()
    {
        FlxG.mouse.visible = true;
        var bg = new FlxSprite().loadGraphic(Paths.image("menuBG"));
        bg.antialiasing = true;

        var logo = new FlxSprite(0, 100).loadGraphic(Paths.image("loginogo"));
        logo.antialiasing = true;
        logo.screenCenter(X);

        userbar = new FlxInputText(0, 400, 200, "", 20);
        userbar.screenCenter(X);

        passbar = new FlxInputText(0, 450, 200, "", 20);
        passbar.passwordMode = true;
        passbar.screenCenter(X);

        ui = new FlxTypedGroup<FlxSprite>();

        for(i in 0...buttons.length){
            var button = new FlxSprite();
            button.frames = Paths.getSparrowAtlas("login");
            button.screenCenter(XY);
            button.y += 250; 
            button.x = 200 + (i * 500);
            button.ID = i;
            button.animation.addByPrefix("idle", buttons[i] + " unselected");
            button.animation.addByPrefix("selected", buttons[i] + " selected");
            button.animation.play("idle");
            ui.add(button);
        }

        add(bg);
        add(logo);
        add(userbar);
        add(passbar);
        errtext = new EzText(0, 335, "", 30, 1, FlxColor.RED);
        errtext.screenCenter(X);
        add(errtext);
        add(new EzText(userbar.x - 150, userbar.y, "Username:", 24, 1));
        add(new EzText(passbar.x - 150, passbar.y, "Password:", 24, 1));

        add(ui);
        super.create();
    }

    override function update(elapsed:Float)
    {
        errtext.screenCenter(X);
        ui.forEach((spr:FlxSprite)->{
            if(spr.ID == curselected) spr.animation.play("selected");
            else spr.animation.play("idle");
        });
        if(FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new MainMenuState());
        if(FlxG.keys.justPressed.LEFT) change(-1);
        if(FlxG.keys.justPressed.RIGHT) change(1);
        if(FlxG.keys.justPressed.ENTER){
            if(!control) return;
            switch(curselected){
                case 0:
                    login();
                case 1:
                    FlxG.openURL("http://"+Config.data.addr+":"+Config.data.port+"/register.html");
                    
            }
        }
        super.update(elapsed);
    }

    function change(bruh:Int){
        if(!control) return;
        FlxG.sound.play(Paths.sound('scrollMenu'));
        curselected += bruh;
        if(curselected >= buttons.length) curselected -= 1;
        if(curselected < 0) curselected = buttons.length - 1;
    }
    
    function login(){
        control = false;
        var request = new haxe.http.HttpRequest();
        request.method = "POST";
        request.url = new haxe.http.Url("http://"+Config.data.addr+":"+Config.data.port+"/login/");
        request.headers.set("Content-Type", "application/json");
        request.data = '{"username":"'+userbar.text+'", "password":"'+passbar.text+'", "action": "accinfo", "value": 0}';
        request.send({
          onData: function (data : String) {
            control = true; 
                var accdata = Json.parse(data);
                if(accdata.banned == 1){
                     errtext.text = "Your account has been banned.";
                     return;
                }
                errtext.text = "Welcome, "+accdata.username;
                errtext.color = FlxColor.GREEN;
                FlxG.save.data.username = accdata.username;
                FlxG.save.data.password = passbar.text;
                FlxG.save.data.loggedin = true;
                FlxG.save.flush();
                FlxG.switchState(new MainMenuState());
          },
          onError: function (error : String, ?data : String) {
              trace(error);
              control = true;
              errtext.text = Json.parse(data).message;
          },
          onStatus: function (code : Int) {
              trace("Status " + code);
          }
        });
    }
}