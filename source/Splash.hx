package;

import funkin.objects.video.FunkinVideo;
import flixel.FlxState;

using StringTools;

@:access(flixel.FlxGame)
@:access(Main)
class Splash extends FlxState
{
	public static var nextState:Class<FlxState>;
	var video:FunkinVideo;
	var _cachedAutoPause:Bool;

	var spriteEvents:FlxTimer;
	var logo:FlxSprite;

	override function create()
	{
		_cachedAutoPause = FlxG.autoPause;
		FlxG.autoPause = false;

		FlxTimer.wait(1, () -> {
			logo = new FlxSprite().loadGraphic(Paths.image('branding/Weekly'));
			logo.screenCenter();
			logo.visible = false;
			add(logo);

			spriteEvents = new FlxTimer().start(1, (t0:FlxTimer) -> {
				new FlxTimer().start(0.25, (t1:FlxTimer) -> {
					logo.visible = true;
					logo.scale.set(0.2, 1.25);
					new FlxTimer().start(0.06125, (t2:FlxTimer) -> {
						logo.scale.set(1.25, 0.5);
						new FlxTimer().start(0.06125, (t3:FlxTimer) -> {
							logo.scale.set(1.125, 1.125);
							FlxTween.tween(logo.scale, {x: 1, y: 1}, 0.25,
								{
									ease: FlxEase.elasticOut,
									onComplete: (t:FlxTween) -> {
										new FlxTimer().start(1, (t5:FlxTimer) -> {
											FlxTween.tween(logo.scale, {x: 0.2, y: 0.2}, 1, {ease: FlxEase.quadIn});
											FlxTween.tween(logo, {alpha: 0}, 1,
												{
													ease: FlxEase.quadIn,
													onComplete: (t:FlxTween) -> {
														finish();
													}
												});
										});
									}
								});
						});
					});
				});
			});
		});
	}

	override function update(elapsed:Float)
	{
		if (logo != null)
		{
			logo.updateHitbox();
			logo.screenCenter();

			if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER)
			{
				onComplete();

				if (spriteEvents != null)
				{
					spriteEvents.cancel();
					spriteEvents.destroy();
				}
			}
		}

		super.update(elapsed);
	}

	function finish()
	{
		if (spriteEvents != null)
		{
			spriteEvents.cancel();
			spriteEvents.destroy();
		}
		new FlxTimer().start(1, function(tmr:FlxTimer){
			video = new FunkinVideo();
			video.onEndReached.add(onComplete,true);
			video.load(Paths.video('intro'));
			video.play();
		});
	}

	function onComplete():Void
	{
		if (video != null)
		{
			video.dispose();
		}
		FlxG.autoPause = _cachedAutoPause;
		FlxG.switchState(() -> Type.createInstance(nextState, []));
	}
}
