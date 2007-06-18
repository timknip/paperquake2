/*
 * Copyright 2007 (c) Tim Knip, suite75.com.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package com.suite75.papervision3d.scenes
{
	import flash.display.Sprite;
	import flash.utils.*;

	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.objects.DisplayObject3D;

	import com.suite75.papervision3d.utils.PolygonClipper;
	
	/**
	 * 
	 */
	public class ClipDisplayObject3D extends DisplayObject3D
	{
		public var useClipping:Boolean = false;
		
		/**
		 * 
		 * @param	name
		 * @param	geometry
		 * @param	initObject
		 */
		public function ClipDisplayObject3D( name:String=null, geometry:GeometryObject3D=null, initObject:Object=null ):void
		{
			super( name, geometry, initObject );
		}
		
		/**
		 * 
		 * @param	parent
		 * @param	camera
		 * @param	sorted
		 * @return
		 */
		public override function project( parent :DisplayObject3D, camera :CameraObject3D, sorted :Array=null ):Number
		{
			var num:Number = super.project( parent, camera, sorted );
			
			// want a ref to the camera (need cam's position to clip faces in #render )
			this._camera = camera;
			
			return num;
		}
		
		/**
		 * 
		 * @param	instance
		 * @param	vertex
		 * @param	transformation
		 */
		private function transformPoints( instance:DisplayObject3D, camera:CameraObject3D, vertices:Array, transformation:Matrix3D ):void 
		{
			var m11 :Number = transformation.n11;
			var m12 :Number = transformation.n12;
			var m13 :Number = transformation.n13;
			var m21 :Number = transformation.n21;
			var m22 :Number = transformation.n22;
			var m23 :Number = transformation.n23;
			var m31 :Number = transformation.n31;
			var m32 :Number = transformation.n32;
			var m33 :Number = transformation.n33;

			var m14 :Number = transformation.n14;
			var m24 :Number = transformation.n24;
			var m34 :Number = transformation.n34;
			
			var focus    :Number = camera.focus;
			var zoom     :Number = camera.zoom;
			var screen 	 :Vertex2D, persp :Number;
			
			var i:int = vertices.length;
			var vertex:Vertex3D;
			
			Papervision3D.log( "rendering #" + i );
			
			while( vertex = vertices[--i] )
			{
				var vx :Number =  vertex.x;
				var vy :Number =  vertex.y;
				var vz :Number =  vertex.z;

				var s_x :Number = vx * m11 + vy * m12 + vz * m13 + m14;
				var s_y :Number = vx * m21 + vy * m22 + vz * m23 + m24;
				var s_z :Number = vx * m31 + vy * m32 + vz * m33 + m34;
							
				screen = instance.projected[vertex] || (instance.projected[vertex] = new Vertex2D());
				
				persp  = focus / (focus + s_z) * zoom;

				screen.x = s_x * persp;
				screen.y = s_y * persp;
				screen.z = s_z;
			}
		}
		
		/**
		 * 
		 * @param	scene
		 */
		public override function render( scene :SceneObject3D ):void
		{			
			var iFaces :Array = this._sorted;

			iFaces.sortOn( 'screenZ', Array.DESCENDING | Array.NUMERIC );

			// Render
			var container :Sprite = this.container || scene.container;
			var rendered  :Number = 0;
			var iFace     :Object;

			var pos:Number3D = new Number3D( _camera.x, _camera.y, _camera.z );

			// create the near plane. TODO: is this ok?
			var plane:Object = new Object();
			plane.normal = new Number3D( 0, 0, 1 );	
			Matrix3D.multiplyVector3x3( Matrix3D.inverse(_camera.view), plane.normal );
			plane.d = -Number3D.dot(plane.normal, pos );			
			
			for( var i:int = 0; iFace = iFaces[i]; i++ )
			{
				if( iFace.visible )
				{
					rendered += iFace.face.render( iFace.instance, container );
				}
				else if( iFace.clipCandidate && useClipping )
				{
					var p0:Vertex3D = new Vertex3D( iFace.face.vertices[0].x, iFace.face.vertices[0].y, iFace.face.vertices[0].z );
					var p1:Vertex3D = new Vertex3D( iFace.face.vertices[1].x, iFace.face.vertices[1].y, iFace.face.vertices[1].z );
					var p2:Vertex3D = new Vertex3D( iFace.face.vertices[2].x, iFace.face.vertices[2].y, iFace.face.vertices[2].z );
				
					var uv:Array = iFace.face.uv.concat();
					
					var tri:Array = PolygonClipper.clipPointsToPlane( [p0, p1, p2], plane, uv );
					
					transformPoints( iFace.instance, _camera, tri, _camera.view );
					
					var j:int;
					var faces:Array = new Array();
					
					faces.push( new Face3D( [tri[0], tri[1], tri[2]], iFace.face.materialName, [uv[0], uv[1], uv[2]] ) );
						
					if( tri.length > 3 )
					{
						for( j = 2; j < tri.length; j++ )
						{
							var k:int = (j+1) % tri.length;
							faces.push( new Face3D( [tri[0], tri[j], tri[k]], iFace.face.materialName, [uv[0], uv[j], uv[k]] ) );
						}
					}

					for( j = 0; j < faces.length; j++ )
						rendered += faces[j].render( iFace.instance, container );			
				}
			}

			// Update stats
			scene.stats.rendered += rendered;			
		}
		
		private var _camera:CameraObject3D;
	}
}