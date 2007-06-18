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
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.Matrix3D;
	import org.papervision3d.core.Number3D;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.geom.Vertex3D;
	
	public class Triangulate
	{
		private static var _points:Array;
		
		public function Triangulate()
		{
			
		}
		
		/**
		 * triangulate.
		 *
		 * @param coords	array of indices into param points.
		 * @param points	array of Vertex3D. @see org.papervision3d.core.geom.Vertex3D
		 *
		 * return an array with indices.
		 */
		public static function triangulate( coords:Array, points:Array ):Array
		{
			//var projected:Array = projectPoints( coords.concat(), points );
			//_points = points;
			//return null;
			
			var result:Array = new Array();
			
			result.push( [coords[0], coords[1], coords[2]] );
			
			for( var i:int = 2; i < coords.length; i++ )
			{
				var j:int = (i+1) % coords.length;
				result.push( [coords[0], coords[i], coords[j]] );
			}
			
			return result;
			/*
			var projected:Array = new Array();
			for( var i:int = 0; i < points.length; i++ )
				projected[i] = new Vertex3D( points[i].x, points[i].y, points[i].z );
			
			return process( coords.concat(), projected );
			*/
		}
		
		
		/**
		 * finds a valid plane.
		 * 
		 * @param	coords	indices into points array
		 * @param	points	array of points
		 * 
		 * @return	a 4 element array representing plane A,B,C and D
		 */
		private static function findPlane( coords:Array, points:Array ):Array
		{
			var plane:Array = new Array( 4 );
			var found:Boolean = false;
			var pt0:Number3D = new Number3D( points[coords[0]].x, points[coords[0]].y, points[coords[0]].z );
			var pt1:Number3D = new Number3D( points[coords[1]].x, points[coords[1]].y, points[coords[1]].z );
			
			for( var i:int = 2; i < coords.length; i++ )
			{
				var pt2:Number3D = new Number3D( points[coords[i]].x, points[coords[i]].y, points[coords[i]].z );
									
				var normal:Number3D = Number3D.cross(Number3D.sub(pt1, pt0), Number3D.sub(pt2, pt0));
					
				normal.normalize();
				
				plane[0] = normal.x;
				plane[1] = normal.y;
				plane[2] = normal.z;
				plane[3] = -Number3D.dot(normal, pt2);	
				
				if( normal.x || normal.y || normal.z ) 
				{
					found = true;
					break;
				}
			}
			
			if( !found ) throw new Error( "couldn't find a valid plane!" );
			return plane;
		}
		
		/**
		 * 
		 * @param	points
		 * @return
		 */
		private static function process( coords:Array, points:Array ):Array
		{
			var poly:Array = new Array();
			var num:uint = coords.length; 
			
			
			if( num < 3 )
				throw new Error( "Can't triangulate faces with less then 3 points!" );
				
			if( num == 3 )
				return [ [coords[0], coords[1], coords[2]] ];
			
			for( var s:int = 0; s < num; s++ )
			{
				poly.push( coords[s] );
			}
				
			var result:Array = new Array();
			var count:uint = 0;
			
			while( num > 3 )
			{
				if( count++ > num * 2 )
				{
					// in a loop... throw...
					throw new Error( "Bad Polygon?" );
				}
				
				for( var i:Number = 0; i < num; i++ )
				{
					var j:Number = (i+num-1) % num;
					var k:Number = (i+1) % num;
								
					var pts:Array = getFaceVerts( poly, points );
					if( isEar(pts, j, i, k) )
					{
						// create triangle
						result.push( [poly[j], poly[i], poly[k]] );
			
						poly.splice( i, 1 );
						num = poly.length;
						count = 0;
					}
				}
			}

			return result;
		}
		
		/**
		 * 
		 * @param	pt
		 * @param	points
		 * @return
		 */
		private static function ptInPoly( pt:Vertex3D, points:Array ):Boolean
		{
			var w:Boolean = false;
			for( var i:int = 0; i < points.length; i++ )
			{
				var j:int = (i+1) % points.length;
				
				var c:Vertex3D = points[i];
				var next:Vertex3D = points[j];
				
				if((((c.y <= pt.y) && (pt.y < next.y)) ||
					((next.y <= pt.y) && (pt.y < c.y))) &&
					(pt.x < (next.x - c.x) * (pt.y - c.y) / (next.y - c.y) + c.x)) 
					{
						w = !w;
					}
			} 
			return w;
		}
		
		/**
		 * signed area of triangle (2D)
		 */
		private static function triArea( points:Array ):Number 
		{
			var area:Number = 0;
			for( var i:int = 0; i < points.length; i++ )
			{
				var j:int = (i+1) % points.length;
				area += points[i].x * points[j].y;
				area -= points[i].y * points[j].x;
			}
			area /= 2.0;
			return area;
		}
		
		/**
		 * 
		 * @param	points
		 * @param	u
		 * @param	v
		 * @param	w
		 * @return
		 */
		private static function isEar( points:Array, u:uint, v:uint, w:uint ):Boolean
		{		
			var tri:Array = [points[u], points[v], points[w]];	
			
			var ar:Number = triArea(tri);
			
			if( !ar )
			{
				Papervision3D.log( "" + ar  + " " + tri );
				return true;
			}
			
			if( triArea(tri) < 0 ) return false;
			for( var i:int = 0; i < points.length; i++ )
			{
				if( i == u || i == v || i == w ) continue;
				if( ptInPoly(points[i], tri) ) return false;
			}
			return true;
		}
		
		/**
		 * 
		 * @param	coords
		 * @param	points
		 * @return
		 */
		private static function getFaceVerts( coords:Array, points:Array ):Array
		{
			var verts:Array = new Array();
			for( var i:Number = 0; i < coords.length; i++ )
				verts.push( points[coords[i]] );
			return verts;
		}
		
		
		/**
		 * 
		 * @param	coords
		 * @param	points
		 * @param	plane
		 * @return
		 */
		private static function projectPoints( coords:Array, points:Array ):Array
		{
			var result:Array = new Array( points.length );
			var plane:Array = findPlane( coords, points );
			var normal:Number3D = new Number3D( plane[0], plane[1], plane[2] );
			
			var up:Number3D = new Number3D( 0, 0, 1 );
				
			var side:Number3D = Number3D.cross(up, normal);
			
			side.normalize();
			
			up = Number3D.cross( normal, side );
			up.normalize();
			
			var matrix:Matrix3D = new Matrix3D([
				side.x, side.y, side.z, 0,
				up.x, up.y, up.z, 0,
				normal.x, normal.y, normal.z, 0,
				0, 0, 0, 1
				]);
			
			for( var i:int = 0; i < points.length; i++ )
				result[i] = new Vertex3D( points[i].x, points[i].y, points[i].z );
				
			transformPoints( result, matrix );
				
			return result;
		}
		
		/**
		 * 
		 * @return
		 */
		private static function transformPoints( vertices:Array, transformation:Matrix3D ):void
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
			
			var i:int = vertices.length;
			var vertex:Vertex3D;
			
			while( vertex = vertices[--i] )
			{
				// Center position
				var vx :Number = vertex.x;
				var vy :Number = vertex.y;
				var vz :Number = vertex.z;
				
				var tx :Number = vx * m11 + vy * m12 + vz * m13 + m14;
				var ty :Number = vx * m21 + vy * m22 + vz * m23 + m24;
				var tz :Number = vx * m31 + vy * m32 + vz * m33 + m34;

				vertex.x = tx;
				vertex.y = ty;
				vertex.z = tz;
			}
		}
		
		/**
		 * 
		 * @param	coords
		 * @param	points
		 * @param	plane
		 * @return
		 */
		private static function projectPoints2( coords:Array, points:Array ):Array
		{
			var result:Array = new Array( points.length );
			var plane:Array = findPlane( coords, points );
			var normal:Number3D = new Number3D( plane[0], plane[1], plane[2] );
			
			normal.normalize();
			
			var dominant:uint = 0;
			
			var nx:Number = Math.abs( normal.x );
			var ny:Number = Math.abs( normal.y );
			var nz:Number = Math.abs( normal.z );
			
			if(ny > nx) dominant = 1;
			if(nz > ny && nz > nx) dominant = 2;
			
			/*
			if( nx >= ny && nx  >= nz )
				dominant = 0; // yz-plane
			else if( ny >= nx && ny  >= nz )
				dominant = 1; // xz-plane
			else
				dominant = 2; // xy-plane
			*/
			
			var pts:Array = [];
			for( var i:int = 0; i < coords.length; i++ )
			{
				var clone:Vertex3D = new Vertex3D();
				
				switch( dominant )
				{
					case 0:
						clone.x = points[coords[i]].y;
						clone.y = points[coords[i]].z;
						break;
						
					case 1:
						clone.x = points[coords[i]].x;
						clone.y = points[coords[i]].z;
						break;
						
					case 2: 
					default:
						clone.x = points[coords[i]].x;
						clone.y = points[coords[i]].y;
						break;
				}
				clone.z = 0;
				pts.push( clone );
			}
			
			try
			{
				findPlane( [0,1,2], pts );
			}
			catch( e:Error )
			{
				Papervision3D.log( "err: " + dominant + " => " + normal );
			}
			if( triArea(pts) < 0 )
				pts.reverse();
			
			for( var j:int = 0; j < coords.length; j++ )
				result[coords[j]] = pts[j];
			
			return result;
		}
	}
}
