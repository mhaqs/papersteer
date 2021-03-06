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

package tabinda.demo.plugins.MultiplePursuit
{
	import tabinda.papersteer.*;
	
	public class MpWanderer extends MpBase
	{
		// constructor
		public function MpWanderer ()
		{
			Reset ();
		}

		// reset state
		public override  function Reset ():void
		{
			super.Reset ();
			bodyColor=Colors.RGBToHex(int(255.0 * 0.4),int(255.0 * 0.6),int(255.0 * 0.4));// greenish
		}

		// one simulation step
		public function Update (currentTime:Number,elapsedTime:Number):void
		{
			var wander2d:Vector3=SteerForWander(elapsedTime);
			wander2d.y=0;

			var steer:Vector3=Vector3.VectorAddition(Forward , Vector3.ScalarMultiplication(3,wander2d));
			ApplySteeringForce (steer,elapsedTime);

			// for annotation
			trail.Record (currentTime,Position);
		}
	}
}