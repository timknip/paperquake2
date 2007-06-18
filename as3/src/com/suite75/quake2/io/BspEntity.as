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
	import mx.utils.StringUtil;
	
	import org.papervision3d.core.geom.Vertex3D;
	import com.suite75.quake2.io.BspLump;
	
	public class BspEntity
	{
		public var classname:String;
		public var message:String;
		public var nextmap:String;
		public var sounds:int;
		public var origin:Vertex3D;
		public var angles:Vertex3D;
		public var noise:String;
		public var spawnflags:int;
		public var speed:int;
		public var model:String;
		public var light:int;
		public var angle:int = 0;
		public var lip:int;
		public var minlight:Number;
		public var target:String;
		
		/**
		 * constructor.
		 * 
		 * @param	pEntity
		 */
		public function BspEntity( pEntity:String )
		{
			var lines:Array = pEntity.split( "\n" );
			for( var j:int = 0; j < lines.length; j++ )
			{
				lines[j] = StringUtil.trim( lines[j] );
				var words:Array = lines[j].split( "\" \"" );
				
				words[0] = words[0].substr(1);
				if( words[1] )
					words[1] = words[1].substr(0, words[1].length-1);					
				lines[j] = words;
			}
			parseEntity( lines );
		}
		
		/**
		 * 
		 * @param	pEntity
		 */
		private function parseEntity( pEntityLines:Array ):void
		{
			for( var i:int = 0; i < pEntityLines.length; i++ )
			{
				switch( pEntityLines[i][0] )
				{
					case "classname":
						this.classname = pEntityLines[i][1];
						break;
					
					case "message":
						this.message = pEntityLines[i][1];
						break;
					
					case "nextmap":
						this.nextmap = pEntityLines[i][1];
						break;
					
					case "origin":
						this.origin = parseVector( pEntityLines[i][1] );
						break;
					
					case "sounds":
						this.sounds = parseInt( pEntityLines[i][1], 10 );
						break;
					
					case "angles":
						this.angles = parseVector( pEntityLines[i][1] );
						break;
					
					case "noise":
						this.noise = pEntityLines[i][1];
						break;
						
					case "spawnflags":
						this.spawnflags = parseInt( pEntityLines[i][1], 10 );
						break;
					
					case "light":
						this.light = parseInt( pEntityLines[i][1], 10 );
						break;
					
					case "angle":
						this.angle = parseInt( pEntityLines[i][1], 10 );
						break;
					
					case "speed":
						this.speed = parseInt( pEntityLines[i][1], 10 );
						break;
						
					case "model":
						this.model = pEntityLines[i][1];
						break;
					
					case "_minlight":
						this.minlight = parseFloat(pEntityLines[i][1]);
						break;
					
					case "target":
						this.target = pEntityLines[i][1];
						break;
					
					case "lip":
						this.lip = parseInt( pEntityLines[i][0], 10 );
						break;
						
					case "":
						break;
						
					default:
						//trace( "unknown: " + pEntityLines[i][0] + " => " + pEntityLines[i][1] );
						break;
				}
			}
		}
		
		/**
		 * 
		 * @param	pString
		 * @return
		 */
		private function parseVector( pString:String ):Vertex3D
		{
			pString = StringUtil.trim( pString );
			var v:Vertex3D = new Vertex3D();
			var parts:Array = pString.split( " " );
			if( parts.length == 3 )
			{
				v.x = parseFloat( StringUtil.trim(parts[0]) );
				v.y = parseFloat( StringUtil.trim(parts[1]) );
				v.z = parseFloat( StringUtil.trim(parts[2]) );
			}
			return v;
		}
	}
}
