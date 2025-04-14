package funkin.states;

import funkin.utils.DifficultyUtil;
import funkin.states.editors.ChartingState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import funkin.data.WeekData;
import funkin.states.*;
import funkin.states.substates.*;
import funkin.data.*;
import funkin.objects.*;

class FreeplayState extends MusicBeatState
{
	public var debugBG:FlxSprite;
	public var debugTxt:FlxText;

	public var songs:Array<SongMetadata> = [];

	public var selector:FlxText;

	public static var curSelected:Int = 0;

	public var curDifficulty:Int = -1;

	public static var lastDifficultyName:String = '';

	public var scoreBG:FlxSprite;
	public var scoreText:FlxText;
	public var lerpScore:Int = 0;
	public var lerpRating:Float = 0;
	public var intendedScore:Int = 0;
	public var intendedRating:Float = 0;

	public var grpSongs:FlxTypedGroup<Alphabet>;
	public var curPlaying:Bool = false;

	public var iconArray:Array<HealthIcon> = [];

	public var bg:FlxSprite;
	public var intendedColor:Int;

	var weekBG:FlxSprite;
	var weekText:FlxText;
	private static var curWeek:Int = 0;
	var loadedWeeks:Array<WeekData> = [];

	var leftButton:FlxSprite;
	var rightButton:FlxSprite;


	override function create()
	{
		Paths.clearStoredMemory();
		// Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var leSongs:Array<String> = [];
		var leChars:Array<String> = [];

		for (j in 0...leWeek.songs.length)
		{
			leSongs.push(leWeek.songs[j][0]);
			leChars.push(leWeek.songs[j][1]);
		}

		WeekData.setDirectoryFromWeek(leWeek);
		for (song in leWeek.songs)
		{
			var colors:Array<Int> = song[2];
			if(colors == null || colors.length < 3)
			{
				colors = [146, 113, 253];
			}
			addSong(song[0], 0, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
		}

		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			loadedWeeks.push(weekFile);
			WeekData.setDirectoryFromWeek(weekFile);
		}
		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		WeekData.loadTheFirstEnabledMod();

		setUpScript('FreeplayState');
		setOnScript('SongMetadata', SongMetadata);
		setOnScript('WeekData', WeekData);
		setOnScript('songs', songs);
		setOnScript('persistentUpdate', persistentUpdate);

		if (isHardcodedState())
		{
			bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			add(bg);
			bg.screenCenter();

			grpSongs = new FlxTypedGroup<Alphabet>();
			add(grpSongs);

			for (i in 0...songs.length)
			{
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
				songText.isMenuItem = true;
				songText.centeredMenuItem = true;
				songText.targetY = i;
				grpSongs.add(songText);

				if (songText.width > 980)
				{
					var textScale:Float = 980 / songText.width;
					songText.scale.x = textScale;
					for (letter in songText.lettersArray)
					{
						letter.x *= textScale;
						letter.offset.x *= textScale;
					}
					// songText.updateHitbox();
					// trace(songs[i].songName + ' new scale: ' + textScale);
				}

				Paths.currentModDirectory = songs[i].folder;
				var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
				icon.sprTracker = songText;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
			WeekData.setDirectoryFromWeek();

			scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
			scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

			scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 42, 0xFF000000);
			scoreBG.alpha = 0.6;
			add(scoreBG);

			weekText = new FlxText(5, 30, 0, "", 32);
			weekText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			weekText.borderSize = 2;

			weekBG = new FlxSprite(-1, 25).makeGraphic(1, 42, 0xFF000000);
			weekBG.alpha = 0.6;
			add(weekBG);
			add(weekText);

			add(scoreText);

			if (curSelected >= songs.length) curSelected = 0;
			bg.color = songs[curSelected].color;
			intendedColor = bg.color;

			if (lastDifficultyName == '')
			{
				lastDifficultyName = DifficultyUtil.defaultDifficulty;
			}
			curDifficulty = Math.round(Math.max(0, DifficultyUtil.defaultDifficulties.indexOf(lastDifficultyName)));

			var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
			textBG.alpha = 0.6;
			add(textBG);

			#if PRELOAD_ALL
			var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
			var size:Int = 16;
			#else
			var leText:String = "Press C to open the Gameplay Changers Menu / Press X to Reset your Score and Accuracy.";
			var size:Int = 18;
			#end
			var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
			text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
			text.scrollFactor.set();
			add(text);

			debugBG = new FlxSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			debugBG.alpha = 0;
			add(debugBG);

			debugTxt = new FlxText(50, 0, FlxG.width - 100, '', 36);
			debugTxt.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
			debugTxt.screenCenter(Y);
			add(debugTxt);

			weekBG = new FlxSprite(-1, 25).makeGraphic(1, 42, 0xFF000000);
			weekBG.alpha = 0.6;
			add(weekBG);

			leftButton = new FlxSprite();
			leftButton.frames = Paths.getSparrowAtlas("mainmenu/button_left");
			leftButton.animation.addByPrefix("idle", "left0", 10, true);
			leftButton.animation.addByPrefix("hover", "left hover0", 10, true);
			leftButton.animation.play("idle");
			leftButton.screenCenter(Y);
			add(leftButton);
	
			rightButton = new FlxSprite();
			rightButton.frames = Paths.getSparrowAtlas("mainmenu/button_right");
			rightButton.animation.addByPrefix("idle", "right0", 10, true);
			rightButton.animation.addByPrefix("hover", "right hover0", 10, true);
			rightButton.animation.play("idle");
			rightButton.screenCenter(Y);
			rightButton.x = FlxG.width - rightButton.width;
			add(rightButton);

			changeSelection();
			changeDiff();
		}
		#if mobile
		addVirtualPad(FULL,A_B_C_X);
		#end
		super.create();
		callOnScript('onCreatePost', []);
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
		#if mobile
		removeVirtualPad();
                addVirtualPad(FULL,A_B_C_X);
		#end
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
		{
			if (songCharacters == null)
				songCharacters = ['bf'];

			var num:Int = 0;
			for (song in songs)
			{
				addSong(song, weekNum, songCharacters[num]);
				this.songs[this.songs.length-1].color = weekColor;

				if (songCharacters.length != 1)
					num++;
			}
	}*/
	var instPlaying:Int = -1;

	private static var vocals:FlxSound = null;

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (isHardcodedState())
		{	
			weekText.text = 'TWEAKMAS ${curWeek + 1}';

			lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
			lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));

