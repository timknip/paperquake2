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
 
package com.suite75.papervision3d.cameras
{
	import flash.geom.Rectangle;
	import org.papervision3d.Papervision3D;

	import com.suite75.papervision3d.core.Edge3D;
	import com.suite75.papervision3d.core.Plane3D;
	
	import org.papervision3d.cameras.FreeCamera3D;
	import org.papervision3d.core.Matrix3D;
	import org.papervision3d.core.Number3D;
	import org.papervision3d.core.proto.CameraObject3D;
	
	/**
	 * 
	 */
	public class FrustumCamera3D extends FreeCamera3D
	{
		public static const LEFT:uint 	= 0;
		public static const RIGHT:uint 	= 1;
		public static const TOP:uint 	= 2;
		public static const BOTTOM:uint = 3;
		public static const NEAR:uint 	= 4;
		public static const FAR:uint 	= 5;
		
		/** */
		public var fov:Number;
		
		/** */
		public var near:Number = -10;
		
		/** */
		public var far:Number = 1000;
		
		/** */
		public var viewport:Rectangle;
		
		/** */
		public var position:Number3D;
		
		/**
		 * 
		 * @param	fov
		 * @param	viewport
		 */
		public function FrustumCamera3D( fov:Number = 65, viewport:Rectangle = null, far:Number = 100, near:Number = -10 ):void
		{
			super();
			
			this.fov = fov;
			this.viewport = viewport || new Rectangle( -160, -120, 320, 240 );
			this.far = far;
			this.near = near;
			
			this.position = new Number3D();
			
			init();
		}
		
		/**
		 * 
		 * @param	points
		 */
		public function test( points:Array ):Boolean
		{			
			var straddle:Array = new Array();
			
			for( var j:int = 0; j < 5; j++ )
			{
				var plane:Plane3D = this._vplanes[j];
				var cnt:int = 0;
				
				for( var i:int = 0; i < points.length; i++ )
				{
					var p:Number3D = new Number3D( points[i].x, points[i].y, points[i].z );
					var dist:Number = plane.distance(p);
					
					if( dist < 0 )
						cnt++;
				}
				
				if( cnt == 3 )
					return false;
			}
			
			return true;
		}
		
		/**
		 * 
		 * @param	transform
		 */
		public override function transformView( transform:Matrix3D=null ):void
		{
			super.transformView( transform );
			
			this.position.x = this.x;
			this.position.y = this.y;
			this.position.z = this.z;
			
			// transform the frustum
			for( var i:int = 0; i < this._planes.length; i++ )
			{
				var plane:Plane3D = this._planes[i];
				var normal:Number3D = plane.normal.clone();
				
				Matrix3D.multiplyVector3x3( this.transform, normal );
				
				normal.normalize();
				
				this._vplanes[i].normal = normal;
				this._vplanes[i].d = -Number3D.dot( normal, this.position );
			}
		}
		
		/**
		 * 
		 */
		private function init():void
		{
			var fov2:Number = (this.fov/2) * (Math.PI/180.0);	
			
			// Make projection constants
			var s:Number =  Math.sin(fov2);
			var c:Number =  Math.cos(fov2);
			
			// Make projection constants
			this._proj = (c*(this.viewport.width>>1))/s;
			this._projRatio = this.viewport.width * 0.75;
			this._projRatio = this.viewport.height / this._projRatio;
			
			setupFrustum();
		}

		/**
		 * 
		 */
		private function setupFrustum():void 
		{	
			// Horizontal FOV
			var a:Number = Math.atan2((this.viewport.width>>1), this._proj);
			var ch:Number = Math.cos(a);
			var sh:Number = Math.sin(a);
			
			// Vertical FOV
			a = Math.atan2((this.viewport.height>>1), this._proj * this._projRatio);
			var cv:Number = Math.cos(a);
			var sv:Number = Math.sin(a);
									
			this._planes = new Array();
			
			// left
			this._planes[LEFT] = new Plane3D();
			this._planes[LEFT].normal = new Number3D(ch, 0, sh);
			this._planes[LEFT].d = 0;
			
			// right
			this._planes[RIGHT] = new Plane3D();
			this._planes[RIGHT].normal = new Number3D(-ch, 0, sh);
			this._planes[RIGHT].d = 0;
			
			// top
			this._planes[TOP] = new Plane3D();
			this._planes[TOP].normal = new Number3D(0, cv, sv);
			this._planes[TOP].d = 0;
			
			// bottom
			this._planes[BOTTOM] = new Plane3D();
			this._planes[BOTTOM].normal = new Number3D(0, -cv, sv);
			this._planes[BOTTOM].d = 0;
			
			// near
			this._planes[NEAR] = new Plane3D();
			this._planes[NEAR].normal = new Number3D(0, 0, 1);
			this._planes[NEAR].d = this.near;
			
			// far
			//this._planes[FAR] = new Plane3D();
			//this._planes[FAR].normal = new Number3D(0, 0, -1);
			//this._planes[FAR].d = this.far;
			
			this._vplanes = new Array(6);
			this._vplanes[LEFT] = new Plane3D();
			this._vplanes[RIGHT] = new Plane3D();
			this._vplanes[TOP] = new Plane3D();
			this._vplanes[BOTTOM] = new Plane3D();
			this._vplanes[NEAR] = new Plane3D();
			this._vplanes[FAR] = new Plane3D();
		}
		
		private var _planes:Array;
		private var _vplanes:Array;
		private var _proj:Number;
		private var _projRatio:Number;
	}
}
