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
 
package
{
	// Import Papervision3D
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.scenes.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.events.*;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.suite75.quake2.events.ClusterChangeEvent;
	import com.suite75.papervision3d.objects.Quake2Bsp;
	import com.suite75.papervision3d.scenes.ClipDisplayObject3D;

	
	import d3s.net.util.FPSCounter;
	
	import com.theriabook.utils.Logger;
	
	[SWF(width='800',height='600',backgroundColor='0x000000',frameRate='120')]

	public class App extends Sprite
	{
		[Embed (source="../deploy/che.jpg")]
		public var cheClass:Class;
		
		/**
		 * 
		 */
		public function App()
		{
			init();
		}
		
		/**
		 * 
		 */
		private function init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = "LOW";
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			
			// Create canvas movieclip and center it
			this._container = new Sprite();
			addChild( this._container );
			this._container.x = 400;
			this._container.y = 300;
			
			// Create _scene
			this._scene = new Scene3D( this._container );
			
			_status = new TextField();
			var tf:TextFormat = new TextFormat( "Arial", 10, 0xff0000 );
			tf.size = 12;
			
			_status.defaultTextFormat = tf;
			_status.multiline = true;
			_status.width = 300;
			_status.height = 30;
			_status.selectable = false;
			this.addChild( _status );
			
			_status.x = 5;
			_status.y = 20;
			_status.text = "";
					
			var fps:FPSCounter = new FPSCounter();
			addChild( fps );
			fps.x = 5;
			
			_crossHair = new Sprite();
			addChild( _crossHair );
			_crossHair.x = 400;
			_crossHair.y = 300;
			
			_crossHair.graphics.lineStyle( 1, 0xff0000 );
			_crossHair.graphics.moveTo( -5, 0 );
			_crossHair.graphics.lineTo( 5, 0 );
			_crossHair.graphics.moveTo( 0, 5 );
			_crossHair.graphics.lineTo( 0, -5 );
			
			_maps = [
				"q2dm1 The Edge",
				"q2dm2 Tokay's Towers",
				"q2dm3 The Frag Pipe",
				"q2dm4 Lost Hallways",
				"q2dm5 The Pits",
				"q2dm6 Lava Tomb",
				"q2dm7 The Slimy Place",
				"q2dm8 WareHouse"				
			];
			
			_startMouse = new Vertex3D();
			
			// Create _camera
			this._camera = new FreeCamera3D();
			
			//test();
			
			var bitmap:Bitmap = new cheClass() as Bitmap;
			var material:BitmapMaterial = new BitmapMaterial( bitmap.bitmapData );
			
			loadMap();
		}
		
		
		private function test():void
		{
			var bitmap:Bitmap = new cheClass() as Bitmap;
			var material:BitmapMaterial = new BitmapMaterial( bitmap.bitmapData );
			material.doubleSided = true;
			//material.lineColor = 0x000000;
			//material.lineAlpha = 1.0;
			
			var uv0:NumberUV = new NumberUV(0,0);
			var uv1:NumberUV = new NumberUV(1,0);
			var uv2:NumberUV = new NumberUV(1,1);
			
			var p0:Vertex3D = new Vertex3D();
			var p1:Vertex3D = new Vertex3D(100);
			var p2:Vertex3D = new Vertex3D(100,100);
			
			var mesh:Mesh3D = new Mesh3D(material, [p0, p1, p2], [] );
			mesh.geometry.faces.push( new Face3D([p0,p1,p2], null, [uv0,uv1,uv2]) );
			
			this._scene.addChild( mesh );
			
			stage.addEventListener( Event.ENTER_FRAME, loop3D );
		}
		/**
		 * 
		 * @param	event
		 */
		private function readerProgressHandler(event:ProgressEvent):void
		{
			var perc:int = Math.round((event.bytesLoaded/event.bytesTotal) * 100);
			
			_status.text = "loading '" + _maps[_curMap] + "' " + perc + "% done";
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function init3D(event:Event):void
		{				
			_status.text = "level '" + _maps[_curMap] + "' loaded.";			
						
			// move _camera to spawn point
			var spawn:Vertex3D = _map.getRandomSpawnPoint();			
			_camera.x = spawn.x;
			_camera.y = spawn.y;
			_camera.z = spawn.z + 32;
			_camera.rotationX = -90;
			
			_camera.zoom = 5;
			_camera.focus = 60;
						
			//_mapObj = new ClipDisplayObject3D( "quake2-display-object", _map );
			
			this._scene.addChild( _map, "quake-level" );
			
			//this._scene.renderCamera( _camera );
			
			if(ExternalInterface.available) 
			{
				var msg:Array = [
					"faces: " + _map.reader.faces.length,
					"verts: " + _map.reader.vertices.length,
					"textures: " + _map.reader.textures.length,
					"active faces: " + _map.geometry.faces.length,
					"active verts: " + _map.geometry.vertices.length
				];
				ExternalInterface.call( "showMapStats", msg );
			}
			
			_map.addEventListener( ClusterChangeEvent.CLUSTER_CHANGE, clusterChangeHandler );
			//stage.addEventListener( Event.ENTER_FRAME, loop3D );
			this._scene.renderCamera( _camera );
		}
	
		
		private function clusterChangeHandler( event:ClusterChangeEvent ):void
		{
			if(ExternalInterface.available) 
			{
				var msg:Array = [
					"cluster: " + event.cluster,
					"faces: " + _map.reader.faces.length,
					"verts: " + _map.reader.vertices.length,
					"textures: " + _map.reader.textures.length,
					"active faces: " + _map.geometry.faces.length,
					"active verts: " + _map.geometry.vertices.length
				];
				ExternalInterface.call( "showMapStats", msg );
			}			
		}
		
		private function loadMap( mapID:uint = 0 ):void
		{
			if( mapID == _curMap ) return;
			
			if( _map )
			{
				stage.removeEventListener( Event.ENTER_FRAME, loop3D );
				this._scene.removeChildByName( "quake-level" );
			}
			
			_curMap = mapID < _maps.length ? mapID : _curMap;

			var mapName:String = _maps[_curMap].split(" ")[0];
			
			_map = new Quake2Bsp( this._scene, "baseq/maps/" + mapName + ".bsp" );
			_map.addEventListener( Event.COMPLETE, init3D );
			_map.addEventListener( ProgressEvent.PROGRESS, readerProgressHandler );
		}
		
		/**
		 * loop3D.
		 * 
		 * @param	event
		 */
		private function loop3D(event:Event):void
		{
			//this._camera.rotationZ++;
			this._scene.renderCamera( _camera );
			
		}
		
		/**
		 * mouseDown handler.
		 * 
		 * @param	event
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			_startMouse = new Vertex3D( event.stageX, event.stageY );
			_editMode = 1;
		}

		/**
		 * mouseUp handler.
		 * 
		 * @param	event
		 */
		private function mouseUpHandler(event:MouseEvent):void
		{
			_editMode = 0;
		}		
		
		/**
		 * mouseMove handler.
		 * 
		 * @param	event
		 */
		private function mouseMoveHandler(event:MouseEvent):void
		{
			var dx:Number = _startMouse.x - event.stageX;
			var dy:Number = _startMouse.y - event.stageY;
			
			if( _editMode )
			{
				_camera.rotationX += dy;
				_camera.rotationZ += dx;	
				this._scene.renderCamera( _camera );
			}
			_startMouse = new Vertex3D( event.stageX, event.stageY );
			event.updateAfterEvent();
		}
		
		
		/**
		 * keyDown handler.
		 * 
		 * @param	event
		 */
		private function keyDownHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{				
				case 65: // a
					_camera.moveLeft( 10 );
					break;
					
				case 67: // c
					_mapObj.useClipping = !_mapObj.useClipping;
					break;
				
				case 68: // d
					_camera.moveRight( 10 );
					break;
				
				case 83: // s
					_camera.moveBackward( 10 );
					break;
					
				case 87: // w
					_camera.moveForward( 10 );
					break;
					
				default:
					break;
			}		
			
			var collision:uint = _map.doesCollide(new Vertex3D(_camera.x, _camera.y, _camera.z));
			
			if( collision )
			{
				switch( event.keyCode )
				{
					case 65: // a
						_camera.moveRight( 10 );
						break;
					
					case 68: // d
						_camera.moveLeft( 10 );
						break;
						
					case 83: // s
						_camera.moveForward( 10 );
						break;
						
					case 87: // w
					default:
						_camera.moveBackward( 10 );
						break;
				}
				
				_status.text = _map.getCollisionString( collision );
			}
			else
				_status.text = "";
				
			_map.updatePosition( _camera );
			//Papervision3D.log( "pos: " + _camera.x + "," + _camera.y + "," + _camera.z );
			
			this._scene.renderCamera( _camera );
			
			event.updateAfterEvent();
		}
		
		/**
		 * keyUp handler.
		 * 
		 * @param	event
		 */
		private function keyUpHandler(event:KeyboardEvent):void
		{
			Logger.debug( event.keyCode );
			
			switch(event.keyCode)
			{
				case 49: // 1
					loadMap( 0 );
					break;
			
				case 50: // 2
					loadMap( 1 );
					break;
				
				case 51: // 3
					loadMap( 2 );
					break;
					
				case 52: // 4
					loadMap( 3 );
					break;
					
				case 53: // 5
					loadMap( 4 );
					break;
					
				case 54: // 6
					loadMap( 5 );
					break;
					
				case 55: // 7
					loadMap( 6 );
					break;
				
				case 56: // 8
					loadMap( 7 );
					break;
				
				case 67: // c
					break;
					
				default:
					break;
			}
			this._scene.renderCamera( _camera );
		}
		
		private var _mapObj:*;
		private var _container:Sprite;		// papervision3D drawto sprite
		private var _camera:FreeCamera3D;	// papervision3D camera
		private var _scene:Scene3D;			// papervision3D scene
		private var _map:Quake2Bsp;			// the Q2 map as Mesh3D
		private var _status:TextField;		// status
		
		private var _maps:Array;
		private var _curMap:int = -1;
		
		private var _editMode:uint = 0;
		private var _startMouse:Vertex3D;
		
		private var _crossHair:Sprite;
	}
}