			if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
			if (Math.abs(lerpRating - intendedRating) <= 0.01) lerpRating = intendedRating;

			var ratingSplit:Array<String> = Std.string(funkin.utils.MathUtil.floorDecimal(lerpRating * 100, 2)).split('.');
			if (ratingSplit.length < 2)
			{ // No decimals, add an empty space
				ratingSplit.push('');
			}

			while (ratingSplit[1].length < 2)
			{ // Less than 2 decimals in it, add decimals then
				ratingSplit[1] += '0';
			}

			scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
			positionHighscore();

			var shiftMult:Int = 1;
			if (FlxG.keys.pressed.SHIFT) shiftMult = 3;

			if (songs.length > 1)
			{
				var leftP = controls.UI_LEFT_P #if mobile || _virtualpad.buttonLeft.justPressed #end;
				var rightP = controls.UI_RIGHT_P #if mobile || _virtualpad.buttonRight.justPressed #end;
		
				if (controls.UI_UP_P #if mobile || _virtualpad.buttonUp.justPressed #end)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_DOWN_P #if mobile || _virtualpad.buttonDown.justPressed #end)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}
				if(rightP){
					rightButton.animation.play("hover");
					new FlxTimer().start(0.125, (tmr)->{
						rightButton.animation.play("idle");
					});
					changeWeek(1);
				}
				if(leftP){
					leftButton.animation.play("hover");
					new FlxTimer().start(0.125, (tmr)->{
						leftButton.animation.play("idle");
					});
					changeWeek(-1);
				}

				if (controls.UI_DOWN || controls.UI_UP #if mobile || _virtualpad.buttonDown.pressed || _virtualpad.buttonUp.pressed #end)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP #if mobile || _virtualpad.buttonUp.justPressed #end ? -shiftMult : shiftMult));
						changeDiff();
					}
				}
			}

			if (controls.UI_LEFT_P) changeDiff(-1);
			else if (controls.UI_RIGHT_P) changeDiff(1);
			else if (controls.UI_UP_P || controls.UI_DOWN_P) changeDiff();

			if (controls.BACK #if mobile || _virtualpad.buttonB.justPressed #end)
			{
				persistentUpdate = false;
				FlxTween.cancelTweensOf(bg, ['color']);

				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new WeeklyMainMenuState());
			}

