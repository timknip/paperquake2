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
	
	public class BspLeaf
	{
		public var brush_or:uint;          	// [uint32] OR of all brushes (not needed?)
		public var cluster:int;           	// [uint16] -1 for cluster indicates no visibility information
		public var area:uint;              	// [uint16] ?
		public var bbox_min:Vertex3D; 		// [point3s] minimum x, y and z of the bounding box
		public var bbox_max:Vertex3D; 		// [point3s] maximum x, y and z of the bounding box
		public var first_leaf_face:uint;	// [uint16] index of the first face (in the face leaf array)
		public var num_leaf_faces:uint;		// [uint16] number of consecutive edges (in the face leaf array)
		public var first_leaf_brush:uint;  	// [uint16] ?
		public var num_leaf_brushes:uint;  	// [uint16] ?
	
		public function BspLeaf()
		{
			
		}
		
		/**
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray ):void
		{
			this.brush_or = pData.readUnsignedInt();
			this.cluster = pData.readShort();
			this.area = pData.readUnsignedShort();
			
			this.bbox_min = new Vertex3D();
			this.bbox_min.x = pData.readShort();
			this.bbox_min.y = pData.readShort();
			this.bbox_min.z = pData.readShort();
			
			this.bbox_max = new Vertex3D();
			this.bbox_max.x = pData.readShort();
			this.bbox_max.y = pData.readShort();
			this.bbox_max.z = pData.readShort();
			
			this.first_leaf_face = pData.readUnsignedShort();
			this.num_leaf_faces = pData.readUnsignedShort();
			
			this.first_leaf_brush = pData.readUnsignedShort();
			this.num_leaf_brushes = pData.readUnsignedShort();
			
			//FlashOut3.trace( "leaf bbox:" + this.bbox_min + " " + this.bbox_max );
		}
	}
}
