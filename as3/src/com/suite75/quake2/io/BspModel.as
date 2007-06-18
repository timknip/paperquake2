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
	
	public class BspModel
	{
		public var bbox_min		:Vertex3D; 	// 12
		public var bbox_max		:Vertex3D; 	// 24
		public var origin		:Vertex3D;	// 36 for sounds or lights
		public var headnode		:uint;		// 40
		public var first_face	:uint; 		// 44
		public var num_faces	:uint;  	// 48
		
		public function BspModel()
		{
			
		}
		
		/**
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray ):void
		{
			this.bbox_min = new Vertex3D();
			this.bbox_min.x = pData.readFloat();
			this.bbox_min.y = pData.readFloat();
			this.bbox_min.z = pData.readFloat();
			
			this.bbox_max = new Vertex3D();
			this.bbox_max.x = pData.readFloat();
			this.bbox_max.y = pData.readFloat();
			this.bbox_max.z = pData.readFloat();
			
			this.origin = new Vertex3D();
			this.origin.x = pData.readFloat();
			this.origin.y = pData.readFloat();
			this.origin.z = pData.readFloat();
			
			this.headnode = pData.readUnsignedInt();
			this.first_face = pData.readUnsignedInt();
			this.num_faces = pData.readUnsignedInt();
		}
	}
}
