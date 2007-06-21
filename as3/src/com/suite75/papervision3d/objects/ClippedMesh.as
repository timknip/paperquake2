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
 
package com.suite75.papervision3d.objects
{
	import com.suite75.papervision3d.cameras.FrustumCamera3D;
	import com.suite75.papervision3d.objects.ClipFace3D;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.Papervision3D;
	
	import org.papervision3d.core.Matrix3D;
	import org.papervision3d.core.geom.Mesh3D;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * 
	 */
	public class ClippedMesh extends Mesh3D
	{
		public static const DEFAULT_VIEWPORT:Rectangle = new Rectangle(-160, -120, 320, 240);
		
		public var viewport:Rectangle;
		
		public var enableLightmaps:Boolean;
		
		/**
		 * 
		 * @param	material
		 * @param	vertices
		 * @param	faces
		 * @param	name
		 * @param	initObject
		 */
		public function ClippedMesh( material:MaterialObject3D, vertices:Array, faces:Array, name:String=null, initObject:Object=null ):void
		{
			super( material, vertices, faces, name, initObject );
			
			this.viewport = DEFAULT_VIEWPORT;
			
			this.enableLightmaps = true;
		}
		
		/**
		 * 
		 * @param	parent
		 * @param	camera
		 * @param	sorted
		 * @return
		 */
		public override function project( parent :DisplayObject3D, camera :CameraObject3D, sorted :Array=null ):Number
		{
			// Vertices
			super.project( parent, camera, sorted );

			if( ! sorted ) sorted = this._sorted;

			var projected:Dictionary = this.projected;
			var view:Matrix3D = this.view;

			// Faces
			var faces        :Array  = this.geometry.faces;
			var iFaces       :Array  = this.faces;
			var screenZs     :Number = 0;
			var visibleFaces :Number = 0;
			var needClip	 :Boolean = false;
			var outside		 :Boolean = false;
			var numinside	 :uint = 0;
			
			var vertex0 :Vertex2D, vertex1 :Vertex2D, vertex2 :Vertex2D, visibles:Number, iFace:Object, face:Face3D;

			for( var i:int=0; face = faces[i]; i++ )
			{
				iFace = iFaces[i] || (iFaces[i] = {});
				iFace.face = face;
				iFace.instance = this;
				
				if( face is ClipFace3D )
					ClipFace3D(face).enableLightmaps = this.enableLightmaps;
				
				vertex0 = projected[ face.vertices[0] ];
				vertex1 = projected[ face.vertices[1] ];
				vertex2 = projected[ face.vertices[2] ];
				
				visibles = Number(vertex0.visible) + Number(vertex1.visible) + Number(vertex2.visible);
				iFace.visible = ( this.enableLightmaps || visibles == 3 );
				
				if( iFace.visible )
				{
					if( camera is FrustumCamera3D )
					{
						var cam:FrustumCamera3D = camera as FrustumCamera3D;
						
						var t:Boolean = cam.test( [face.vertices[0], face.vertices[1], face.vertices[2]] );
					
						if( !t )
						{
							iFace.visible = false;
						}
					}
				}
				
				if( iFace.visible )
				{
					screenZs += iFace.screenZ = ( vertex0.z + vertex1.z + vertex2.z ) /3;
					visibleFaces++;
				
					if( sorted ) sorted.push( iFace );	
				}
			}

			return this.screenZ = screenZs / visibleFaces;
		}
		
		/**
		 * 
		 * @param	scene
		 */
		public override function render( scene:SceneObject3D ):void
		{
			if( !scene.container.getChildByName("mymesh") )
			{
				this.container = new Sprite();
				
				var obj:DisplayObject = this.container.addChild( new Sprite() );
				obj.name = "lightmaps";
				obj.blendMode = BlendMode.OVERLAY;
				
				scene.container.addChild( this.container );
				
				var masker:Shape = new Shape();
				
				this.container.addChild( masker );
				masker.name = "masker";
				
				this.container.name = "mymesh";
				
				this.container.mask = masker;
				
				masker.graphics.beginFill( 0xffff00 );
				masker.graphics.lineStyle();
				masker.graphics.drawRect( this.viewport.x, this.viewport.y, this.viewport.width, this.viewport.height );
				masker.graphics.endFill();
			}
			
			if( this.container )
			{
				this.container.graphics.clear();
				Sprite(this.container.getChildAt(0)).graphics.clear();
			}
			
			super.render( scene );

			var graphics:Graphics = this.container.graphics;
			
			graphics.lineStyle( 3, 0xff0000 );
			graphics.drawRect( this.viewport.x, this.viewport.y, this.viewport.width, this.viewport.height );
		}
	}
}
