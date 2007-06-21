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
//                                                               Edge3D

package com.suite75.papervision3d.core
{

import org.papervision3d.core.Number3D;

/**
* The Edge3D class represents a line in a three-dimensional coordinate system.
*
*
*/
public class Edge3D
{
	/** startpoint */
	public var sp:Number3D
	
	/** endpoint */
	public var ep:Number3D
	
	/**
	 *
	 */	
	public function Edge3D( sp:Number3D, ep:Number3D ):void
	{
		this.sp = sp;
		this.ep = ep;
	}

	/**
	 * flip start- and endpoint. 
	 */
	public function flip():void
	{
		var tmp:Number3D = this.sp;
		this.sp = this.ep;
		this.ep = tmp;
	}
	
	/**
	 * property direction. The (normalized) direction of this edge.
	 */
	public function get direction():Number3D
	{
		var dir:Number3D = Number3D.sub( this.ep, this.sp );
		dir.normalize();
		return dir;
	}
	
	/**
	 * property length. the length of this edge.
	 */
	public function get length():Number
	{
		return Number3D.sub( this.ep, this.sp ).modulo;
	}	
}
}