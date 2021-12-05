package;

import haxe.Json;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
using StringTools;
class FourChan extends MusicBeatState
{
    var htmlFilter:EReg = ~/(<([^>]+)>)/gi;

    var posts:FlxTypedGroup<EzText>;
    var postbg:FlxTypedGroup<FlxSprite>;
    override function create(){
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);
        posts = new FlxTypedGroup<EzText>();
        postbg = new FlxTypedGroup<FlxSprite>();
        add(postbg);
        add(posts);
        var post = Json.parse(sys.io.File.getContent('./ass'));
        var ass:String = "\n";
        //posts.add(new EzText(50, 100 + (i * 60), "\n", 24, 2)); //com.htmlUnescape().replace("<br>", "\n")
        posts.add(new EzText(50, 100, "\n" + post.posts[0].com, 24, 2)); //com.htmlUnescape().replace("<br>", "\n")
        var ass:EzText = new EzText();
        var dna:Array<Dynamic> = post.posts;
        for(i in 0...post.posts.length){
            var com:String = post.posts[i].com.htmlUnescape().replace("<br>", "\n");
            com = htmlFilter.replace(com, "");
            var posttext = new EzText(50, posts.members[i].y + ((posts.members[i].text.split('\n').length + 1) * 25), com, 24, 2);
            var bgs = new FlxSprite(25, posts.members[i].y + ((posts.members[i].text.split('\n').length + 1) * 25)).makeGraphic(400, posttext.text.split("\n").length * 100);
            postbg.add(bgs);
            posts.add(posttext); //com.htmlUnescape().replace("<br>", "\n")
        }
        posts.add(new EzText(50, 50, ass + '\n', 24, 2));
    }

    override function update(elapsed:Float){
        if(controls.UP){
            postbg.forEach((spr:FlxSprite)->{
                spr.y += 4;
            });
            posts.forEach((spr:EzText)->{
                spr.y += 4;
            });
        }
        if(controls.DOWN){
            postbg.forEach((spr:FlxSprite)->{
                spr.y -= 4;
            });
            posts.forEach((spr:EzText)->{
                spr.y -= 4;
            });
        }
    }
}