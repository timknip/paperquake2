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
 *
 */
  
package com.suite75.quake2.io.wal
{	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.*;
		
	import org.papervision3d.Papervision3D;
	import org.papervision3d.events.FileLoadEvent;
	
	import com.suite75.quake2.io.wal.WALHeader;
	
	 /** 	
	  * class WALReader.
	  * 
	  * <p>WAL textures are stored in a 8-bit indexed color format with a specific palette being used by all 
	  * textures (this palette is stored in the PAK data file that comes with Quake 2). 
	  * Four mip-map levels are stored for each texture at sizes decreasing by a factor of two. 
	  * This is mostly for software rendering since most 3D APIs will automatically generate the mip-map 
	  * levels when you create a texture. Each frame of an animated texture is stored as an individual 
	  * WAL file, and the animation sequence is encoded by storing the name of the next texture in 
	  * the sequence for each frame; texture names are stored with paths and without any extension.</p>
	  */	
	public class WALReader extends EventDispatcher
	{
		public var header:WALHeader;		
		public var data:ByteArray;
		public var bm:BitmapData;
		
		/**
		 * 
		 */
		public function WALReader( filename:String )
		{
			this._filename = filename;
			
			this._loader = new URLLoader();
			this._loader.dataFormat = URLLoaderDataFormat.BINARY;
			this._loader.addEventListener( Event.COMPLETE, completeHandler );
			this._loader.addEventListener( IOErrorEvent.IO_ERROR, errorHandler );
			this._loader.load( new URLRequest( this._filename ) );		
			
		}
		
		public function get filename():String { return _filename; }
		
		/**
		 * 
		 * @param	event
		 */
        private function completeHandler(event:Event):void 
		{			
			var loader:URLLoader = event.target as URLLoader;
			this.data = loader.data as ByteArray;
			
			this.data.endian = Endian.LITTLE_ENDIAN;
			
			this.header = new WALHeader();
			this.header.read( this.data );
			
			var fileEvent:FileLoadEvent = new FileLoadEvent( FileLoadEvent.LOAD_COMPLETE, _filename );
			this.dispatchEvent( fileEvent );
		}
		
		/**
		 * 
		 * @param	event
		 */
        private function errorHandler(event:IOErrorEvent):void 
		{
			Papervision3D.log( event.type + ": "+ event.text );
			var fileEvent:FileLoadEvent = new FileLoadEvent( FileLoadEvent.LOAD_ERROR, _filename );
			this.dispatchEvent( fileEvent );
		}
		
		private var _filename:String;
		private var _loader:URLLoader;
	}
}
