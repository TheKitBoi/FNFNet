package;

import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.util.FlxSave;
import Controls.KeyboardScheme;
class OptionsMenu extends MusicBeatState
{
	public static var notice:FlxText;
	public static var resolution:FlxText;
	public static var fullscreen:FlxText;
	public static var curFPS:FlxText;
	public static var downscroll:FlxText;
	public static var ks:FlxText;
	public static var rn:Int;
	public static var cDat:Int;
	public static var kbd:String;
	var curVars:Array<String> = [];
	var cockJoke = new FlxTypedGroup<FlxText>();
	var tabtext = new FlxTypedGroup<FlxText>();
	var selector:FlxText;
	var curSelected:Int = 0;
	var curtab:Int = 0;
	var bar:FlxSprite;
	var dababe:FlxText;
	var valueDescriptor:FlxText;
	var controlsStrings:Array<String> = [];
	var cockjoke:Int = FlxG.updateFramerate;
	var settings:Map<String, String>;
	private var grpControls:FlxTypedGroup<Alphabet>;

	override function create()
	{
		FlxG.camera.zoom = 0.7;
		settings = new Map<String, String>();
		if(FlxG.save.data.pgbar == null) FlxG.save.data.pgbar = false;
		switch(FlxG.save.data.ks){
			case null:
				kbd = "WASD";
			case "WASD":
				kbd = "WASD";
			case "DFJK":
				kbd = "DFJK";
		}
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		controlsStrings = [
			"< category >",
			"Framerate", 
			"Pause on Unfocus", 
			"Fullscreen", 
			"Downscroll", 
			"Middle Scroll",
			"Keyboard Scheme", 
			"Scripts",
			#if !js "Stage Tester", #end 
			"Kade Input", 
			"Progress Bar", 
			"Instant Restart",
			"Inst Volume",
			"Vocal Volume",
			"Reset Settings",
			"Load Custom Assets",
			"Logout",
			"Login"
		];// nop3CoolUtil.coolTextFile(Paths.txt('controls'));
		var controlsDesc = [
			"Change the category using left/right arrow keys.",
			"Change your framerate ingame.", 
			"Pause when you aren't focusing on the game.", 
			"If the game should run on fullscreen.", 
			"Downscrolling for arrows.", 
			"Middle scrolling for arrows.",
			"Choose between WASD or DFJK.",
			"Scripts that you can run.", 
			#if !js "A easy test tool to port stages and characters.", #end
			"Activate input similar to Kade Engine.",
			"A progression bar in-game to see how far you are in a song.",
			"If you should restart when you die.",
			"How loud instrumental should be.",
			"How loud vocals should be.",
			"Reset all your settings.",
			"Choose if the game should load custom stages/characters.",
			"Logout of your account.",
			"Login into your account."
		];

		for(i in 0...controlsStrings.length){
			settings.set(controlsStrings[i], controlsDesc[i]);
		}


		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.6), Std.int(menuBG.height * 1.6));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		notice = new FlxText(20, FlxG.height * 0.83, 0, "", 32);
		notice.text = "Use the left and arrow keys to change this option!";
		notice.alpha = 0;
		notice.scrollFactor.set();
		notice.setFormat(Paths.font('vcr.ttf'), 48);
		notice.updateHitbox();
		notice.screenCenter(X);
		notice.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
		notice.antialiasing = true;
		add(notice);

			grpControls = new FlxTypedGroup<Alphabet>();
			add(grpControls);

			for (i in 0...controlsStrings.length)
			{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false, 0.48, 70, false);
				//controlLabel.setGraphicSize(Std.int(controlLabel.width / 1.6), Std.int(controlLabel.height / 1.6));
				controlLabel.x += 700;
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			}
		 
			dababe = new FlxText(-250, 760, settings.get(controlsStrings[curSelected]), 32);
			dababe.scrollFactor.set();
			dababe.setFormat(Paths.font('vcr.ttf'), 48);
			dababe.updateHitbox();
			dababe.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
			dababe.antialiasing = true;
			add(dababe);

			valueDescriptor = new FlxText(-250, 500, curVars[0], 32);
			valueDescriptor.scrollFactor.set();
			valueDescriptor.setFormat(Paths.font('vcr.ttf'), 54);
			valueDescriptor.updateHitbox();
			valueDescriptor.setBorderStyle(OUTLINE, FlxColor.BLACK, 5);
			valueDescriptor.antialiasing = true;
			add(valueDescriptor);
		bar = new FlxSprite(-250, -50).makeGraphic(75, 10, FlxColor.BLACK);

		tabtext = new FlxTypedGroup<FlxText>();
		var tabbies = ['Gen', 'Game', 'SFX', 'Data'];
		for (i in 0...tabbies.length){
			var fuck = new FlxText(-250 + (100 * i), bar.y - 40, tabbies[i], 32);
			fuck.scrollFactor.set();
			fuck.setFormat(Paths.font('vcr.ttf'), 32);
			fuck.updateHitbox();
			fuck.ID = i;
			fuck.setBorderStyle(OUTLINE, FlxColor.BLACK, 5);
			fuck.antialiasing = true;
			tabtext.add(fuck);
		}
		changeTab();
		add(tabtext);
		super.create();

		//openSubState(new OptionsSubState());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		curVars = [
			"",
			Std.string(FlxG.save.data.framerate),
			Std.string(FlxG.autoPause), 
			Std.string(FlxG.fullscreen), 
			Std.string(FlxG.save.data.downscroll), 
			Std.string(FlxG.save.data.midscroll),
			kbd, 
			"",
			#if !js "",#end
			Std.string(FlxG.save.data.kadeinput),
			Std.string(FlxG.save.data.pgbar), 
			Std.string(FlxG.save.data.instres),
			""+FlxG.save.data.instvolume,
			""+FlxG.save.data.vocalsvolume,
			"",
			""+FlxG.save.data.loadass,
			"",
			""
		];
			switch(grpControls.members[curSelected].text){
				case "< category >":
					if(controls.RIGHT_P) 
						changeTab(1);
					if(controls.LEFT_P) 
						changeTab(-1);
				case "Framerate":
					if(controls.RIGHT_P) {
						if(FlxG.drawFramerate < 300){
							FlxG.drawFramerate = FlxG.updateFramerate += 10; 

							FlxG.save.data.framerate = FlxG.drawFramerate;
							FlxG.save.flush();
							initSettings(false, 0, ""+FlxG.drawFramerate);
						}
					}
					if(controls.LEFT_P) {
						if(FlxG.drawFramerate > 20) {
							FlxG.drawFramerate = FlxG.updateFramerate -= 10;
							FlxG.save.data.framerate = FlxG.drawFramerate;
							FlxG.save.flush();
							initSettings(false, 0, "" + FlxG.drawFramerate);
						}
					}
				case "Inst Volume":
					if(FlxG.save.data.instvolume > -2 && FlxG.save.data.instvolume < 102){
						if(controls.RIGHT) {
							FlxG.save.data.instvolume += 2;
							if(FlxG.save.data.instvolume == -2) FlxG.save.data.instvolume = 0;
							if(FlxG.save.data.instvolume == 102) FlxG.save.data.instvolume = 100;
							FlxG.save.flush();
							initSettings(false, 0, ""+FlxG.save.data.instvolume);
						}
						if(controls.LEFT) {
								FlxG.save.data.instvolume -= 2;
								if(FlxG.save.data.instvolume == -2) FlxG.save.data.instvolume = 0;
								if(FlxG.save.data.instvolume == 102) FlxG.save.data.instvolume = 100;
								FlxG.save.flush();
								initSettings(false, 0, "" + FlxG.save.data.instvolume);
						}
					}		
				case "Vocal Volume":
					if(FlxG.save.data.vocalsvolume > -2 && FlxG.save.data.vocalsvolume < 102){
						if(controls.RIGHT) {
							FlxG.save.data.vocalsvolume += 2;
							if(FlxG.save.data.vocalsvolume == -2) FlxG.save.data.vocalsvolume = 0;
							if(FlxG.save.data.vocalsvolume == 102) FlxG.save.data.vocalsvolume = 100;
							FlxG.save.flush();
							initSettings(false, 0, ""+FlxG.save.data.vocalsvolume);
						}
						if(controls.LEFT) {
								FlxG.save.data.vocalsvolume -= 2;
								if(FlxG.save.data.vocalsvolume == -2) FlxG.save.data.vocalsvolume = 0;
								if(FlxG.save.data.vocalsvolume == 102) FlxG.save.data.vocalsvolume = 100;
								FlxG.save.flush();
								initSettings(false, 0, "" + FlxG.save.data.vocalsvolume);
						}
					}					
			}
			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				switch(grpControls.members[curSelected].text){
					case "Framerate":
						{
						FlxTween.tween(notice, {alpha: 1}, 1, {
							ease: FlxEase.quartInOut, 
							onComplete: function(twn:FlxTween)
								{
									new FlxTimer().start(2, function(timer:FlxTimer){
										if (timer.finished) {
											FlxTween.tween(notice, {alpha: 0}, 1, {ease: FlxEase.quartInOut});
										}
									});
								}
						});
					}
					case "Pause on Unfocus":
						FlxG.autoPause = !FlxG.autoPause;
						FlxG.save.data.pauseonunfocus = FlxG.autoPause;
						FlxG.save.flush();
						initSettings(false, 1, ""+FlxG.autoPause);
					case "Fullscreen":
						if(controls.ACCEPT) {
							FlxG.fullscreen = !FlxG.fullscreen;
							FlxG.save.data.fullscreen = FlxG.fullscreen;
							FlxG.save.flush();
							initSettings(false, 2, ""+FlxG.fullscreen);
						}
					case "Downscroll":
						PlayState.downscroll = !PlayState.downscroll;
						FlxG.save.data.downscroll = PlayState.downscroll;
						FlxG.save.flush();
						initSettings(false, 3, ""+PlayState.downscroll);
					case "Middle Scroll":
						FlxG.save.data.midscroll = !FlxG.save.data.midscroll;
						FlxG.save.flush();
						initSettings(false, 4, ""+FlxG.save.data.midscroll);
					case "Keyboard Scheme":
						if(kbd == "WASD"){
							kbd = "DFJK";
							controls.setKeyboardScheme(KeyboardScheme.Custom, true);
							FlxG.save.data.ks = "DFJK";
							FlxG.save.flush();
							initSettings(false, 4, kbd);
						}else{
							kbd = "WASD";
							controls.setKeyboardScheme(KeyboardScheme.Solo, true);
							FlxG.save.data.ks = "WASD";
							FlxG.save.flush();
							initSettings(false, 4, kbd);
						}
					case "Scripts":
						FlxG.switchState(new ScriptState());	
					case "Stage Tester":	
						#if !js LoadingState.loadAndSwitchState(new test.TestState());	#end

					case "Kade Input":
						if(FlxG.save.data.kadeinput != null)FlxG.save.data.kadeinput = !FlxG.save.data.kadeinput;
						else FlxG.save.data.kadeinput = true;
						FlxG.save.flush();
						initSettings(false, 5, FlxG.save.data.kadeinput);
					case "Reset Settings":
						Config.initsave(true);
					case "Progress Bar":
						FlxG.save.data.pgbar = !FlxG.save.data.pgbar;
						FlxG.save.flush();
						initSettings(false, 6, FlxG.save.data.pgbar);
					case "Instant Restart":
						FlxG.save.data.instres = !FlxG.save.data.instres;
						FlxG.save.flush();
						initSettings(false, 7, FlxG.save.data.instres);
					case "Load Custom Assets":
						FlxG.save.data.loadass = !FlxG.save.data.loadass;
						FlxG.save.flush();
						initSettings(false, 7, FlxG.save.data.loadass);	
					case "Logout":
						Config.logout();
						FlxG.switchState(new MainMenuState());
					case "Login":
						FlxG.switchState(new online.Login());
					case "big chungus":
						var request = new haxe.Http("https://fnf.general-infinity.tech/thing.php");
						request.setPostData("no=no");
						request.request(true);
						FlxG.openURL('https://fnf.general-infinity.tech/thefunny.php');	
				}
			}
			if (isSettingControl)
				waitingInput();
			else
			{
				if (controls.BACK){
					FlxG.save.flush();
					FlxG.switchState(new MainMenuState());
				}
				if (controls.UP_P)
					changeSelection(-1);
				if (controls.DOWN_P)
					changeSelection(1);
				if (FlxG.keys.justPressed.N)
					changeTab(1);
			}
		 
	}
	function initSettings(noreset, ?thingit, ?text):Void
		{
			var iv = ""+FlxG.save.data.instvolume;
			var vv = ""+FlxG.save.data.vocalsvolume;
			valueDescriptor.text = text;
		}
	function waitingInput():Void
	{
		if (FlxG.keys.getIsDown().length > 0)
		{
			PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxG.keys.getIsDown()[0].ID, null);
		}
		// PlayerSettings.player1.controls.replaceBinding(Control)
	}

	var isSettingControl:Bool = false;

	function changeBinding():Void
	{
		if (!isSettingControl)
		{
			isSettingControl = true;
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;
		trace(settings.get(grpControls.members[curSelected].text));
		dababe.text = settings.get(grpControls.members[curSelected].text);
		valueDescriptor.text = curVars[controlsStrings.indexOf(grpControls.members[curSelected].text)];
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
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
	function changeTab(change = 0){
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curtab += change;

		if (curtab < 0)
			curtab = tabtext.length - 1;
		if (curtab >= tabtext.length)
			curtab = 0;
		curSelected = 0;
		var bullShit:Int = 0;
		controlChange();
		for (item in tabtext.members)
		{
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.ID == curtab)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
	function controlChange(){
		
		var acctab = switch(FlxG.save.data.loggedin){
			case true:
				'Logout';
			case false:
				'Login';
		}
		var chungus = switch(curtab){
			case 0:
			[
				'< category >',
				'Framerate',
				'Pause on Unfocus',
				'Fullscreen'
			];
			case 1:
				[
					'< category >',
					'Load Custom Assets',
					'Downscroll',
					'Middle Scroll',
					'Keyboard Scheme',
					'Kade Input',
					'Instant Restart'
				];
			case 2:
				[
					'< category >',
					'Inst Volume',
				'Vocal Volume'];
			case 3: 
				[
					'< category >',
					'Scripts',
					#if !js 'Stage Tester',#end
					'Reset Settings',
					acctab
				];
			case _:
				['shit doesnt work'];
		}
		remove(grpControls);
		grpControls.clear();
		grpControls = new FlxTypedGroup<Alphabet>();

		for (i in 0...chungus.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, chungus[i], true, false, 0.48, 70, false);
			//controlLabel.setGraphicSize(Std.int(controlLabel.width / 1.6), Std.int(controlLabel.height / 1.6));
			controlLabel.x += 700;
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}
		changeSelection();
		add(grpControls);
	}
}
