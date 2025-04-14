import flixel.text.FlxText;

var FILE_PREFIX:String = 'persona/dialogue/';

// im not putting this in a json sorry
var dialogue:Array<Array<String>> = [
    // [character, expression, text]
    ["joker", "0", "So Futaba, what did Sojiro get you today?"],
    ["futaba", "2", "Sojiro? You mean Santa, right?"],
    ["joker", "1", "...oh."],
    ["futaba", "1", "Be for realz, Joker! Who do you think delivers the presents?\nEats the cookies? Drinks the milk? Mwehehehe!!"],
    ["futaba", "0", "These phenomena only have one real answer and you know it."],
    ["joker", "1", "You can't be serious... Listen, Santa isn't--"],
    ["futaba", "0", "Nope! Don't even try it! Not listeniiiing!"],
    ["joker", "2", "Oh boy..."]
];
var dialogueIndex:Int = -1;
var prevChar:Null<String> = null;
var isDialogueFinished:Bool = false;

var bg:FlxSprite;
var portrait:FlxSprite;
var bubble:FlxSprite;
var text:FlxText;
var bgm:FlxSound;

function onCreate()
{
    bg = new FlxSprite(0, 0).makeGraphic(FlxG.width + 2, FlxG.height + 2, FlxColor.BLACK);
    bg.alpha = 0.5;
    bg.cameras = [game.camOther];
    add(bg);

    portrait = new FlxSprite(50, 330);
    portrait.cameras = [game.camOther];
    portrait.antialiasing = ClientPrefs.globalAntialiasing;
    add(portrait);

    bubble = new FlxSprite(130, 410);
    bubble.cameras = [game.camOther];
    bubble.antialiasing = ClientPrefs.globalAntialiasing;
    add(bubble);

    text = new FlxText(bubble.x + 310, bubble.y + 160).setFormat(Paths.font('Arsenal-Bold.ttf'), 22, FlxColor.WHITE, "left");
    text.cameras = [game.camOther];
    text.antialiasing = ClientPrefs.globalAntialiasing;
    add(text);

    bgm = new FlxSound().loadEmbedded(Paths.music('personaloop'), true);
    FlxG.sound.list.add(bgm);
    bgm.volume = 0;
    bgm.play();
    bgm.fadeIn();
}

function doStartCountdown() { return Function_Stop; }

function presongCutscene() 
{
    if (!isDialogueFinished) {
        nextDialogue();
        return Function_Stop;
    }
}

function onUpdatePost()
{
    var justTouched:Bool = false;
 		for (touch in FlxG.touches.list)
 			if (touch.justPressed)
 				justTouched = true;
    if (FlxG.keys.justPressed.ENTER || justTouched && !isDialogueFinished) 
    {
        FlxG.sound.play(Paths.sound('personasfx'));
        nextDialogue();
    }
}

function nextDialogue()
{
    dialogueIndex += 1;
    if (dialogueIndex > dialogue.length - 1) {
        endDialogue();
        return;
    }

    var curDialogue:Array<String> = dialogue[dialogueIndex];

    // portraits
    portrait.loadGraphic(Paths.image(FILE_PREFIX + curDialogue[0] + curDialogue[1]));
    portrait.setGraphicSize(portrait.width * 1.2, portrait.height * 1.2);

    // bubble
    if (prevChar != curDialogue[0]) {
        bubble.loadGraphic(Paths.image(FILE_PREFIX + 'dialoguebox_' + curDialogue[0]));
        bubble.setGraphicSize(bubble.width * 0.75, bubble.height * 0.75);
    }

    // text
    text.text = curDialogue[2];

    prevChar = curDialogue[0];
}

function endDialogue()
{
    if (isDialogueFinished) return;

    isDialogueFinished = true;

    bgm.fadeOut();
    killAllObjects();
    game.startCountdown();
}

function killAllObjects()
{
    bg.kill();
    bg.destroy();

    portrait.kill();
    portrait.destroy();

    bubble.kill();
    bubble.destroy();

    text.kill();
    text.destroy();
}
