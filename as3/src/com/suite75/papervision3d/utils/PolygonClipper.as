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
 
package com.suite75.papervision3d.utils
{	
	import org.papervision3d.core.*;
	import org.papervision3d.core.geom.*;
	
	public class PolygonClipper
	{
		public static const OUTSIDE:uint = 0;
		public static const INSIDE:uint = 1;
		public static const OUT_IN:uint = 2;
		public static const IN_OUT:uint = 3;
		
		public static const POSITIVE:uint 	= 0;
		public static const NEGATIVE:uint 	= 1;
		public static const COINCIDING:uint = 2;
		public static const SPANNING:uint 	= 3;
		
		/**
		 * 
		 */
		public function PolygonClipper()
		{
			
		}
		
		/**
		 * Sutherland-Hodgman clipping of a @see Polygon by a @see Plane.
		 * 
		 * @param	points
		 * @param	plane - plane: array with 4 items 'A', 'B', 'C' and 'D'
		 * @return 	Array - the clipped poly
		 */
		public static function clipToPlane( points:Array, plane:Array ):Array
		{
			return clipPointsToPlane(points, plane);
		}

		/**
		 * Sutherland-Hodgman clipping of an Array of Vertex3D by a plane.
		 * 
		 * @param	points
		 * @param	plane
		 * @param	texels
		 * @return
		 */
		public static function clipPointsToPlane( points:Array, plane:Object, texels:Array = null ):Array
		{
			var verts:Array = new Array();
			var uvs:Array = new Array();
			
			var dist1:Number = distancePtPlane( points[0], plane );
			
			for( var j:int = 0; j < points.length; j++ )
			{
				var k:int = (j+1) % points.length;
				
				var pt0:* = points[j];
				var pt1:* = points[k];
				
				var t0:NumberUV = null;
				var t1:NumberUV = null;
				
				if( texels )
				{
					t0 = texels[j];	
					t1 = texels[k];
				}				
				
				var dist2:Number = distancePtPlane( pt1, plane );
				var d:Number = dist1 / (dist1-dist2);
				var t:Vertex3D;
				var uv:NumberUV;
				
				var status:uint = compareDistances( dist1, dist2 );
				
				switch( status )
				{
					case INSIDE:
						verts.push( pt1 );
						if( t0 is NumberUV && t1 is NumberUV )
						{
							uvs.push( t1 );
						}
						break;
				
					case IN_OUT:
						t = new Vertex3D();
						t.x = pt0.x + (pt1.x - pt0.x) * d;
						t.y = pt0.y + (pt1.y - pt0.y) * d;
						t.z = pt0.z + (pt1.z - pt0.z) * d;
						verts.push( t );
						
						if( t0 is NumberUV && t1 is NumberUV )
						{
							uv = new NumberUV();
							uv.u = t0.u + (t1.u - t0.u) * d;
							uv.v = t0.v + (t1.v - t0.v) * d;
							uvs.push( uv );
						}
						break;
					
					case OUT_IN:
						t = new Vertex3D();
						t.x = pt0.x + (pt1.x - pt0.x) * d;
						t.y = pt0.y + (pt1.y - pt0.y) * d;
						t.z = pt0.z + (pt1.z - pt0.z) * d;
						verts.push( t );
						verts.push( pt1 );
						if( t0 is NumberUV && t1 is NumberUV )
						{
							uv = new NumberUV();
							uv.u = t0.u + (t1.u - t0.u) * d;
							uv.v = t0.v + (t1.v - t0.v) * d;
							uvs.push( uv );
							uvs.push( t1 );
						}
						break;
							
					default:
						break;
				}
				dist1 = dist2;
			}
				
			if( texels )
			{
				for( var tex:int = 0; tex < uvs.length; tex++ )
					texels[tex] = uvs[tex];
			}
			
			return verts;			
		}
		
		/**
		 * creates a plane from 3 points.
		 * 
		 * @param	p0
		 * @param	p1
		 * @param	p2
		 * @return
		 */
		public static function createPlane( p0:*, p1:*, p2:* ):Object
		{
			var pt0:Number3D = new Number3D( p0.x, p0.y, p0.z );
			var pt1:Number3D = new Number3D( p1.x, p1.y, p1.z );
			var pt2:Number3D = new Number3D( p2.x, p2.y, p2.z );
			
			var normal:Number3D = Number3D.cross(Number3D.sub(pt1, pt0), Number3D.sub(pt2, pt0));
					
			normal.normalize();
			
			var plane:Object = new Object();
			plane.normal = new Vertex3D( normal.x, normal.y, normal.z );
			plane.d = -Number3D.dot(normal, pt2);	
			return plane;
		}
		
		/**
		 * 
		 * @param	pDist1
		 * @param	pDist2
		 * @return
		 */
		private static function compareDistances( pDist1:Number, pDist2:Number ):uint
		{			
			if( pDist1 < 0 && pDist2 < 0 )
				return OUTSIDE;
			else if( pDist1 > 0 && pDist2 > 0 )
				return INSIDE;
			else if( pDist1 > 0 && pDist2 < 0 )
				return IN_OUT;	
			else
				return OUT_IN;
		}		
		
		/**
		 * classifies a point being behind, in front or spanning this plane.
		 * 
		 * @param	pPoint
		 * @param	pTolerance
		 * @return
		 */
		public static function classifyPoint( point:*, plane:Object, tolerance:Number = 0.001 ):uint 
		{
			var lDistance:Number = distancePtPlane( point, plane );
			if(lDistance < -tolerance) 
				return PolygonClipper.NEGATIVE;
			else if(lDistance > tolerance) 
				return PolygonClipper.POSITIVE;
			else 
				return PolygonClipper.COINCIDING;
		}

		/**
		 * classifies a point-array being behind, in front or spanning this plane.
		 * 
		 * @param	pPoints
		 * @param	pTolerance
		 * @return
		 */
		public static function classifyPoints( points:Array, plane:Object, tolerance:Number = 0.001 ):uint 
		{
			var numneg:uint = 0;
			var numpos:uint = 0;
			
			for( var i:int = 0; i < points.length; i++ )
			{
				var side:uint = classifyPoint( points[i], plane, tolerance );
				if( side == PolygonClipper.POSITIVE )
					numpos++;
				else if( side == PolygonClipper.NEGATIVE )
					numneg++;
			}
			
			if( numpos > 0 && numneg == 0 )
				return PolygonClipper.POSITIVE;
			else if( numpos == 0 && numneg > 0 )
				return PolygonClipper.NEGATIVE;
			else if( numpos > 0 && numneg > 0 )
				return PolygonClipper.SPANNING;
			else
				return PolygonClipper.COINCIDING;
		}
		
		/**
		 * 
		 * @param	point
		 * @param	plane
		 * @return
		 */
		private static function distancePtPlane( point:*, plane:Object ):Number
		{
			var normal:Number3D = new Number3D( plane.normal.x, plane.normal.y, plane.normal.z );
			var pt:Number3D = new Number3D( point.x, point.y, point.z );
			normal.normalize();
			return Number3D.dot(pt, normal) + plane.d;
		}
	}
}