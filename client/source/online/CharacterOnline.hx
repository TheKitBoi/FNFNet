package online;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxTimer;
import lime.app.Future;
import openfl.display.BitmapData;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import GlobalSettings.songDir as songname;

using StringTools;

typedef Offset =
{
	name:String,
	x:Int,
	y:Int
}

class CharacterOnline extends FlxSprite
{
    public static var tex(default, default):FlxAtlasFrames;
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	var loaded:Bool = false;
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var camPos:{x:Null<Int>, y:Null<Int>} = {x: 0, y: 0};
	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, overide:Bool = false)
	{
		super(x, y);
		var tex:FlxAtlasFrames;
		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = true;
		var characterdecide = switch(character){
			case "gf": 
				"girlfriend";
			case "bf": 
				"boyfriend";
			case _:
				"character";
		}
		if(isPlayer) characterdecide = "boyfriend";
		if(overide) characterdecide = character;
			var md = new haxe.Http('http://'+Config.data.resourceaddr+'/songs/$songname/$characterdecide.json');
			md.onData = function (meta:String) {
				var chardata = haxe.Json.parse(meta);
				x = chardata.character.position.x;
				y = chardata.character.position.y;
				loaded = false;
				var xml = new haxe.Http('http://'+Config.data.resourceaddr+'/songs/$songname/$characterdecide.xml');
				xml.onData = function (data:String) { // end my suffering
					sys.thread.Thread.create(()-> {
						BitmapData.loadFromFile('http://'+Config.data.resourceaddr+'/songs/$songname/$characterdecide.png').then(function(image){
							frames = FlxAtlasFrames.fromSparrow(image, data);
							if(character != "gf"){
								animation.addByPrefix('idle', chardata.animations.idle.prefix, 24, false);
								animation.addByPrefix('singUP', chardata.animations.up.prefix, 24, false);
								animation.addByPrefix('singDOWN', chardata.animations.down.prefix, 24, false);
								animation.addByPrefix('singLEFT', chardata.animations.left.prefix, 24, false);
								animation.addByPrefix('singRIGHT', chardata.animations.right.prefix, 24, false);
								if(character == "bf"){
									animation.addByPrefix('singUPmiss', chardata.animations.upMiss.prefix, 24, false);
									animation.addByPrefix('singDOWNmiss', chardata.animations.downMiss.prefix, 24, false);
									animation.addByPrefix('singLEFTmiss', chardata.animations.leftMiss.prefix, 24, false);
									animation.addByPrefix('singRIGHTmiss', chardata.animations.rightMiss.prefix, 24, false);
	
									addOffset("singUPmiss", chardata.animations.upMiss.offsets.x, chardata.animations.up.offsets.y);
									addOffset("singRIGHTmiss", chardata.animations.rightMiss.offsets.x, chardata.animations.right.offsets.y);
									addOffset("singLEFTmiss", chardata.animations.leftMiss.offsets.x, chardata.animations.left.offsets.y);
									addOffset("singDOWNmiss", chardata.animations.downMiss.offsets.x, chardata.animations.down.offsets.y);
									flipX = chardata.character.flipX;
								}
								addOffset('idle', chardata.animations.idle.offsets.x, chardata.animations.idle.offsets.y);
								addOffset("singUP", chardata.animations.up.offsets.x, chardata.animations.up.offsets.y);
								addOffset("singRIGHT", chardata.animations.right.offsets.x, chardata.animations.right.offsets.y);
								addOffset("singLEFT", chardata.animations.left.offsets.x, chardata.animations.left.offsets.y);
								addOffset("singDOWN", chardata.animations.down.offsets.x, chardata.animations.down.offsets.y);
								loaded = true;
								playAnim('idle');
								if(chardata.character.camera != null){
									camPos.x = chardata.character.camera.x;
									camPos.y = chardata.character.camera.y;
								}
								}else{
									animation.addByIndices('danceLeft', chardata.animations.danceLeft.prefix, chardata.animations.danceLeft.indices, "", 24, false);
									animation.addByIndices('danceRight', chardata.animations.danceRight.prefix, chardata.animations.danceRight.indices, "", 24, false);
									addOffset("danceLeft", chardata.animations.danceLeft.offsets.x, chardata.animations.danceLeft.offsets.y);
									addOffset("danceRight", chardata.animations.danceRight.offsets.x, chardata.animations.danceRight.offsets.y);
									loaded = true;
									playAnim('danceRight');
								}
							dance();
							
							if(chardata.character.size.width != 0) setGraphicSize(chardata.character.size.width, chardata.character.size.height);
							return Future.withValue(image);
						});
					});
				}
				xml.request();
			};
			md.onError = function(err:String){
				if(isPlayer){
					var tex:Any;
					#if charselection
					if(FlxG.save.data.curcharacter == null || !isPlayer) tex = Paths.getSparrowAtlas('BOYFRIEND');
					else tex = Paths.getSparrowAtlas(FlxG.save.data.curcharacter);
					#else
					tex = Paths.getSparrowAtlas('BOYFRIEND');
					#end
					switch(curCharacter){
						case 'bf-christmas':
							var tex = Paths.getSparrowAtlas('christmas/bfChristmas');
							frames = tex;
							animation.addByPrefix('idle', 'BF idle dance', 24, false);
							animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
							animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
							animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
							animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
							animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
							animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
							animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
							animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
							animation.addByPrefix('hey', 'BF HEY', 24, false);
			
							addOffset('idle', -5);
							addOffset("singUP", -29, 27);
							addOffset("singRIGHT", -38, -7);
							addOffset("singLEFT", 12, -6);
							addOffset("singDOWN", -10, -50);
							addOffset("singUPmiss", -29, 27);
							addOffset("singRIGHTmiss", -30, 21);
							addOffset("singLEFTmiss", 12, 24);
							addOffset("singDOWNmiss", -11, -19);
							addOffset("hey", 7, 4);
							loaded=true;
							playAnim('idle');
			
							//flipX = true;
						case 'bf-car':
							var tex = Paths.getSparrowAtlas('bfCar');
							frames = tex;
							animation.addByPrefix('idle', 'BF idle dance', 24, false);
							animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
							animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
							animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
							animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
							animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
							animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
							animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
							animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
			
							addOffset('idle', -5);
							addOffset("singUP", -29, 27);
							addOffset("singRIGHT", -38, -7);
							addOffset("singLEFT", 12, -6);
							addOffset("singDOWN", -10, -50);
							addOffset("singUPmiss", -29, 27);
							addOffset("singRIGHTmiss", -30, 21);
							addOffset("singLEFTmiss", 12, 24);
							addOffset("singDOWNmiss", -11, -19);
							loaded=true;
							playAnim('idle');
			
							//flipX = true;
						case 'bf-pixel':
							frames = Paths.getSparrowAtlas('weeb/bfPixel');
							animation.addByPrefix('idle', 'BF IDLE', 24, false);
							animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
							animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
							animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
							animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
							animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
							animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
							animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
							animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);
			
							addOffset('idle');
							addOffset("singUP");
							addOffset("singRIGHT");
							addOffset("singLEFT");
							addOffset("singDOWN");
							addOffset("singUPmiss");
							addOffset("singRIGHTmiss");
							addOffset("singLEFTmiss");
							addOffset("singDOWNmiss");
			
							setGraphicSize(Std.int(width * 6));
							updateHitbox();
							loaded=true;
							playAnim('idle');
			
							width -= 100;
							height -= 100;
			
							antialiasing = false;
			
							//flipX = true;
						case 'bf-pixel-dead':
							frames = Paths.getSparrowAtlas('weeb/bfPixelsDEAD');
							animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
							animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
							animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
							animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
							animation.play('firstDeath');
			
							addOffset('firstDeath');
							addOffset('deathLoop', -37);
							addOffset('deathConfirm', -37);
							playAnim('firstDeath');
							// pixel bullshit
							setGraphicSize(Std.int(width * 6));
							updateHitbox();
							antialiasing = false;
							//flipX = true;
						case _:
							frames = tex;
							animation.addByPrefix('idle', 'BF idle dance', 24, false);
							animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
							animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
							animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
							animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
							animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
							animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
							animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
							animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
							animation.addByPrefix('hey', 'BF HEY', 24, false);
			
							animation.addByPrefix('firstDeath', "BF dies", 24, false);
							animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
							animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
							animation.addByPrefix('scared', 'BF idle shaking', 24);
							animation.addByPrefix('dodge', "boyfriend dodge", 24, false);
							animation.addByPrefix('charge', "bf pre attack", 24, false);
							animation.addByPrefix('hit', "BF hit", 24, true);
							animation.addByPrefix('dodge', "boyfriend dodge", 24, false);
							animation.addByPrefix('attack', 'boyfriend attack', 24, false);
			
							
							addOffset('idle', -5);
							addOffset("singUP", -29, 27);
							addOffset("singRIGHT", -38, -7);
							addOffset("singLEFT", 12, -6);
							addOffset("singDOWN", -10, -50);
							addOffset("singUPmiss", -29, 27);
							addOffset("singRIGHTmiss", -30, 21);
							addOffset("singLEFTmiss", 12, 24);
							addOffset("singDOWNmiss", -11, -19);
							addOffset("hey", 7, 4);
							addOffset('firstDeath', 37, 11);
							addOffset('deathLoop', 37, 5);
							addOffset('deathConfirm', 37, 69);
							addOffset('scared', -4);
							loaded=true;
							playAnim('idle');
					}
					curCharacter = "bf";
			}else switch(character){
					case 'gf':
						tex = Paths.getSparrowAtlas('GF_assets');
						frames = tex;
						animation.addByPrefix('cheer', 'GF Cheer', 24, false);
						animation.addByPrefix('singLEFT', 'GF left note', 24, false);
						animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
						animation.addByPrefix('singUP', 'GF Up Note', 24, false);
						animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
						animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
						animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
						animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
						animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
						animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
						animation.addByPrefix('scared', 'GF FEAR', 24);
		
						addOffset('cheer');
						addOffset('sad', -2, -2);
						addOffset('danceLeft', 0, -9);
						addOffset('danceRight', 0, -9);
		
						addOffset("singUP", 0, 4);
						addOffset("singRIGHT", 0, -20);
						addOffset("singLEFT", 0, -19);
						addOffset("singDOWN", 0, -20);
						addOffset('hairBlow', 45, -8);
						addOffset('hairFall', 0, -9);
		
						addOffset('scared', -2, -17);
		
						loaded=true;
						playAnim('danceRight');
						
						new FlxTimer().start(2, (tmr:FlxTimer)->{loaded=true;});
					case _: 
						tex = Paths.getSparrowAtlas('DADDY_DEAREST');
						frames = tex;
						animation.addByPrefix('idle', 'Dad idle dance', 24);
						animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
						animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
						animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
						animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

						addOffset('idle');
						addOffset("singUP", -6, 50);
						addOffset("singRIGHT", 0, 27);
						addOffset("singLEFT", -10, 10);
						addOffset("singDOWN", 0, -30);
						loaded=true;
						playAnim('idle');
						dance();
						new FlxTimer().start(2, (tmr:FlxTimer)->{loaded=true;});
				}
			}
			md.request();
	}

	override function update(elapsed:Float)
	{
		if(loaded){
			if (!curCharacter.startsWith('bf'))
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				var dadVar:Float = 4;

				if (curCharacter == 'dad')
					dadVar = 6.1;
				if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
				{
					dance();
					holdTimer = 0;
				}
			}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-christmas':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-car':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if(loaded){
			animation.play(AnimName, Force, Reversed, Frame);

			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);

			if (curCharacter == 'gf')
			{
				if (AnimName == 'singLEFT')
				{
					danced = true;
				}
				else if (AnimName == 'singRIGHT')
				{
					danced = false;
				}

				if (AnimName == 'singUP' || AnimName == 'singDOWN')
				{
					danced = !danced;
				}
			}
		}
	}
	public function isthisnull(val:Null<Int>):Bool
	{
		return val==null;
	}
	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
