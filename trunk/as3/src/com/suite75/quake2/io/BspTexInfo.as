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
	
	import org.papervision3d.core.geom.Vertex3D;
	
	public class BspTexInfo
	{
		public var u_axis:Vertex3D;		// 12 float[3]
		public var u_offset:Number;		// 16 float
		
		public var v_axis:Vertex3D;		// 28 float[3]
		public var v_offset:Number;		// 32 float
		
		public var flags:int;			// 36 [int32] miptex flags + overrides
		public var value:int;			// 40 [int32] light emission, etc
		public var texture:String;		// 72 [char[32]]  texture name (textures/*.wal)
		public var nexttexinfo:int;		// 76 [int32] for animations, -1 = end of chain
		
		/**
		 * 
		 */
		public function BspTexInfo()
		{
			
		}
		
		/**
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray ):void
		{
			this.u_axis = new Vertex3D();
			this.u_axis.x = pData.readFloat();
			this.u_axis.y = pData.readFloat();
			this.u_axis.z = pData.readFloat();
			this.u_offset = pData.readFloat();
			
			this.v_axis = new Vertex3D();
			this.v_axis.x = pData.readFloat();
			this.v_axis.y = pData.readFloat();
			this.v_axis.z = pData.readFloat();
			this.v_offset = pData.readFloat();
			
			this.flags = pData.readInt();
			this.value = pData.readInt();
			this.texture = pData.readMultiByte( 32, "iso-8859-1" );
			this.nexttexinfo = pData.readInt();
		}
	}
}
