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
 
package com.suite75.quake2.io
{
	import flash.utils.ByteArray;
	import org.papervision3d.core.Number3D;
	
	public class BspPlane
	{
		public var a:Number;
		public var b:Number;
		public var c:Number;
		public var d:Number;
		
		public var type:uint;  	 	// uint
	
		public var normal:Number3D;
		
		public function BspPlane( normal:Number3D = null, pt:Number3D = null )
		{
			if( normal is Number3D && pt is Number3D )
			{
				normal.normalize();
				
				this.a = normal.x;
				this.b = normal.y;
				this.c = normal.z;
				this.d = -Number3D.dot( normal, pt );	
				
				this.normal = new Number3D( this.a, this.b, this.c );
			}
		}
		
		/**
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray ):void
		{
			this.a = pData.readFloat();
			this.b = pData.readFloat();
			this.c = pData.readFloat();
			this.d = pData.readFloat();
			this.type = pData.readUnsignedInt();
			this.normal = new Number3D( this.a, this.b, this.c );
		}
		
		public function toString():String
		{
			return "[a:"+a+" b:"+b+" c:"+c+"d:"+d+"]";
		}
	}
}