			if (FlxG.keys.justPressed.CONTROL #if mobile || _virtualpad.buttonC.justPressed #end)
			{
				persistentUpdate = false;
				#if mobile
			        removeVirtualPad();
			        #end
				openSubState(new GameplayChangersSubstate());
			}
			else if (FlxG.keys.justPressed.SPACE)
			{
				if (instPlaying != curSelected)
				{
					// #if PRELOAD_ALL
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
					Paths.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					if (PlayState.SONG.needsVoices) vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					else vocals = new FlxSound();

					FlxG.sound.list.add(vocals);
					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
					vocals.play();
					vocals.persist = true;
					vocals.looped = true;
					vocals.volume = 0.7;
					instPlaying = curSelected;
					// #end
				}
			}
			else if (controls.ACCEPT #if mobile || _virtualpad.buttonA.justPressed #end)
			{
				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

				try
				{
					PlayState.SONG = Song.loadFromJson(poop, songLowercase);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;
				}
				catch (e)
				{
					var message = 'Failed to load song: [$poop]\ndoes the chart exist?';
					debugBG.alpha = 0.7;
					debugTxt.text = message;
					debugTxt.screenCenter(Y);

					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(FlxG.elapsed);
					return;
				}

				FlxTween.cancelTweensOf(bg, ['color']);

				if (FlxG.keys.pressed.SHIFT)
				{
					LoadingState.loadAndSwitchState(new ChartingState());
				}
				else
				{
					LoadingState.loadAndSwitchState(new PlayState());
				}

				FlxG.sound.music.volume = 0;

				destroyFreeplayVocals();
			}
			else if (controls.RESET #if mobile || _virtualpad.buttonX.justPressed #end)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		super.update(elapsed);
	}

	function changeWeek(change:Int = 0){
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;	

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		loadWeekSongs(leWeek);
	}

	function loadWeekSongs(week:WeekData){
		curSelected = 0;
		songs = [];
		grpSongs.clear();
		if(iconArray.length > 0){
			for(icon in iconArray){
				icon.destroy();
			}
		}
		iconArray = [];

		for (song in week.songs)
		{
			var colors:Array<Int> = song[2];
			if(colors == null || colors.length < 3)
			{
				colors = [146, 113, 253];
			}
			addSong(song[0], curWeek, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
		}


		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.centeredMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
			}

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			insert(members.indexOf(grpSongs) + 1, icon);

			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}
		WeekData.setDirectoryFromWeek();

		changeSelection(0, false);
	}

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		debugBG.alpha = 0;
		debugTxt.text = '';

		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, DifficultyUtil.difficulties.length - 1);

		lastDifficultyName = DifficultyUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (isHardcodedState())
		{
			debugBG.alpha = 0;
			debugTxt.text = '';

			if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

			curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);

			var newColor:Int = songs[curSelected].color;
			if (newColor != intendedColor)
			{
				FlxTween.cancelTweensOf(bg, ['color']);
				intendedColor = newColor;
				FlxTween.color(bg, 1, bg.color, intendedColor);
			}

			#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
			#end

			var bullShit:Int = 0;

			for (i in 0...iconArray.length)
			{
				iconArray[i].alpha = 0.6;
			}

			iconArray[curSelected].alpha = 1;

			for (item in grpSongs.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;

				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}

			Paths.currentModDirectory = songs[curSelected].folder;
			PlayState.storyWeek = songs[curSelected].week;

			DifficultyUtil.reset();

			var diffStr:String = WeekData.getCurrentWeek().difficulties;
			if (diffStr != null) diffStr = diffStr.trim(); // Fuck you HTML5

			if (diffStr != null && diffStr.length > 0)
			{
				var diffs:Array<String> = diffStr.split(',');
				var i:Int = diffs.length - 1;
				while (i > 0)
				{
					if (diffs[i] != null)
					{
						diffs[i] = diffs[i].trim();
						if (diffs[i].length < 1) diffs.remove(diffs[i]);
					}
					--i;
				}

				if (diffs.length > 0 && diffs[0].length > 0)
				{
					DifficultyUtil.difficulties = diffs;
				}
			}

			if (DifficultyUtil.difficulties.contains(DifficultyUtil.defaultDifficulty))
			{
				curDifficulty = Math.round(Math.max(0, DifficultyUtil.defaultDifficulties.indexOf(DifficultyUtil.defaultDifficulty)));
			}
			else
			{
				curDifficulty = 0;
			}

			var newPos:Int = DifficultyUtil.difficulties.indexOf(lastDifficultyName);
			if (newPos > -1)
			{
				curDifficulty = newPos;
			}
		}
	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if (this.folder == null) this.folder = '';
	}
}
