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
 
 
package com.suite75.quake2.io.pal
{	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.*;
		
	import org.papervision3d.Papervision3D;
	import org.papervision3d.events.FileLoadEvent;
	
	public class PALReader extends EventDispatcher
	{
		public var palette:ByteArray;
		public var texpal:Array;
		
		/**
		 * 
		 */
		public function PALReader( filename:String )
		{
			this._filename = filename;
			
			this._loader = new URLLoader();
			this._loader.dataFormat = URLLoaderDataFormat.BINARY;
			this._loader.addEventListener( Event.COMPLETE, completeHandler );
			this._loader.addEventListener( IOErrorEvent.IO_ERROR, errorHandler );
			this._loader.load( new URLRequest( this._filename ) );
		}
		
		/**
		 * 
		 * @param	event
		 */
        private function completeHandler(event:Event):void 
		{			
			var loader:URLLoader = event.target as URLLoader;
			var ba:ByteArray = loader.data as ByteArray;
			
			this.palette = new ByteArray();
			this.palette.writeBytes( ba, 0, 768 );
			this.palette.endian = Endian.LITTLE_ENDIAN;
			
			// Texture gamma hack
			this.texpal = new Array();
			for( var i:int = 0; i < 768; i++) 
			{
				var a:uint = this.palette[i];
				a *= 2;
				if( a > 255 ) a = 255;
				texpal[i] = a;
			}
			
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
