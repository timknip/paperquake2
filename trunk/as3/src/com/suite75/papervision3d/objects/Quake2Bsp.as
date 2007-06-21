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
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import com.suite75.papervision3d.objects.ClipFace3D;
	import com.suite75.papervision3d.objects.ClippedMesh;
	import com.suite75.papervision3d.utils.Triangulate;
	import com.suite75.quake2.events.ClusterChangeEvent;
	import com.suite75.quake2.io.*;
	import com.suite75.quake2.io.wal.WALReader;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.*;
	import org.papervision3d.scenes.*;
	
	/**
	 * class Quake2Bsp.
	 * 
	 * <p></p>
	 */
	public class Quake2Bsp extends ClippedMesh
	{
		public static const BLOCK_WIDTH:Number = 128;
		public static const BLOCK_HEIGHT:Number = 128;
		public static const LIGHTMAP_BYTES:uint = 4;
		
		public var filename:String;
		public var paletteFile:String;
		
		public var materialsAdded:Boolean;
		
		/**
		 * 
		 * @param	filename
		 */
		public function Quake2Bsp( scene:Scene3D, filename:String = "baseq/maps/q2dm1.bsp", paletteFile:String = "baseq/textures/POLY.PAL" )
		{
			super( null, [], [] );
			
			this._scene = scene;
				
			this.materialsAdded = false;
			this.filename = filename;
			this.paletteFile = paletteFile;
			this._curCluster = -1;
			
			this._reader = new BspReader( this.filename, this.paletteFile );
			this._reader.addEventListener( FileLoadEvent.LOAD_COMPLETE, readerCompleteHandler );
			this._reader.addEventListener( FileLoadEvent.LOAD_ERROR, readerErrorHandler );
			this._reader.addEventListener( ProgressEvent.PROGRESS, readerProgressHandler );
			this._reader.load();
		}
		
		public function get reader():BspReader { return _reader; }
		
		/**
		 * 
		 * @param	scene
		 */
		public override function render( scene:SceneObject3D ):void
		{
			if( !this.materialsAdded )
			{
				try
				{
					addMaterials();
				}
				catch( e:Error )
				{
					
				}
			}
			super.render( scene );
		}
		
		public function updatePosition( camera:CameraObject3D ):void 
		{
			var camPos:Vertex3D = new Vertex3D( camera.x, camera.y, camera.z );
			
			var vis:BspVisInfo = makeVisible( camPos  );
			if( vis is BspVisInfo )
			{
				makeWorldFaces( vis );	
			}
		}
		
		/**
		 * 
		 * @return
		 */
		public function getRandomSpawnPoint():Vertex3D
		{
			var ent:BspEntity = this._reader.entities.findEntityByClassName("info_player_start");
			
			var camPos:Vertex3D = new Vertex3D( ent.origin.x, ent.origin.y, ent.origin.z );
			camPos.z += 0.01;
			
			return camPos;
		}
				
		/**
		 * 
		 * @param	point
		 * @return
		 */
		private function findLeaf( point:Vertex3D ):int
		{
			var idx:int = BspModel( this._reader.models[0] ).headnode;
			var pt:Number3D = new Number3D( point.x, point.y, point.z );
			
			while( idx >= 0 )
			{
				var node:BspNode = this._reader.nodes[idx] as BspNode;
				var plane:BspPlane = this._reader.planes[node.plane];	
				var dot:Number = Number3D.dot(plane.normal, pt) - plane.d;
				idx = dot >= 0 ? node.front_child : node.back_child;
			}
			return -(idx+1);
		}
		
		/**
		 * 
		 * @param	collision
		 * @return
		 */
		public function getCollisionString( collision:uint ):String 
		{
			if( collision == BspBrush.CONTENTS_WATER )
				return "WATER!";
			else if( collision == BspBrush.CONTENTS_LAVA )
				return "LAVA!";
			else if( collision == BspBrush.CONTENTS_SLIME )
				return "SLIME!";
			else if( collision == BspBrush.CONTENTS_MIST )
				return "MIST!";
			else if( collision == BspBrush.CONTENTS_AUX )
				return "AUX!";
			else if( collision == BspBrush.CONTENTS_SOLID )
				return "SOLID!";
			else if( collision == BspBrush.CONTENTS_WINDOW )
				return "WINDOW!";
			else if( collision == BspBrush.LAST_VISIBLE_CONTENTS )
				return "LAST_VISIBLE_CONTENTS!";
			else
				return "";
		}
		
		/**
		 * do we have a collision for a certain camera position?
		 * 
		 * @param	point
		 * @return
		 */
		public function doesCollide( camPos:Vertex3D ):uint
		{
			var leafID:int = findLeaf( camPos );
			var leaf:BspLeaf = this._reader.leaves[leafID];
			
			if( leaf.brush_or & BspBrush.CONTENTS_WATER )
			{
				return BspBrush.CONTENTS_WATER;
			}
			else if( leaf.brush_or & BspBrush.CONTENTS_LAVA )
			{
				return BspBrush.CONTENTS_LAVA;
			}
			else if( leaf.brush_or & BspBrush.CONTENTS_SLIME )
			{
				return BspBrush.CONTENTS_SLIME;
			}
			else if( leaf.brush_or & BspBrush.CONTENTS_MIST )
			{
				return BspBrush.CONTENTS_MIST;
			}
			else if( leaf.brush_or & BspBrush.CONTENTS_AUX )
			{
				return BspBrush.CONTENTS_AUX;
			}
			else if( leaf.brush_or & BspBrush.CONTENTS_SOLID )
			{
				return BspBrush.CONTENTS_SOLID;
			}
			else if( leaf.brush_or & BspBrush.CONTENTS_WINDOW )
			{
				return BspBrush.CONTENTS_WINDOW;
			}
			else if( leaf.brush_or & BspBrush.LAST_VISIBLE_CONTENTS )
			{
				return BspBrush.LAST_VISIBLE_CONTENTS;
			}
			return 0;
		}
		
		/**
		 * 
		 */
		private function makeVisible( camPos:Vertex3D ):BspVisInfo
		{
			_curLeaf = findLeaf( camPos );
			var leaf:BspLeaf = this._reader.leaves[_curLeaf];
			
			if( leaf.cluster < 0 || leaf.cluster == _curCluster ) return null;
						
			_curCluster = leaf.cluster;
			
			var lump:BspLump = this._reader.header.lump[BspLump.VISIBILITY] as BspLump;
			
			var num:int = (this._reader.visibility.num_clusters+7) >> 3;
			
			var offset:BspVisOffset = this._reader.visibility.clusters[leaf.cluster] as BspVisOffset;
			
			var src:uint = lump.offset + offset.pvs;
			var dest:uint = 0;
			
			var vis:BspVisInfo = new BspVisInfo();
			
			while( num > 0 )
			{
				this._reader.bspData.position = src;
				
				var a:uint = this._reader.bspData[src];
				
				if( a )
				{
					vis.visible_clusters[dest]  = a;
					dest++;
					src++;
					num--;
				}
				else
				{
					a = this._reader.bspData[src+1];
					if( num < a ) { 	}
					else { 	}
					num -= a;
					dest += a;
					src += 2;
				}
			}
			
			if( leaf.area < 0 )
			{
				Papervision3D.log( "ALL VISIBLE" );
			}
			
			_visibleAreas = new Array();
			makeVisibleAreas( leaf.area );
			
			dispatchEvent( new ClusterChangeEvent(ClusterChangeEvent.CLUSTER_CHANGE, _curCluster) );
			
			return vis;
		}
				
		/**
		 * 
		 * @param	areaID
		 */
		private function makeVisibleAreas( areaID:uint ):void 
		{
			_visibleAreas[areaID] = 1;
			
			// Walk thru all portals of this area
			var area:BspArea = this._reader.areas[areaID];
				
			for( var i:int = 0; i < area.num_areaportals; i++ )
			{
				var ap:BspAreaPortal = this._reader.portals[area.first_areaportal+i] as BspAreaPortal;
				if( ap is BspAreaPortal )
				{
					if( !_visibleAreas[ap.other_area] )
						makeVisibleAreas( ap.other_area );
				}
			}
		}
		
		/**
		 * 
		 */
		private function addMaterials():void
		{
			this.materials = new MaterialsList();
			
			var added:Object = new Object();

			for( var i:int = 0; i < this._reader.textures.length; i++ )
			{				
				var texinfo:BspTexInfo = this._reader.textures[i];
				var wal:WALReader = this._reader.wals[texinfo.texture];
			
				if( added[texinfo.texture] is String ) continue;

				if( !(this._reader.bitmaps[wal.header.name] is BitmapData) )
					throw new Error("no bm!");
					
				var material:BitmapMaterial = new BitmapMaterial( this._reader.bitmaps[wal.header.name] );
				//var material:ColorMaterial = new ColorMaterial();
				//var material:WireframeMaterial = new WireframeMaterial();
				//material.lineAlpha = 1.0;
				
				this.materials.addMaterial( material, texinfo.texture );
				
				added[texinfo.texture] = texinfo.texture;
			}
			
			this.materialsAdded = true;
		}
		
		/**
		 * 
		 * @param	visInfo
		 * @return
		 */
		private function makeWorldFaces( visInfo:BspVisInfo ):void
		{
			this.geometry.faces = new Array();
			this.geometry.vertices = new Array();

			var vis_byte:int;
			var vis_mask:int;
			var allreadyViz:Object = new Object();
			
			var spawn:Vertex3D = getRandomSpawnPoint();
			
			for( var i:int = 0; i < this._reader.leaves.length; i++ )
			{
				var leaf:BspLeaf = this._reader.leaves[i] as BspLeaf;
				
				vis_byte = visInfo.visible_clusters[leaf.cluster >> 3];
				vis_mask = 1 << (leaf.cluster & 7);
				
				if( vis_byte & vis_mask && this._visibleAreas[leaf.area]  ) 
				{
					for( var j:int = 0; j < leaf.num_leaf_faces; j++ )
					{
						var fidx:uint = this._reader.leave_faces[leaf.first_leaf_face + j];
						
						// prevent doubles
						if( allreadyViz[fidx] is uint )	continue;
						allreadyViz[fidx] = fidx;
						
						var f:BspFace = this._reader.faces[fidx] as BspFace;
						var plane:BspPlane = this._reader.planes[f.plane];
												
						// Setup texturing stuff
						var texinfo:BspTexInfo = this._reader.textures[f.texture_info];
						var wal:WALReader = this._reader.wals[texinfo.texture];

						var fs:Number = 1.0/wal.header.width;
						var ft:Number = 1.0/wal.header.height;
						
						var points:Array = new Array();
						var uvs:Array = new Array();
						var coords:Array = new Array();
						
						var tri:Array = new Array();
						
						for( var k:int = 0; k < f.num_edges; k++ )
						{
							var idx:int = this._reader.face_edges[f.first_edge+k];
							var edge_idx:int = idx < 0 ? -idx : idx;
							var edge:Array = this._reader.edges[edge_idx];

							var coord:int = idx < 0 ? edge[1] : edge[0];
						
							var pt:Number3D = new Number3D( this._reader.vertices[coord].x, this._reader.vertices[coord].y, this._reader.vertices[coord].z );							
							
							var u:Number3D = new Number3D( texinfo.u_axis.x, texinfo.u_axis.y, texinfo.u_axis.z );
							var v:Number3D = new Number3D( texinfo.v_axis.x, texinfo.v_axis.y, texinfo.v_axis.z );
							
							var uv:NumberUV = new NumberUV(
								Number3D.dot(pt, u) + texinfo.u_offset,
								-Number3D.dot(pt, v) + texinfo.v_offset
							);
	
							var pidx:uint = points.push(this._reader.vertices[coord]) - 1;
							
							coords.push( pidx );
							uvs.push( uv );
						}
						
						var lightmap:BitmapData = fixUV( f, uvs, texinfo );
						
						//Papervision3D.log( "====" );
						//this.geometry.vertices = this.geometry.vertices.concat( points );
						
						var triangles:Array = Triangulate.triangulate( coords, points );
						
						for( var m:int = 0; m < triangles.length; m++ )
						{
							var p0:Vertex3D = points[triangles[m][0]];
							var p1:Vertex3D = points[triangles[m][1]];
							var p2:Vertex3D = points[triangles[m][2]];
							
							this.geometry.vertices.push( p0, p1, p2 );
							
							var uv0:NumberUV = uvs[triangles[m][0]];
							var uv1:NumberUV = uvs[triangles[m][1]];
							var uv2:NumberUV = uvs[triangles[m][2]];
							
							var face:ClipFace3D = new ClipFace3D( [p0, p1, p2], texinfo.texture, [uv0, uv1, uv2], this.viewport, lightmap );
							
							//Papervision3D.log( "material name: " + face.materialName );
							//Papervision3D.log( "material name: " + face.materialName );
							
							this.geometry.faces.push( face );
						}
						
					
					}
				}
			}
			
			Papervision3D.log( "v:" + this.geometry.vertices.length + " f:" + this.geometry.faces.length );
		}
				
		/**
		 * 
		 * @param	face
		 * @param	uvs
		 * @param	w
		 * @param	h
		 */
		private function fixUV( face:BspFace, uvs:Array, texinfo:BspTexInfo ):BitmapData
		{
			face.min_s = face.max_s = uvs[0].u;
			face.min_t = face.max_t = uvs[0].v;
			
			for( var i:int = 1; i < uvs.length; i++ )
			{
				face.min_s = Math.min( face.min_s, uvs[i].u );
				face.min_t = Math.min( face.min_t, uvs[i].v );
				face.max_s = Math.max( face.max_s, uvs[i].u );
				face.max_t = Math.max( face.max_t, uvs[i].v );
			}
			
			face.size_s = face.max_s - face.min_s;
			face.size_t = face.max_t - face.min_t;

			for( var j:int = 0; j < uvs.length; j++ )
			{
				uvs[j].u -= face.min_s;
				uvs[j].v -= face.min_t;
				
				uvs[j].u /= face.size_s;
				uvs[j].v /= face.size_t;
				
				//Papervision3D.log( "uv:"+uvs[j] );
			}
			
			// set the drawing flags
			if( texinfo.flags & BspBrush.SURF_WARP )
			{
				Papervision3D.log( "SURF_WARP " + texinfo.flags );
			}
			
			if( !(texinfo.flags & (BspBrush.SURF_SKY|BspBrush.SURF_TRANS33|BspBrush.SURF_TRANS66|BspBrush.SURF_WARP)) )
			{
			//	Papervision3D.log( "GL_CreateSurfaceLightmap " + texinfo.flags );
			}
			
			if( !(texinfo.flags & BspBrush.SURF_WARP) )
			{
			//	Papervision3D.log( "GL_BuildPolygonFromSurface " + texinfo.flags );
			}
			
			var smax:int = (face.size_s >> 4) + 1;
			var tmax:int = (face.size_t >> 4) + 1;;
			
			var lm:BitmapData = buildLightMap( face, smax, tmax );
			
			return lm;
			//Papervision3D.log( "f:" + face.min_s + ","+face.min_t+","+face.max_s+","+face.max_t+" "+face.size_s+" "+face.size_t );
		}
		
		private function buildLightMap( surf:BspFace, smax:int, tmax:int ):BitmapData
		{
			var i:int, j:int;
			var nummaps:uint = 0;
			var maxsize:int = 34 * 34 * 3;
			var size:int = smax * tmax;
			var lump:BspLump = this.reader.header.lump[BspLump.LIGHTMAPS];
			var data:ByteArray = this.reader.bspData;
			var bitmap:BitmapData = new BitmapData( smax, tmax, true, 0xffffffff );
			
			data.position = lump.offset + surf.lightmap_offset;
			
			for( i = 0; i < 4 && surf.lightmap_styles[i] != 255; i++ )
				nummaps++;

			if( !nummaps )
				return bitmap;
				
			if( size > maxsize )
				throw new Error( "bad block size" );
				
			for( i = 0; i < tmax; i++ )
			{
				for( j = 0; j < smax; j++ )
				{
					var r:uint = data.readUnsignedByte();
					var g:uint = data.readUnsignedByte();
					var b:uint = data.readUnsignedByte();

					var col:uint = (r<<16 | g<<8 | b);
					
					bitmap.setPixel( j, i, col );
				}
			}
			
			return bitmap;
		}
		
		public function transformTex( vertices:Array, plane:BspPlane ):void
		{
			var normal:Number3D = new Number3D( plane.a, plane.b, plane.c );
			var up:Number3D = new Number3D(0,0,1);
			var side:Number3D = Number3D.cross(up, normal);
			
			side.normalize();
			
			up = Number3D.cross(normal, side);
			up.normalize();
			
			var transformation:Matrix3D = new Matrix3D(
				[side.x, side.y, side.z, 0,
				up.x, up.y, up.z, 0,
				normal.x, normal.y, normal.z, 0,
				vertices[0].x, vertices[0].y, vertices[0].z, 1]
			);
			
			var m11 :Number = transformation.n11;
			var m12 :Number = transformation.n12;
			var m13 :Number = transformation.n13;
			var m21 :Number = transformation.n21;
			var m22 :Number = transformation.n22;
			var m23 :Number = transformation.n23;
			var m31 :Number = transformation.n31;
			var m32 :Number = transformation.n32;
			var m33 :Number = transformation.n33;

			var m14 :Number = transformation.n14;
			var m24 :Number = transformation.n24;
			var m34 :Number = transformation.n34;
			
			var i:int = vertices.length;
			var vertex   :Vertex3D;

			Papervision3D.log( "in: " + vertices );
			
			while( vertex = vertices[--i] )
			{
				// Center position
				var vx :Number = vertex.x;
				var vy :Number = vertex.y;
				var vz :Number = vertex.z;
				
				var tx :Number = vx * m11 + vy * m12 + vz * m13 + m14;
				var ty :Number = vx * m21 + vy * m22 + vz * m23 + m24;
				var tz :Number = vx * m31 + vy * m32 + vz * m33 + m34;

				vertex.x = tx;
				vertex.y = ty;
				vertex.z = tz;
			}
			
			Papervision3D.log( "out: " + vertices );
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function readerCompleteHandler(event:FileLoadEvent):void
		{			
			var ent:BspEntity = this._reader.entities.findEntityByClassName("info_player_start");
			
			var camPos:Vertex3D = new Vertex3D( ent.origin.x, ent.origin.y, ent.origin.z );
			
			var vis:BspVisInfo = makeVisible( camPos  );
			if( vis is BspVisInfo )
				makeWorldFaces( vis );	
		
			try
			{
				addMaterials();
			}
			catch( e:Error )
			{
				
			}
			dispatchEvent( new Event(Event.COMPLETE) );
		}

		/**
		 * 
		 * @param	event
		 */
		private function readerErrorHandler(event:FileLoadEvent):void
		{
			
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function readerProgressHandler(event:ProgressEvent):void
		{
			dispatchEvent( event );
			//Papervision3D.log( _reader.progressText + " " + event.bytesLoaded + " of " + event.bytesTotal );
		}
		
		private var _reader:BspReader; 
		private var _curLeaf:int;
		private var _curCluster:int;
		private var _visibleAreas:Array;
		private var _scene:Scene3D;
		
	}
}
