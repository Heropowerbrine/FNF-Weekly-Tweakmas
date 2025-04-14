import funkin.data.Conductor;
import openfl.filters.ShaderFilter;
import openfl.Lib;
import funkin.utils.WindowUtil;
import funkin.objects.shader.BloomShaderB;

var mosaic = newShader('mosaic');
var bloom = new BloomShaderB();
bloom.dim.value = [2];
bloom.Size.value = [0];

var iconRobot2:HealthIcon;

var speakers:FlxSprite;
var robot1:FlxSprite;
var robot2:FlxSprite;

var skipCutscene:Bool = false;
var fuckyes:Bool = false;
var modcharted:Bool = true;

var strength = skipCutscene ? 1 : 32;
var mosaicMult = -1;
var flashBeat = 8;

if(ClientPrefs.shadersEnabled){
    var shaders = [];
    if(ClientPrefs.flashing) shaders.push(new ShaderFilter(bloom));
    shaders.push(new ShaderFilter(mosaic));
    
    FlxG.camera.setFilters(shaders);
    game.camHUD.setFilters([new ShaderFilter(mosaic)]);    
}


function onLoad(){
    var bg = new FlxSprite().loadGraphic(Paths.image('Daftpunk/background'));
    bg.screenCenter();
    add(bg);   

    var ceiling = new FlxSprite().loadGraphic(Paths.image('DaftPunk/Cellingshit'));
    ceiling.screenCenter(FlxAxes.X);
    ceiling.y -= 250;
    add(ceiling);

    var dsotm = new FlxSprite().loadGraphic(Paths.image('DaftPunk/Pyramid'));
    dsotm.screenCenter(FlxAxes.X);
    dsotm.y -= 75;
    add(dsotm);

    var floor = new FlxSprite().loadGraphic(Paths.image('Daftpunk/Floor'));
    // floor.scale.set(1.5, 1.5);
    // floor.updateHitbox();
    // floor.screenCenter(FlxAxes.X);
    floor.y += 625;
    floor.x -= 37.5;
    add(floor);   

    var flash = new FlxSprite(200, -200).loadGraphic(Paths.image('Daftpunk/flash'));
    flash.angle = 45;
    flash.blend = BlendMode.ADD;
    add(flash);

    var originalPosition = FlxPoint.get(-200, -200);
    FlxTween.tween(flash, {angle: -45, x: originalPosition.x - 225, y: originalPosition.y + 100}, 3, {ease: FlxEase.quadInOut, type: 4});

    var flash = new FlxSprite(605, -250).loadGraphic(Paths.image('Daftpunk/flash'));
    flash.angle = -45;
    flash.blend = BlendMode.ADD;
    add(flash);

    var originalPosition = FlxPoint.get(975, -200);
    FlxTween.tween(flash, {angle: 45, x: originalPosition.x + 225, y: originalPosition.y + 100}, 3, {ease: FlxEase.quadInOut, type: 4});

    speakers = new FlxSprite();
    speakers.frames = Paths.getSparrowAtlas('Daftpunk/Speakers');
    speakers.animation.addByPrefix('bump', 'Speakers', 24, false);
    speakers.animation.play('bump');
    speakers.screenCenter();
    speakers.y += 125;
    add(speakers);

    robot1 = new FlxSprite();
    robot1.frames = Paths.getSparrowAtlas('Daftpunk/DaftPunk');
    robot1.animation.addByPrefix('bump', 'IdleLeft', 24, false);
    robot1.animation.play('bump');
    // robot1.screenCenter();
    robot1.x += 300;
    robot1.y += 225;
    add(robot1);

    robot2 = new FlxSprite();
    robot2.frames = Paths.getSparrowAtlas('Daftpunk/DaftPunk');
    robot2.animation.addByPrefix('bump', 'IdleRight', 24, false);
    robot2.animation.play('bump');
    // robot1.screenCenter();
    robot2.x += 600;
    robot2.y += 45;
    add(robot2);

    var spotlights = new FlxSprite().loadGraphic(Paths.image('Daftpunk/SpotlightsFInal'));
    spotlights.screenCenter();
    spotlights.y += 400;
    spotlights.zIndex = 999;
    add(spotlights);
}

function onBeatHit(){
    strength += mosaicMult;
    if(strength <= 0) strength = 1;
    mosaic.data.uBlocksize.value = [strength, strength];

    speakers.animation.play('bump', true);
    robot1.animation.play('bump', true);
    robot2.animation.play('bump', true);

    if(game.curBeat % flashBeat == 0){
        var from = fuckyes ? 0.5 : 1;
        var from2 = fuckyes ? 9 : 4;
        FlxTween.num(from, 2, (Conductor.stepCrotchet / 1000) * 8, {onUpdate: (t)->{ bloom.dim.value = [t.value]; }});    
        FlxTween.num(from2, 2, (Conductor.stepCrotchet / 1000) * 8, {onUpdate: (t)->{ bloom.Size.value = [t.value]; }});    
    }
}

