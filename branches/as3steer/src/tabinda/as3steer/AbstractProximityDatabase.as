﻿// ----------------------------------------------------------------------------
//
// OpenSteer - Action Script 3 Port
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

package tabinda.as3steer
{	
	/**
	 *  abstract type for all kinds of proximity databases
	 */
	public class AbstractProximityDatabase
	{
		/** allocate a token to represent a given client object in this database
		 * 
		 * @param	parentObject An Abstract Vehicle
		 * @return  AbstractTokenForProximityDatabase
		 */
		public function allocateToken(parentObject:AbstractVehicle):AbstractTokenForProximityDatabase
		{
			return new AbstractTokenForProximityDatabase();
		}

		/** returns the number of tokens in the proximity database
		 * 
		 * @return 0
		 */ 
		public function getPopulation():int
		{
			return 0;
		}

		public function getNearestVehicle(position:Vector3,radius:Number):AbstractVehicle
		{
			return null;
		}

		public function getMostPopulatedBinCenter():Vector3
		{
			return Vector3.ZERO;
		}

	}
}