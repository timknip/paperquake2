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
	public class BspLump
	{
		public static const ENTITIES:uint 			= 0;	// MAP entity text buffer	
		public static const PLANES:uint 			= 1;	// Plane array
		public static const VERTICES:uint 			= 2;	// Vertices array
		public static const VISIBILITY:uint 		= 3;	// Compressed PVS data and directory for all clusters	
		public static const NODES:uint 				= 4;	// Internal node array for the BSP tree	
		public static const TEXTURE_INFO:uint 		= 5;	// Face texture application array	
		public static const FACES:uint 				= 6;	// Face array	
		public static const LIGHTMAPS:uint 			= 7;	// Lightmaps
		public static const LEAVES:uint 			= 8;	// Internal leaf array of the BSP tree	
		public static const LEAVE_FACE_TABLE:uint	= 9;	// Index lookup table for referencing the face array from a leaf	
		public static const LEAVE_BRUSH_TABLE:uint	= 10;	// ?
		public static const EDGES:uint 				= 11;	// Edge Array
		public static const FACE_EDGE_TABLE:uint	= 12;	// Index lookup table for referencing the edge array from a face	
		public static const MODELS:uint 			= 13;	// ?
		public static const BRUSHES:uint 			= 14;	// ?
		public static const BRUSH_SIDES:uint		= 15;	// ?
		public static const POP:uint 				= 16;	// ?
		public static const AREAS:uint 				= 17;	// ?
		public static const AREA_PORTALS:uint		= 18;	// ?
		
		public var offset:uint;     // offset (in bytes) of the data from the beginning of the file
		public var length:uint;     // length (in bytes) of the data
		
		public function BspLump()
		{
			
		}
	}
}
