package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			#if fnfnet "HEY! You're running an outdated version of Friday Night Funkin' Network!\nFNFNet will not work until you update.\n\nPress space to open the mod page.\n\nPress ESC to continue anyway without Multiplayer.", 
			#else "HEY! You're running an outdated version of TrollEngine!\n\nPress space to open the mod page.\n\nPress ESC to continue anyway without FNFNet.", 
			#end
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			leftState = true;
			#if linux
			Sys.command('/usr/bin/xdg-open', ["https://gamebanana.com/mods/307671", "&"]);
			#else
			FlxG.openURL('https://gamebanana.com/mods/307671');
			#end
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