function onCreatePost(){
    // FlxG.resizeWindow(960, 720);
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

    game.dad.danceEveryNumBeats = 1;
    game.boyfriend.danceEveryNumBeats = 1;
    game.basegameHoldHandling = true;

    game.dad.forceDance = true;
    game.dad.screenCenter();
    game.dad.y += 75;

    game.boyfriend.forceDance = true;
    game.boyfriend.screenCenter();
    game.boyfriend.y += 250;
    game.boyfriend.x += 10;

    // game.isCameraOnForcedPos = true;
    game.snapCamFollowToPos(1280 / 2, (720 / 2) - 100);
    game.camGame.visible = skipCutscene;

    game.playHUD.showCombo = false;
    game.playHUD.showRating = false;
    game.playHUD.iconP1.flipX = !game.playHUD.iconP1.flipX;

    if(ClientPrefs.downScroll){
        game.playHUD.timeBar.y += 235;
        game.playHUD.timeTxt.y += 235;
        // for(fuck in [game.playHUD.scoreTxt, game.playHUD.healthBar, game.playHUD.iconP1, game.playHUD.iconP2]){ fuck.y += 220; }
    }else{
        for(fuck in [game.playHUD.scoreTxt, game.playHUD.healthBar, game.playHUD.iconP1, game.playHUD.iconP2]){ fuck.y += 220; }
    }
    game.playHUD.healthBar.bg.loadGraphic(Paths.image('Daftpunk/Bar'));
    game.playHUD.healthBar.bg.scale.set(1.0325, 0.85);
    game.playHUD.healthBar.bg.updateHitbox();
    game.playHUD.healthBar.bg.screenCenter(FlxAxes.X);
    game.playHUD.healthBar.bgOffset.x -= 12.5;
    game.playHUD.healthBar.bgOffset.y -= 3;

    game.opponentStrums.cameras = [game.camGame];
    for(m in game.opponentStrums.members){ m.scrollFactor.set(1,1);}

    game.modManager.setValue("opponentSwap", 0.5, 0);
    if(!ClientPrefs.downScroll){
        game.modManager.setValue("reverse", 1, 1);
        game.modManager.setValue("sudden", 0.9, 1);
        game.modManager.setValue("suddenOffset", -0.75, 1);    
    }else
        game.modManager.setValue("stealth", 0.9, 1);

    game.modManager.setValue("transformX", 315, 1);
    game.modManager.setValue("transformY", -425, 1);

    if(PlayState.SONG.song.toLowerCase() == 'all-night' && modcharted) loadModchart(game.modManager);

    for(fuck in [game.playFields, game.notes, game.playHUD]){
        game.remove(fuck);
        game.stage.add(fuck);
    }

    game.playHUD.zIndex = 0;
    game.playFields.zIndex = 1;
    game.notes.zIndex = 1;
    speakers.zIndex = 2;
    robot1.zIndex = 3;
    robot2.zIndex = 3;
    game.dadGroup.zIndex = 4;
    game.boyfriendGroup.zIndex = 5;
    game.refreshZ(game.stage);

    game.modManager.queueFuncOnce(830, (s,s2)->{ flashBeat = 9999; });
    game.modManager.queueFuncOnce(891, (s,s2)->{ fuckyes = true; flashBeat = 4; });
    game.modManager.queueFuncOnce(1216, (s,s2)->{ 
        mosaicMult = 2;

        FlxTween.num(1.1, 1.6, (Conductor.stepCrotchet / 1000) * 48, {ease: FlxEase.quadOut, onUpdate: (t)->{
            FlxG.camera.zoom = t.value;
        }});
        game.camHUD.fade(FlxColor.BLACK, (Conductor.stepCrotchet / 1000) * 48);
     });

    game.setGameOverVideo('burger');
}

function onDestroy(){
    FlxG.scaleMode.height = 720;
}

function onSpawnNotePost(note){
    if(!note.mustPress) {
        note.cameras = [game.camGame];
        note.scrollFactor.set(1,1);
    }
}

function onSongStart(){
    if(!skipCutscene){
        game.camGame.visible = true;
        game.camGame.flash(FlxColor.BLACK, 12);
        FlxTween.num(2, 1.2, 12, {ease: FlxEase.quadOut, onUpdate: (t)->{
            FlxG.camera.zoom = t.value;
        }});
    
        new FlxTimer().start((Conductor.stepCrotchet / 1000) * 124, ()->{
            game.isCameraOnForcedPos = false;
        });
    }
}

var fuck = false;
var counter = 0;
function onSectionHit(){
    counter += 1;
    if(counter % 2 == 0){
        fuck = !fuck;
        game.dad.animSuffix = fuck ? '' : '-alt';

        game.playHUD.iconP2.changeIcon(game.dad.animSuffix == '-alt' ? 'bot2' : 'bot1');
    }

}

// var modManager = game.modManager;
function loadModchart(modManager){
    modManager.queueSet(896, 'beat', 1);
    var counter = -1;
    numericForInterval(896, 1280, 8, (step)->{
        counter *= -1;
        modManager.queueSet(step, "mini", -0.5);
        modManager.queueEase(step, step + 4, "mini", 0, "quintOut");
        modManager.queueSet(step, "drunk", -2 * counter);
        modManager.queueEase(step, step + 4, "drunk", 0, "quintOut");

        modManager.queueSet(step + 4, "mini", -0.5);
        modManager.queueEase(step + 4, step + 8, "mini", 0, "quintOut");
        modManager.queueSet(step + 4, "tipsy", 2 * counter);
        modManager.queueEase(step + 4, step + 8, "tipsy", 0, "quintOut");
        modManager.queueSet(step + 4, "drunk", 2 * counter);
        modManager.queueEase(step + 4, step + 8, "drunk", 0, "quintOut");
    });

    for(s in [896, 928, 992, 1024, 1072, 1120, 1152, 1184, 1216, 1248]){
        modManager.queueSet(s, "centerrotateY", tr(360 * 2));
        modManager.queueEase(s, s+4, "centerrotateY", 0, 'quintOut');
    }
    // modManager.queueSet()
}

function tr(d){ return d * (3.14159265359 / 180); }

function numericForInterval(start, end, interval, func){
    var index = start;
    while(index < end){
        func(index);
        index += interval;
    }
}
