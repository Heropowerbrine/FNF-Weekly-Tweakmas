import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import funkin.data.Conductor;
import funkin.objects.shader.ColorSwap;

import openfl.Lib;
import funkin.utils.WindowUtil;

var wolfBG:FlxSprite;
var sam:FlxSprite;

var flowerSky:FlxSprite;
var flowerBG:FlxSprite;
var flowerFG:FlxSprite;
var flowerOverlay:FlxSprite;

var colorBG:FlxSprite;
var igor:Character;
var stchroma:Character;

var branding:FlxTypeText;
var flowerBrand:FlxText;
var chromakopia:FlxSprite;

var igorShader:ColorSwap = new ColorSwap();
igorShader.saturation = -1;
igorShader.daAlpha = 0;

function onLoad(){
    wolfBG = new FlxSprite().loadGraphic(Paths.image('tyler/wolf'));
    wolfBG.setGraphicSize(1280);
    wolfBG.updateHitbox();
    wolfBG.screenCenter();
    add(wolfBG);

    sam = new FlxSprite();
    sam.frames = Paths.getSparrowAtlas('tyler/sam');
    sam.animation.addByPrefix('idle', 'sam', 4, true);
    sam.animation.play('idle');
    sam.screenCenter(FlxAxes.X);
    sam.x += 1280 / 4;
    sam.y = 960 / 4;
    sam.alpha = 0.6;
    add(sam);

    flowerSky = new FlxSprite().loadGraphic(Paths.image('tyler/flowerSky'));
    flowerSky.scale.set(1.25, 1.25);
    flowerSky.updateHitbox();
    flowerSky.screenCenter();
    flowerSky.visible = false;
    flowerSky.y -= 350;
    add(flowerSky);

    colorBG = new FlxSprite().makeGraphic(1280, 960, FlxColor.WHITE);
    colorBG.color = 0xFFF7B4C6;
    colorBG.y += 121 - 600;
    colorBG.alpha = 0;
    add(colorBG);

    igor = new Character(0, -600, 'igor');
    igor.screenCenter(FlxAxes.X);
    igor.x += (FlxG.width / 4) - 25;
    igor.y += 360;
    igor.shader = igorShader.shader;
    add(igor);

    flowerBG = new FlxSprite().loadGraphic(Paths.image('tyler/flowerBack'));
    flowerBG.scale.set(1.25, 1.25);
    flowerBG.updateHitbox();
    flowerBG.screenCenter();
    flowerBG.visible = false;
    add(flowerBG);

    flowerFG = new FlxSprite().loadGraphic(Paths.image('tyler/flowerFront'));
    flowerFG.scale.set(1.325, 1.325);
    flowerFG.updateHitbox();
    flowerFG.screenCenter();
    flowerFG.y += 190;
    flowerFG.scrollFactor.set(1.25, 1.25);
    flowerFG.visible = false;
    flowerFG.zIndex = 2;
    add(flowerFG);

    flowerOverlay = new FlxSprite().loadGraphic(Paths.image('tyler/flower overlay'));
    flowerOverlay.camera = game.camHUD;
    flowerOverlay.scale.set(1.25, 1.25);
    flowerOverlay.updateHitbox();
    add(flowerOverlay);

    chromakopia = new FlxSprite().loadGraphic(Paths.image('tyler/Chromakopia'));
    chromakopia.screenCenter(FlxAxes.X);
    chromakopia.y -= 350;
    chromakopia.y -= 315;
    add(chromakopia);

    stchroma = new Character(0,-600, 'stchroma');
    stchroma.screenCenter(FlxAxes.X);
    stchroma.x += (FlxG.width / 4) - 25;
    stchroma.y += 550;
    stchroma.y += stchroma.height;
    stchroma.alpha = 0;
    add(stchroma);
}

function onCreatePost(){
    // remove(game.dadGroup);
    // remove(game.gfGroup);

    FlxG.scaleMode.width = 1280;    
    FlxG.scaleMode.height = 960;    
    FlxG.camera.height = 960;
    game.camHUD.height = 960;
    game.playHUD.healthBar.screenCenter(FlxAxes.X);
    game.playHUD.scoreTxt.screenCenter(FlxAxes.X);
    game.playHUD.timeBar.screenCenter(FlxAxes.X);
    game.playHUD.timeTxt.screenCenter(FlxAxes.X);
    for (hbox in game._hitbox.hitbox.members) {
	    hbox.scale.y = 960 / hbox.frameHeight;
	    hbox.updateHitbox();
    }

    game.isCameraOnForcedPos = true;
    game.snapCamFollowToPos(1280 / 2, 960 / 2);
    game.playHUD.visible = false;
    game.basegameHoldHandling = true;
    game.boyfriendGroup.screenCenter();
    game.gfGroup.remove(game.gf);
    game.dadGroup.remove(game.dad);
    game.opponentStrums.owner = game.boyfriend;

    game.boyfriendGroup.zIndex = 1;
    game.refreshZ(game.stage);

    wolfBG.screenCenter();

    flowerOverlay.screenCenter();
    flowerOverlay.y += 12.5;
    flowerOverlay.x = 1280;

    var modManager = game.modManager;
    modManager.setValue("opponentSwap", 0.5);
    modManager.setValue("alpha", 1, 1);

    branding = new FlxTypeText(0, 0, 999, "ALL SONGS WRITTEN, PRODUCED, AND ARRANGED BY TYLER OKONMA");
    branding.setFormat(Paths.font('tyler.otf'), 32, FlxColor.BLACK, FlxTextAlign.CENTER);
    branding.visible = false;
    // branding.camera = game.camHUD;
    branding.screenCenter(FlxAxes.X);
    branding.y = 1025 - 600;
    add(branding);

    flowerBrand = new FlxText();
    flowerBrand.setFormat(Paths.font('flower boy.ttf'), 32, 0xFFDF968D, FlxTextAlign.CENTER, 
    FlxTextBorderStyle.SHADOW, 0x6B000000, 3);
    flowerBrand.text = 'ALL SONGS WRITTEN AND\nPRODUCED BY TYLER OKONMA';
    flowerBrand.camera = game.camHUD;
    flowerBrand.screenCenter(FlxAxes.X);
    flowerBrand.y = FlxG.height;
    flowerBrand.alpha = 0;
    add(flowerBrand);

    game.addCharacterToList('flower', 0);
    flowerTransition(632);
    igorTransition(1152 + 48);
    chromakopiaTransition1(1984);
    chromakopiaTransition2(2018);

    game.setGameOverVideo('didyouseeit');
}

