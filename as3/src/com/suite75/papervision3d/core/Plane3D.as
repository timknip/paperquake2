/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org ? blog.papervision3d.org ? osflash.org/papervision3d
 */

/*
 * Copyright 2006 (c) Carlos Ulloa Matesanz, noventaynueve.com.
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
 
// ______________________________________________________________________
//                                                               Plane3D

package com.suite75.papervision3d.core
{

import org.papervision3d.core.Number3D;

/**
* The Plane3D class represents a plane in a three-dimensional coordinate system.
*
*/
public class Plane3D
{	
	/** normal */
	public var normal:Number3D
	
	/** distance to origin */
	public var d:Number
	
	/**
	 * constructor. Creates a plane from three points on the plane.
	 *
	 * @param p0
	 * @param p1
	 * @param p2
	 */	
	public function Plane3D( p0:Number3D = null, p1:Number3D = null, p2:Number3D = null ):void
	{
		if( p0 != null && p1 != null && p2 != null )
		{
			var ab:Number3D = Number3D.sub( p1, p0 );
			var ac:Number3D = Number3D.sub( p2, p0 );
			
			this.normal = Number3D.cross(ab, ac);
			
			this.normal.normalize();
			
			this.d = -Number3D.dot( this.normal, p0 );		
		}	
	}	

	/**
	 *
	 */
	public static function fromNormalAndPoint( normal:Number3D, point:Number3D ):Plane3D
	{
		var plane:Plane3D = new Plane3D();
		plane.normal = normal.clone();
		plane.normal.normalize();
		plane.d = -Number3D.dot( plane.normal, point );
		return plane;
	}
	
	/**
	 * clone.
	 * 
	 * @return
	 */
	public function clone():Plane3D
	{
		var plane:Plane3D = new Plane3D();
		plane.normal = this.normal.clone();
		plane.d = this.d;
		return plane;
	}
	
	/**
	 * distance of point to plane.
	 * 
	 * @param	pt
	 * @return
	 */
	public function distance( pt:Number3D ):Number
	{
		return Number3D.dot(pt, this.normal) + this.d;
	}	
}
}