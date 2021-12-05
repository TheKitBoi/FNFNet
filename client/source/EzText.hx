package;

import flixel.util.FlxColor;
import flixel.text.FlxText;

class EzText extends FlxText
{
    public function new(x:Float = 0, y:Float = 0, text:String = "", size:Int = 8, bordersize:Int = 1, color:FlxColor = FlxColor.WHITE){
        super(x, y, 0, text);
        scrollFactor.set();
		setFormat(Paths.font('vcr.ttf'), size, color);
		updateHitbox();
		setBorderStyle(OUTLINE, FlxColor.BLACK, bordersize); //300 modifier btw
		antialiasing = true;
    }
    override function update(elapsed:Float){
        super.update(elapsed);
    }
}