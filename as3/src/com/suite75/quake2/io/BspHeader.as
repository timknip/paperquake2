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
	
	import com.suite75.quake2.io.*;
	
	public class BspHeader
	{
		public var magic:uint;		// magic number ("IBSP")
		public var version:uint;	// version of the BSP format (38)
		public var lump:Array;		// [19] directory of the lumps
		public var vertices:Array;
		public var faces:Array;
		
		function BspHeader()
		{
			
		}
		
		/**
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray ):void
		{
			this.magic = pData.readUnsignedInt();
			this.version = pData.readUnsignedInt();
			
			// read the lumps
			this.lump = new Array(19);
			for( var i:int = 0; i < 19; i++ )
			{
				this.lump[i] = new BspLump();
				this.lump[i].offset = pData.readUnsignedInt();
				this.lump[i].length = pData.readUnsignedInt();
			}
			
			if( !check() )
			{
				throw new Error( "invalid BSP header!" );
			}
		}
		
		/**
		 * 
		 */
		private function check():Boolean
		{
			var a:uint = this.magic & 0x00FF;
			var b:uint = (this.magic >> 8) & 0x000000FF;
			var c:uint = (this.magic >> 16) & 0x000000FF;
			var d:uint = (this.magic >> 24) & 0x000000FF;

			return ( a.toString(16) == "49" && // I
					 b.toString(16) == "42" && // B
					 c.toString(16) == "53" && // S
					 d.toString(16) == "50" ); // P
		}
	}
}