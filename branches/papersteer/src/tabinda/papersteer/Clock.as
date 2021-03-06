﻿// ----------------------------------------------------------------------------
//
// PaperSteer - Papervision3D Port of OpenSteer
// Port by Mohammad Haseeb aka M.H.A.Q.S.
// http://www.tabinda.net
//
// OpenSteer -- Steering Behaviors for Autonomous Characters
//
// Copyright (c) 2002-2003, Sony Computer Entertainment America
// Original author: Craig Reynolds <craig_reynolds@playstation.sony.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//
// ----------------------------------------------------------------------------

package tabinda.papersteer
{
	import flash.utils.getTimer;
	
	public class Clock
	{		
		// run as fast as possible, simulation time is based on real time
		private var variableFrameRateMode:Boolean;

		// fixed frame rate (ignored when in variable frame rate mode) in
		// real-time mode this is a "target", in animation mode it is absolute
		private var fixedFrameRate:int;

		// used for offline, non-real-time applications
		private var animationMode:Boolean;

		// is simulation running or paused?
		private var paused:Boolean;
		
		// clock keeps track of "smoothed" running average of recent frame rates.
		// When a fixed frame rate is used, a running average of "CPU load" is
		// kept (aka "non-wait time", the percentage of each frame time (time
		// step) that the CPU is busy).
		private var smoothedFPS:Number;
		private var smoothedUsage:Number;
		
		// clock state member variables and public accessors for them

		// real "wall clock" time since launch
		private var totalRealTime:Number;

		// total time simulation has run
		private var totalSimulationTime:Number;

		// total time spent paused
		private var totalPausedTime:Number;

		// sum of (non-realtime driven) advances to simulation time
		private var totalAdvanceTime:Number;

		// interval since last simulation time
		// (xxx does this need to be stored in the instance? xxx)
		private var elapsedSimulationTime:Number;

		// interval since last clock update time 
		// (xxx does this need to be stored in the instance? xxx)
		private var elapsedRealTime:Number;

		// interval since last clock update,
		// exclusive of time spent waiting for frame boundary when targetFPS>0
		private var elapsedNonWaitRealTime:Number;
		
		// "manually" advance clock by this amount on next update
		private var newAdvanceTime:Number;
		
		private var instance:Number;

		// constructor
		public function Clock()
		{
			// calendar time when this clock was first started
			instance = getTimer() + 0.0;
			
			// default is "real time, variable frame rate" and not paused
			FixedFrameRate = 0;
			PausedState = false;
			AnimationMode = false;
			VariableFrameRateMode = true;

			// real "wall clock" time since launch
			totalRealTime = 0.0;

			// time simulation has run
			totalSimulationTime = 0.0;

			// time spent paused
			totalPausedTime = 0.0;

			// sum of (non-realtime driven) advances to simulation time
			totalAdvanceTime = 0.0;

			// interval since last simulation time 
			elapsedSimulationTime = 0.0;

			// interval since last clock update time 
			elapsedRealTime = 0.0;

			// interval since last clock update,
			// exclusive of time spent waiting for frame boundary when targetFPS>0
			elapsedNonWaitRealTime = 0.0;

			// "manually" advance clock by this amount on next update
			newAdvanceTime =0.0;
			
			// clock keeps track of "smoothed" running average of recent frame rates.
			// When a fixed frame rate is used, a running average of "CPU load" is
			// kept (aka "non-wait time", the percentage of each frame time (time
			// step) that the CPU is busy).
			smoothedFPS = 0.0;
			smoothedUsage = 0.0;
		}

		// update this clock, called exactly once per simulation step ("frame")
		public function Update():void
		{
			//instance = (getTimer() - instance);
			// keep track of average frame rate and average usage percentage
			UpdateSmoothedRegisters();

			// wait for next frame time (when targetFPS>0)
			// XXX should this be at the end of the update function?
			FrameRateSync();

			// save previous real time to measure elapsed time
			var previousRealTime:Number = totalRealTime;

			// real "wall clock" time since this application was launched
			totalRealTime = RealTimeSinceFirstClockUpdate();

			// time since last clock update
			elapsedRealTime = (totalRealTime - previousRealTime);

			// accumulate paused time
			if (paused)
			{
				totalPausedTime += elapsedRealTime;
			}

			// save previous simulation time to measure elapsed time
			var previousSimulationTime:Number = totalSimulationTime;

			// update total simulation time
			if (AnimationMode)
			{
				// for "animation mode" use fixed frame time, ignore real time
				var frameDuration:Number = 1.0 / FixedFrameRate;
				totalSimulationTime += paused ? newAdvanceTime : frameDuration;
				if (!paused)
				{
					newAdvanceTime += (frameDuration - elapsedRealTime);
				}
			}
			else
			{
				// new simulation time is total run time minus time spent paused
				totalSimulationTime = (totalRealTime + totalAdvanceTime - totalPausedTime);
			}

			// update total "manual advance" time
			totalAdvanceTime += newAdvanceTime;

			// how much time has elapsed since the last simulation step?
			if (paused)
			{
				elapsedSimulationTime = newAdvanceTime;
			}
			else
			{
				elapsedSimulationTime = (totalSimulationTime - previousSimulationTime);
			}

			// reset advance amount
			newAdvanceTime = 0.0;
		}

		// returns the number of seconds of real time (represented as a float)
		// since the clock was first updated.
		public function RealTimeSinceFirstClockUpdate():Number
		{
			if (instance == 0)
			{
				instance = getTimer()/1000;
			}
			return (getTimer() - instance)/1000;
		}

		// force simulation time ahead, ignoring passage of real time.
		// Used for OpenSteerDemo's "single step forward" and animation mode
		private function AdvanceSimulationTimeOneFrame():Number
		{
			// decide on what frame time is (use fixed rate, average for variable rate)
			var fps:Number = (VariableFrameRateMode ? SmoothedFPS : FixedFrameRate);
			var frameTime:Number = 1.0 / fps;

			// bump advance time
			AdvanceSimulationTime(frameTime);

			// return the time value used (for OpenSteerDemo)
			return frameTime;
		}

		private function AdvanceSimulationTime(seconds:Number):void
		{
			if (seconds < 0)
				throw new ArgumentError("Negative argument to advanceSimulationTime." + " seconds");
			else
				newAdvanceTime += seconds;
		}

		// "wait" until next frame time
		private function FrameRateSync():void
		{
			// when in real time fixed frame rate mode
			// (not animation mode and not variable frame rate mode)
			if ((!AnimationMode) && (!VariableFrameRateMode))
			{
				// find next (real time) frame start time
				var targetStepSize:Number = 1.0 / FixedFrameRate;
				var now:Number = RealTimeSinceFirstClockUpdate();
				var lastFrameCount:int = int((now / targetStepSize));
				var nextFrameTime:Number = (lastFrameCount + 1.0) * targetStepSize;

				// record usage ("busy time", "non-wait time") for OpenSteerDemo app
				elapsedNonWaitRealTime = now - totalRealTime;

				//FIXME: eek.
				// wait until next frame time
				do { } while (RealTimeSinceFirstClockUpdate() < nextFrameTime);
			}
		}
		
		private function UpdateSmoothedRegisters():void
		{
			var rate:Number = SmoothingRate;
			if (elapsedRealTime > 0)
			{
					smoothedFPS = Utilities.BlendIntoAccumulator(rate, Number((1 / elapsedRealTime)),smoothedFPS);
			}
			if (!VariableFrameRateMode)
			{
					smoothedUsage = Utilities.BlendIntoAccumulator(rate, Usage, smoothedUsage);
			}
		}
		
		public function TogglePausedState():Boolean	{ return (paused = !paused); }

		// run time per frame over target frame time (as a percentage)
		public function get Usage():Number { return ((60 * elapsedNonWaitRealTime) / (1.0 / fixedFrameRate)); }
		public function get FixedFrameRate():int { return fixedFrameRate;	}
		public function set FixedFrameRate(val:int):void { fixedFrameRate = val; }
		public function get AnimationMode():Boolean { return animationMode; }
		public function set AnimationMode(val:Boolean):void { animationMode = val; }
		public function get VariableFrameRateMode():Boolean { return variableFrameRateMode; }		
		public function set VariableFrameRateMode(val:Boolean):void { variableFrameRateMode = val; }
		public function get PausedState():Boolean{return paused;}	
		public function set PausedState(val:Boolean):void { paused = val; }
		public function get SmoothedFPS():Number { return smoothedFPS; }
		public function get SmoothedUsage():Number { return smoothedUsage; }
		public function get SmoothingRate():Number { return smoothedFPS == 0.0 ? 1.0 : elapsedRealTime * 1.5; }
		public function get TotalRealTime():Number { return totalRealTime; }
		public function get TotalSimulationTime():Number { return totalSimulationTime; }
		public function get TotalPausedTime():Number { return totalPausedTime; }
		public function get TotalAdvanceTime():Number { return totalAdvanceTime; }
		public function get ElapsedSimulationTime():Number { return elapsedSimulationTime; }
		public function get ElapsedRealTime():Number { return elapsedRealTime; }
		public function get ElapsedNonWaitRealTime():Number { return elapsedNonWaitRealTime; }
	}
}
