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
	
	public class BspNode
	{
		public var plane:uint;    	// [uint32] index of the splitting plane (in the plane array)
		
		public var front_child:int;// [int32] index of the front child node or leaf
		public var back_child:int; // [int32] index of the back child node or leaf
	   
		public var bbox_min:Vertex3D; // [point3s] minimum x, y and z of the bounding box
		public var bbox_max:Vertex3D; // [point3s] maximum x, y and z of the bounding box
		
		public var first_face:uint;	// [uint16] index of the first face (in the face array)
		public var num_faces:uint;	// [uint16] number of consecutive edges (in the face array)

		/**
		 * ctor 
		 */
		public function BspNode()
		{
			
		}
		
		/**
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray ):void
		{
			this.plane = pData.readUnsignedInt();
			this.front_child = pData.readInt();
			this.back_child = pData.readInt();
			
			this.bbox_min = new Vertex3D();
			this.bbox_min.x = pData.readShort();
			this.bbox_min.y = pData.readShort();
			this.bbox_min.z = pData.readShort();
			
			this.bbox_max = new Vertex3D();
			this.bbox_max.x = pData.readShort();
			this.bbox_max.y = pData.readShort();
			this.bbox_max.z = pData.readShort();
			
			this.first_face = pData.readUnsignedShort();
			this.num_faces = pData.readUnsignedShort();
		}
	}
}
