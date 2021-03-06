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

package tabinda.demo.plugins.Soccer
{
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.core.math.*;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.special.*;
	import org.papervision3d.Papervision3D;
	import org.papervision3d.typography.*;
	
	import tabinda.demo.*;
	import tabinda.papersteer.*;
	
	public class SoccerPlugIn extends PlugIn
	{
		private var teamA:Vector.<Player>;
		private var teamB:Vector.<Player>;
		private var allPlayers:Vector.<Player>;

		private var ball:Ball;
		private var bbox:AABBox;
		private var teamAGoal:AABBox;
		private var teamBGoal:AABBox;
		private var redScore:int;
		private var blueScore:int;
		
		// PV3D Variables
		public var GridMesh:TriangleMesh3D;						// Mesh used to create a Grid - Look at Grid Function
		public var LineList:Lines3D;
		private var text3D:Text3D;

		// TTT - Used to perform selective rendering in Plugins
		// Affects - Grids and Large redrawn objects
		public var ForceRedraw:Boolean;
		
		public function SoccerPlugIn()
		{
			super();
			
			teamA = new Vector.<Player>();
			teamB = new Vector.<Player>();
			allPlayers = new Vector.<Player>();
		}
		
		public function initPV3D():void
		{		
			GridMesh = new TriangleMesh3D(new ColorMaterial(0x000000,1) , new Array(), new Array());
			LineList = new Lines3D(new LineMaterial(0x000000, 1));
			
			addPV3DObject(LineList);
			addPV3DObject(GridMesh);
		}

		public override function get Name():String { return "Michael's Simple Soccer"; }

		public override function Open():void
		{
			// Initialize PV3D objects
			initPV3D();
			
			// Set to true for first render
			ForceRedraw = true;
			
			// Make a field
			bbox = new AABBox(new Vector3( -20, 0, -10), new Vector3(20, 0, 10));
			addPV3DObject(bbox.LineList);
			
			// Red goal
			teamAGoal = new AABBox(new Vector3( -21, 0, -7), new Vector3( -19, 0, 7));
			addPV3DObject(teamAGoal.LineList);
			
			// Blue Goal
			teamBGoal = new AABBox(new Vector3(19, 0, -7), new Vector3(21, 0, 7));
			addPV3DObject(teamBGoal.LineList);
			
			// Make a ball
			ball = new Ball(bbox);
			
			addPV3DObject(ball.VehicleMesh);
			addPV3DObject(ball.LineList);
			
			// Build team A
			const PlayerCountA:int = 8;
			
			for (var i:int = 0; i < PlayerCountA; i++)
			{
				var pMicTest:Player = new Player(teamA, allPlayers, ball, true, i);
				Demo.SelectedVehicle = pMicTest;
				teamA.push(pMicTest);
				
				addPV3DObject(pMicTest.VehicleMesh);
				addPV3DObject(pMicTest.LineList);
				
				allPlayers.push(pMicTest);
			}
			
			// Build Team B
			const  PlayerCountB:int = 8;
			
			for (i = 0; i < PlayerCountB; i++)
			{
				pMicTest = new Player(teamB, allPlayers, ball, false, i);
				Demo.SelectedVehicle = pMicTest;
				teamB.push(pMicTest);
				
				addPV3DObject(pMicTest.VehicleMesh);
				addPV3DObject(pMicTest.LineList);
				
				allPlayers.push(pMicTest);
			}
			
			// initialize camera
			Demo.Init2dCamera(ball);
			Demo.camera.SetPosition(10, Demo.Camera2dElevation, 10);
			Demo.camera.FixedPosition = new Vector3(40,40,40);
			Demo.camera.Mode = CameraMode.Fixed;
			
			Demo.Draw2dTextAt2dLocation("", new Vector3(20, 50, 0), Colors.Black);
			
			redScore = 0;
			blueScore = 0;
		}

		/**
		 * @inheritDoc
		 */
		public override function Update(currentTime:Number, elapsedTime:Number):void
		{
			// update simulation of test vehicle
			for (var i:int = 0; i < teamA.length; i++)
			{
				teamA[i].Update(currentTime, elapsedTime);
			}
			
			for (i = 0; i < teamB.length; i++)
			{
				teamB[i].Update(currentTime, elapsedTime);
			}
			
			ball.Update(currentTime, elapsedTime);

			if (teamAGoal.IsInsideX(ball.Position) && teamAGoal.IsInsideZ(ball.Position))
			{
				ball.Reset();	// Ball in blue teams goal, red scores
				redScore++;
			}
			
			if (teamBGoal.IsInsideX(ball.Position) && teamBGoal.IsInsideZ(ball.Position))
			{
				ball.Reset();	// Ball in red teams goal, blue scores
				blueScore++;
			}
		}

		public function Grid(gridTarget:Vector3):void
		{		
			var center:Vector3 = new Vector3(Number(Math.round(gridTarget.x * 0.5) * 2),
												 Number(Math.round(gridTarget.y * 0.5) * 2) - .05,
												 Number(Math.round(gridTarget.z * 0.5) * 2));

			// colors for checkboard
			var gray1:uint = Colors.Gray
			var gray2:uint = Colors.DarkGray;
			
			var size:int = 100;
			var subsquares:int = 50;
			
			var half:Number = size / 2;
			var spacing:Number = size / subsquares;

			var flag1:Boolean = false;
			var p:Number = -half;
			var corner:Vector3 = new Vector3();
			
			for (var i:int = 0; i < subsquares; i++)
			{
				var flag2:Boolean = flag1;
				var q:Number = -half;
				for (var j:int = 0; j < subsquares; j++)
				{
					corner.x = p;
					corner.y = -1;
					corner.z = q;

					corner = Vector3.VectorAddition(corner, center);
					
					var vertA:Vertex3D = corner.ToVertex3D();
					var vertB:Vertex3D = Vector3.VectorAddition(corner, new Vector3(spacing, 0, 0)).ToVertex3D();
					var vertC:Vertex3D = Vector3.VectorAddition(corner, new Vector3(spacing, 0, spacing)).ToVertex3D();
					var vertD:Vertex3D = Vector3.VectorAddition(corner, new Vector3(0, 0, spacing)).ToVertex3D();
					
					GridMesh.geometry.vertices.push(vertA, vertB,vertC, vertD);
					
					var color:uint = flag2 ? gray1 : gray2;
					var colorMaterial:ColorMaterial = new ColorMaterial(color, 1);
					colorMaterial.doubleSided = true;
					
					var t1:Triangle3D = new Triangle3D(GridMesh, [vertA,vertB,vertC], colorMaterial);
					var t2:Triangle3D = new Triangle3D(GridMesh, [vertD,vertA,vertC], colorMaterial);
					
					GridMesh.geometry.faces.push(t1);
					GridMesh.geometry.faces.push(t2);
					
					flag2 = !flag2;
					q += spacing;
				}
				flag1 = !flag1;
				p += spacing;
			}
			GridMesh.geometry.ready = true;
		}
		
		public override function Redraw(currentTime:Number, elapsedTime:Number):void
		{
			// We do this because AS3 uses a Display List
			// and constant redrawing bogs the CPU down
			if(ForceRedraw)
			{
				LineList.geometry.faces = [];
				LineList.geometry.vertices = [];
				LineList.removeAllLines();
				
				GridMesh.geometry.faces = [];
				GridMesh.geometry.vertices = [];
				
				Grid(Vector3.Zero);
				
				bbox.Draw();
				teamAGoal.Draw();
				teamBGoal.Draw();
				
				ForceRedraw = false;
			}

			// draw test vehicle
			for (var i:int = 0; i < teamA.length; i++)
			{
				teamA[i].Draw();
			}
			
			for (i = 0; i < teamB.length; i++)
			{
				teamB[i].Draw();
			}
			
			ball.Draw();

			var annote:String = new String();
			annote += "Red: " + redScore;
			//text3D.text = annote;
			//text3D.position = new Number3D(23, 0, 0);
			//Drawing.Draw2dTextAt3dLocation(annote.ToString(), new Vector3(23, 0, 0), new Color((byte)(255.0 * 1), (byte)(255.0f * 0.7), (byte)(255.0f * 0.7f)));

			annote = new String();
			annote +="Blue: "+blueScore;
			//Drawing.Draw2dTextAt3dLocation(annote.ToString(), new Vector3(-23, 0, 0), new Color((byte)(255.0f * 0.7f), (byte)(255.0f * 0.7f), (byte)(255.0f * 1)));

			// update camera, tracking test vehicle
			Demo.UpdateCamera(currentTime, elapsedTime, Demo.SelectedVehicle);
		}

		public override function Close():void
		{
			//TODO: Remove scene object once the plugin closes
			destoryPV3DObject(GridMesh);
			destoryPV3DObject(LineList);
			
			destoryPV3DObject(ball.VehicleMesh);
			destoryPV3DObject(ball.LineList);
			ball.removeTrail();
			
			destoryPV3DObject(bbox.LineList);
			destoryPV3DObject(teamAGoal.LineList);
			destoryPV3DObject(teamBGoal.LineList);
			
			for (var i:int = 0; i < allPlayers.length; i++)
			{
				destoryPV3DObject(allPlayers[i].VehicleMesh);
				destoryPV3DObject(allPlayers[i].LineList);
			}
			
			teamA.splice(0,teamA.length);
			teamB.splice(0,teamB.length);
			allPlayers.splice(0,allPlayers.length);
		}
		
		private function destoryPV3DObject(object:*):void 
		{
			Demo.container.removeChild(object);
			object.material.destroy();
			object = null;
		}
		
		private function addPV3DObject(object:*):void
		{
			Demo.container.addChild(object);
		}

		public override function Reset():void
		{
			// reset vehicle
			for (var i:int = 0; i < teamA.length; i++)
			{
					teamA[i].Reset();
			}
			for (i = 0; i < teamB.length; i++)
			{
				teamB[i].Reset();
			}
			ball.Reset();
			
			ForceRedraw = true;
		}

		public override function get Vehicles():Vector.<IVehicle>
		{
			var vehicles:Vector.<IVehicle> = Vector.<IVehicle>(allPlayers);
			return vehicles;
		}
	}
}
