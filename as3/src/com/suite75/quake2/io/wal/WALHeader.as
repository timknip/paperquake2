/**
 *	Suite75 Source Code - Confidential Material
 *	Copyright © 2006 Suite75. All Rights Reserved.
 *
 *	Project: Quake2
 *
 *	@author Tim Knip
 */
 
package com.suite75.quake2.io.wal
{	
	import flash.utils.ByteArray;
	
	public class WALHeader
	{
		public var name:String;		// 32 [char[32]] 
		public var width:uint;		// 36
		public var height:uint;		// 40
		public var offsets:Array;	// 56 [uint32[4]] four mip maps stored
		public var animname:String; // 88 [char[32]] next frame in animation chain
		public var flags:int;		// 92
		public var contents:int;	// 96
		public var value:int;		// 100
		
		/**
		 * 
		 */
		public function WALHeader()
		{
			
		}
		
		/**
		 * size of header.
		 * 
		 * @return
		 */
		public function get size():uint { return 100; }
		
		/**
		 * read the header.
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray ):void
		{
			if( pData is ByteArray )
			{
				//pData.position = 0;
				this.name = pData.readMultiByte( 32, "iso-8859-1" );
				this.width = pData.readUnsignedInt();
				this.height = pData.readUnsignedInt();
				this.offsets = new Array( 4 );
				this.offsets[0] = pData.readUnsignedInt();
				this.offsets[1] = pData.readUnsignedInt();
				this.offsets[2] = pData.readUnsignedInt();
				this.offsets[3] = pData.readUnsignedInt();
				this.animname = pData.readMultiByte( 32, "iso-8859-1" );
				this.flags = pData.readInt();
				this.contents = pData.readInt();
				this.value = pData.readInt();
			}
			else
			{
				throw new Error( "WALHeader#read => invalid data!" );
			}
		}
	}
}