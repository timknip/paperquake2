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
	
	public class BspVisibility
	{
		public var num_clusters:uint; // [uint32] number of clusters in the map
		public var clusters:Array;
		public var cluster_visible:Array;
		
		/**
		 *  
		 */
		public function BspVisibility()
		{
			
		}
		
		/**
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray ):void
		{
			this.num_clusters = pData.readUnsignedInt();
			this.clusters = new Array();
			this.cluster_visible = new Array();
			
			for( var i:int = 0; i < this.num_clusters; i++ )
			{
				var cluster:BspVisOffset = new BspVisOffset();
				cluster.read( pData );
				this.clusters.push( cluster );
				this.cluster_visible[i] = 0;
			}
		}
		
		/**
		 * reads cluster-visibility for a cluster.
		 * 
		 * 	for (int c = 0; c < num_clusters; v++) {
		 *	   if (pvs_buffer[v] == 0) {
		 *		  v++;     
		 *		  c += 8 * pvs_buffer[v];
		 *	   } else {
		 *		  for (uint8 bit = 1; bit != 0; bit *= 2, c++) {
		 *			 if (pvs_buffer[v] & bit) {
		 *				cluster_visible[c] = 1;
		 *		     }
		 *		  }
		 *	   }   
		 *	}
		 * 
		 * @param	pData
		 * @param	pOffset	offset of cluster visibility
		 */
		public function readClusterVisible( pData:ByteArray, pOffset:BspVisOffset ):void
		{
			pData.position = pOffset.pvs;
	
			var v:uint = pData.position;
			var n:int = this.num_clusters;
			
			this.cluster_visible = new Array( n );
			
			for( var c:uint = 0; c < this.num_clusters; v++ )
			{
				if( pData[v] == 0 )
				{
					v++;
					c += 8 * pData[v];
				}
				else
				{
					for( var bit:uint = 1; bit != 0; bit *= 2, c++ )
					{
						if( pData[v] & bit )
						{
							this.cluster_visible[c] = 1;
						}
					}
				}
			}
		}
	}
}