function onSpawnNotePost(note){
    if(!note.mustPress) note.noAnimation = true;
}

function flowerTransition(step){
    var stepSize = Conductor.stepCrotchet / 1000;

    modManager.queueFuncOnce(step, (s,s2)->{
        FlxTween.tween(flowerOverlay, {x: (FlxG.width - flowerOverlay.width) / 2 }, stepSize * 8, {ease: FlxEase.quartIn, onComplete: ()->{
            game.triggerEventNote('Change Character', 'bf', 'flower');
            game.snapCamFollowToPos(game.getCharacterCameraPos(game.boyfriend).x, game.getCharacterCameraPos(game.boyfriend).y);
            
            game.isCameraOnForcedPos = false;
            game.camZooming = true;
            FlxTween.num(1.6, 1.75, stepSize * 4, {ease: FlxEase.quartOut, onUpdate: (t)->{
                FlxG.camera.zoom = t.value;
                game.defaultCamZoom = t.value;
            }});

            wolfBG.visible = false;
            flowerSky.visible = true;
            flowerBG.visible = true;
            flowerFG.visible = true;
            FlxTween.tween(flowerOverlay, {x: -flowerOverlay.width}, stepSize * 8, {ease: FlxEase.quartOut, onComplete: ()->{
                FlxTween.tween(flowerBrand, {alpha: 1, y: flowerBrand.y - 125}, stepSize * 8, {ease: FlxEase.quadOut});
            }});

            
        }});
    });
}

function igorText(){
    flowerSky.visible = false;
    branding.visible = true;
    branding.start();
}

function igorTransition(step){
    var stepSize = Conductor.stepCrotchet / 1000;

    modManager.queueFuncOnce(step - 48, (s,s2)->{
        game.isCameraOnForcedPos = true;
        game.playerStrums.owner = igor;

        FlxTween.num(game.camFollow.y, -120, stepSize * (64 + 32), {ease: FlxEase.quadInOut, onUpdate: (t)->{
            game.camFollow.y = t.value;
            game.camFollowPos.y = t.value;
        }});
        FlxTween.num(game.camFollow.x, 1280 / 2, stepSize * (64 + 32), {ease: FlxEase.quadInOut, onUpdate: (t)->{
            game.camFollow.x = t.value;
            game.camFollowPos.x = t.value;
        }});

        FlxTween.num(1.75, 1, stepSize * 128, {ease: FlxEase.quadInOut, onUpdate: (t)->{
            game.defaultCamZoom = t.value;
        }, onComplete: igorText});

        FlxTween.tween(colorBG, {alpha: 1}, stepSize * (64 + 32));
        FlxTween.tween(flowerBG, {alpha: 0}, stepSize * (64 + 32), {startDelay: stepSize * 32});
        for(fuck in [game.boyfriend, flowerBrand, flowerFG]){ FlxTween.tween(fuck, {alpha: 0}, stepSize * 64, {startDelay: (Conductor.stepCrotchet / 1000) * 32}); }

        FlxTween.num(igorShader.saturation, 0, 6, {startDelay: stepSize * 128, ease: FlxEase.quadInOut, onUpdate: (fuck)->{ igorShader.saturation = fuck.value; }});
        FlxTween.num(igorShader.daAlpha, 1, stepSize * 32, {ease: FlxEase.quadInOut, onUpdate: (fuck)->{ igorShader.daAlpha = fuck.value; }});
        // FlxTween.tween(igor, {y: 200}, stepSize * 24, {ease: FlxEase.quartOut});
    });
}

function chromakopiaTransition1(step){
    game.modManager.queueFuncOnce(step, (s,s2)->{
        FlxTween.color(colorBG, (Conductor.stepCrotchet / 1000) * 32, 0xFFF7B4C6, 0xFF00853C);
        FlxTween.tween(igor, {alpha: 0}, (Conductor.stepCrotchet / 1000) * 32);    
    });
}

function chromakopiaTransition2(step){
    game.modManager.queueFuncOnce(step, (s,s2)->{
        game.playerStrums.owner = stchroma;
        FlxTween.tween(stchroma, {y: (stchroma.y - stchroma.height) + 50, alpha: 1}, (Conductor.stepCrotchet / 1000) * 16, {ease: FlxEase.quintOut});
        FlxTween.tween(chromakopia, {y: chromakopia.y + 200}, (Conductor.stepCrotchet / 1000) * 16, {ease: FlxEase.quintOut});
        FlxTween.tween(branding, {y: (chromakopia.y + 175) + chromakopia.height + 20}, (Conductor.stepCrotchet / 1000) * 16, {ease: FlxEase.quintOut});
    });
}
