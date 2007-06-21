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
 
package com.suite75.papervision3d.objects
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import com.suite75.papervision3d.core.Edge3D;
	import com.suite75.papervision3d.core.Plane3D;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.Number3D;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * 
	 */
	public class ClipFace3D extends Face3D
	{
		public var viewport:Rectangle;
		
		public var lightmap:BitmapData;
		
		public var enableLightmaps:Boolean;
		
		public var texture:BitmapData;
		
		/**
		 * 
		 * @param	vertices
		 * @param	materialName
		 * @param	uv
		 */
		public function ClipFace3D( vertices:Array, materialName:String=null, uv:Array=null, viewport:Rectangle = null, lightmap:BitmapData = null ):void
		{
			super( vertices, materialName, uv );
			
			this.viewport = viewport || new Rectangle( -160, -100, 320, 200 );
			this.lightmap = lightmap;
			this.enableLightmaps = false;
		}
		
		/**
		 * 
		 * @param	instance
		 * @param	container
		 * @return
		 */
		public override function render( instance:DisplayObject3D, container:Sprite ): Number
		{
			var vertices  :Array      = this.vertices;
			var projected :Dictionary = instance.projected;

			var s0 :Vertex2D = projected[ vertices[0] ];
			var s1 :Vertex2D = projected[ vertices[1] ];
			var s2 :Vertex2D = projected[ vertices[2] ];

			var x0 :Number = s0.x;
			var y0 :Number = s0.y;
			var x1 :Number = s1.x;
			var y1 :Number = s1.y;
			var x2 :Number = s2.x;
			var y2 :Number = s2.y;

			var material :MaterialObject3D = ( this.materialName && instance.materials )? instance.materials.materialsByName[ this.materialName ] : instance.material;

			// Invisible?
			if( material.invisible ) return 0;

			// Double sided?
			if( material.oneSide )
			{
				if( material.opposite )
				{
					if( ( x2 - x0 ) * ( y1 - y0 ) - ( y2 - y0 ) * ( x1 - x0 ) > 0 )
					{
						return 0;
					}
				}
				else
				{
					if( ( x2 - x0 ) * ( y1 - y0 ) - ( y2 - y0 ) * ( x1 - x0 ) < 0 )
					{
						return 0;
					}
				}
			}

			//Papervision3D.log( "container: " + container.name );
			
			if( !this._lightmapMatrix && material.bitmap )
			{
				_lightmapMatrix = new Matrix();
				_lightmapMatrix.scale( material.bitmap.width/lightmap.width, material.bitmap.height/lightmap.height );
			}
			
			/*
			if( !this.texture && material.bitmap )
			{
				this.texture = material.bitmap.clone(); //new BitmapData(material.bitmap.width, material.bitmap.height);
				this.texture.draw( lightmap, _lightmapMatrix, null, "overlay" );
			}
			*/
			
			var texture   :BitmapData  = material.bitmap;
			var fillAlpha :Number      = material.fillAlpha;
			var lineAlpha :Number      = material.lineAlpha;

			var graphics  :Graphics    = container.graphics;

			if( texture )
			{
				var map :Object = instance.projected[ this ] || transformUV( instance );

				var a1  :Number = map._a;
				var b1  :Number = map._b;
				var c1  :Number = map._c;
				var d1  :Number = map._d;
				var tx1 :Number = map._tx;
				var ty1 :Number = map._ty;

				var a2  :Number = x1 - x0;
				var b2  :Number = y1 - y0;
				var c2  :Number = x2 - x0;
				var d2  :Number = y2 - y0;

				var matrix :Matrix = _bitmapMatrix;
				matrix.a = a1*a2 + b1*c2;
				matrix.b = a1*b2 + b1*d2;
				matrix.c = c1*a2 + d1*c2;
				matrix.d = c1*b2 + d1*d2;
				matrix.tx = tx1*a2 + ty1*c2 + x0;
				matrix.ty = tx1*b2 + ty1*d2 + y0;
				
				if( this.enableLightmaps && this.lightmap )
				{
					var lm:Sprite = container.getChildAt(0) as Sprite;
					var g:Graphics = lm.graphics;
					
					var m:Matrix = _lightmapMatrix.clone();
					m.concat( matrix );
					
					g.beginBitmapFill( this.lightmap, m );
					g.lineStyle();
					g.moveTo( x0, y0 );
					g.lineTo( x1, y1 );
					g.lineTo( x2, y2 );
			
					g.endFill();
				}
			
				graphics.beginBitmapFill( texture, matrix, false, material.smooth );
				
			}
			else if( fillAlpha )
			{
				graphics.beginFill( material.fillColor, fillAlpha );
			}

			// Line color
			if( lineAlpha )
				graphics.lineStyle( 0, material.lineColor, lineAlpha );
			else
				graphics.lineStyle();

			// Draw triangle
			graphics.moveTo( x0, y0 );
			graphics.lineTo( x1, y1 );
			graphics.lineTo( x2, y2 );

			if( lineAlpha )
				graphics.lineTo( x0, y0 );

			if( texture || fillAlpha )
				graphics.endFill();

			return 1;
		}
		
		private function findSplitterEdge( vpEdges:Array, fEdges:Array ):void
		{
			for( var i:int = 0; i < vpEdges.length; i++ )
			{
				var x1:Number = vpEdges[i][0][0];
				var y1:Number = vpEdges[i][0][1];
				var x2:Number = vpEdges[i][1][0];
				var y2:Number = vpEdges[i][1][1];
				
				for( var j:int = 0; j < fEdges.length; j++ )
				{
					var x3:Number = fEdges[j][0].x;
					var y3:Number = fEdges[j][0].y;
					var x4:Number = fEdges[j][1].x;
					var y4:Number = fEdges[j][1].y;
					
					var isect:Vertex2D = intersection(x1, y1, x2, y2, x3, y3, x4, y4);
					
					if( isect )
					{
						Papervision3D.log( "isect @" + i + "," + j + " " + isect.x+","+isect.y);
					}
				}
			}
		}
		
		/**
		 * 
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @param	x3
		 * @param	y3
		 * @param	x4
	 	 * @param	y4
		 * @return
		 */
		private function intersection( x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number):Vertex2D 
		{
			var d:Number = ((y4-y3)*(x2-x1)-(x4-x3)*(y2-y1));
			
			if (d != 0) 
			{ 
				// The lines intersect at a point somewhere
				var ua:Number = ((x4-x3)*(y1-y3)-(y4-y3)*(x1-x3)) / d;
				var ub:Number = ((x2-x1)*(y1-y3)-(y2-y1)*(x1-x3)) / d;

				if( (ua > 0 && ua < 1) && (ub > 0 && ub < 1) ) 
				{ 
					var x:Number = x1 + ua*(x2-x1);
					var y:Number = y1 + ua*(y2-y1);
					
					return new Vertex2D(x, y);
				}
			}
			
			return null;
		}
		
		/**
		 * 
		 * @param	s0
		 * @param	s1
		 * @param	s2
		 * @return
		 */
		private function numInsideViewport( s0:Vertex2D, s1:Vertex2D, s2:Vertex2D ):Array
		{
			var result:Array = new Array();
			var vp:Rectangle = this.viewport;
			
			if( vp.contains(s0.x, s0.y) ) result.push(s0);
			if( vp.contains(s1.x, s1.y) ) result.push(s1);
			if( vp.contains(s2.x, s2.y) ) result.push(s2);
			
			return result;
		}
		
		private var _lightmapMatrix:Matrix;
	}
}
