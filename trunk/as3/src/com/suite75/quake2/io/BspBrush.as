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
	
	public class BspBrush
	{
		// contents flags are seperate bits
		// a given brush can contribute multiple content bits
		// multiple brushes can be in a single leaf
		// lower bits are stronger, and will eat weaker brushes completely
		public static const CONTENTS_SOLID:uint			= 1; // an eye is never valid in a solid
		public static const CONTENTS_WINDOW:uint 		= 2; // translucent, but not watery
		public static const CONTENTS_AUX:uint 			= 4;
		public static const CONTENTS_LAVA:uint 			= 8;
		public static const CONTENTS_SLIME:uint 	  	= 16;
		public static const CONTENTS_WATER:uint			= 32;
		public static const CONTENTS_MIST:uint 			= 64;
		public static const LAST_VISIBLE_CONTENTS:uint 	= 64;
				
		public static const SURF_LIGHT:uint		= 0x1;		// value will hold the light strength
		public static const SURF_SLICK:uint		= 0x2;		// effects game physics
		public static const SURF_SKY:uint		= 0x4;		// don't draw, but add to skybox
		public static const SURF_WARP:uint		= 0x8;		// turbulent water warp
		public static const SURF_TRANS33:uint	= 0x10;
		public static const SURF_TRANS66:uint	= 0x20;
		public static const SURF_FLOWING:uint	= 0x40;	// scroll towards angle
		public static const SURF_NODRAW:uint 	= 0x80;	// don't bother referencing the texture

		public var firstside:int;	// [int32]
		public var numsides:int;	// [int32]
		public var contents:int;	// [int32]
		
		public function BspBrush()
		{
			
		}
	}
}
