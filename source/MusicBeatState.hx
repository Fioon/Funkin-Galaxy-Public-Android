package;

import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import flixel.FlxCamera;
#if android
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public static var camBeat:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	#if android
        var _virtualpad:FlxVirtualPad;
        var androidc:AndroidControls;
        var trackedinputsUI:Array<FlxActionInput> = [];
        var trackedinputsNOTES:Array<FlxActionInput> = [];
        #end

        #if android
        public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
                _virtualpad = new FlxVirtualPad(DPad, Action, 0.75, ClientPrefs.globalAntialiasing);
                add(_virtualpad);
                controls.setVirtualPadUI(_virtualpad, DPad, Action);
                trackedinputsUI = controls.trackedinputsUI;
                controls.trackedinputsUI = [];
        }
        #end

        #if android
        public function removeVirtualPad() {
                controls.removeFlxInput(trackedinputsUI);
                remove(_virtualpad);
        }
        #end
        
        #if android
        public function addAndroidControls() {
                androidc = new AndroidControls();

                switch (androidc.mode)
                {
                        case VIRTUALPAD_RIGHT | VIRTUALPAD_LEFT | VIRTUALPAD_CUSTOM:
                                controls.setVirtualPadNOTES(androidc.vpad, FULL, NONE);
                        case DUO:
                                controls.setVirtualPadNOTES(androidc.vpad, DUO, NONE);
                        case HITBOX:
                           if(ClientPrefs.hitboxmode != 'New'){
                                controls.setHitBox(androidc.hbox);
                                }else{
                                controls.setNewHitBox(androidc.newhbox);
                                }
                        default:
                }

                trackedinputsNOTES = controls.trackedinputsNOTES;
                controls.trackedinputsNOTES = [];

                var camcontrol = new flixel.FlxCamera();
                FlxG.cameras.add(camcontrol, false);
                camcontrol.bgColor.alpha = 0;
                androidc.cameras = [camcontrol];

                androidc.visible = false;

                add(androidc);
        }
        #end

        #if android
        public function addPadCamera() {
                var camcontrol = new flixel.FlxCamera();
                camcontrol.bgColor.alpha = 0;
                FlxG.cameras.add(camcontrol, false);
                _virtualpad.cameras = [camcontrol];
        }
        #end

        override function destroy() {
                #if android
                controls.removeFlxInput(trackedinputsNOTES);
                controls.removeFlxInput(trackedinputsUI);
                #end

                super.destroy();
	}
	
	override function create() {
		Paths.clearUnusedMemory();
		camBeat = FlxG.camera;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		if(!skip) {
			openSubState(new CustomFadeTransition(0.4, true));
		}
		FlxTransitionableState.skipNextTransOut = false;

		if (stickerSubState != null) {
			persistentUpdate = true;
			persistentDraw = true;
			openSubState(stickerSubState);
			stickerSubState.degenStickers();
			stickerSubState.closeCallback = function()
			{
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				stickerSubState = null;
			}
		}
		Paths.clearUnusedMemory();
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.sections.length)
		{
			if (PlayState.SONG.sections[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState, ?instance:FlxState) {
		// Custom made Trans in
		var leState = instance != null ? instance : getState();
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.3, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}
	
	public var stickerSubState:StickerSubState;

	public static function switchStateStickers(nextState:FlxState)
	{
		var leState = getState();
		if (leState.subState != null)
			leState.subState.close();
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		leState.openSubState(new StickerSubState(null, function (sticker:StickerSubState) {
			var j:MusicBeatState = cast nextState;
			j.stickerSubState = sticker;
			FlxG.switchState(nextState);
		  }));
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var leState:Dynamic = FlxG.state;
		 //doesnt work well for some reasons so disabled until i know how to fix it
		/*if (leState.subState != null)
			leState = leState.subState;
		//yes substates can have substates themselves
		if (leState.subState != null)
			leState = leState.subState;*/
		return cast leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.sections[curSection] != null) val = PlayState.SONG.sections[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
