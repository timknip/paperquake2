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
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.geom.Vertex3D;
	import org.papervision3d.events.FileLoadEvent;

	import com.suite75.quake2.io.*;
	import com.suite75.quake2.io.pal.PALReader;
	import com.suite75.quake2.io.wal.WALReader;
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.*;
	import mx.utils.StringUtil;
	
	public class BspReader extends EventDispatcher
	{
		public var bspData:ByteArray;
		public var header:BspHeader;
		
		public var vertices:Array;
		public var planes:Array;
		public var faces:Array;
		public var nodes:Array;
		public var edges:Array;
		public var face_edges:Array;
		public var leaves:Array;
		public var leave_faces:Array;
		public var models:Array;
		public var areas:Array;
		public var portals:Array;
		public var brushes:Array;
		public var brush_sides:Array;
		public var textures:Array;
		public var texels:Array;
		public var visibility:BspVisibility;
		public var entities:BspEntities;
		public var wals:Object;
		
		public var bitmaps:Object;
		
		public var progressText:String;
		
		/**
		 * constructor.
		 * 
		 * @param	filename
		 * @param	paletteFile
		 */
		public function BspReader( filename:String, paletteFile:String = "baseq/textures/POLY.PAL" )
		{
			this._filename = filename;
			
			progressText = "";
			
			
			loadPAL( paletteFile );
		}

		/**
		 * 
		 */
		private function loadBsp():void
		{
			this._loader = new URLLoader();
			this._loader.dataFormat = URLLoaderDataFormat.BINARY;
			this._loader.addEventListener( Event.COMPLETE, completeHandler );
			this._loader.addEventListener( IOErrorEvent.IO_ERROR, errorHandler );
			this._loader.addEventListener( ProgressEvent.PROGRESS, progressHandler );
			this._loader.load( new URLRequest( this._filename ) );
		}
		
		/**
		 * 
		 */
		private function loadPAL( paletteFile:String ):void
		{
			this._pal = new PALReader( paletteFile );
			this._pal.addEventListener( FileLoadEvent.LOAD_COMPLETE, palCompleteHandler );
			this._pal.addEventListener( FileLoadEvent.LOAD_ERROR, palErrorHandler );
		}
		
		/**
		 * 
		 * @param	event
		 */
        private function completeHandler(event:Event):void 
		{
			//super.completeHandler( event );
			
			this.bspData = this._loader.data as ByteArray;
			this.bspData.endian = Endian.LITTLE_ENDIAN;
			
			this.header = new BspHeader();
			this.header.read( this.bspData );
			
			readVertices( this.bspData );
			readFaces( this.bspData );
			readPlanes( this.bspData );
			readNodes( this.bspData );
			readEdges( this.bspData );
			readFaceEdges( this.bspData );
			readLeaves( this.bspData );
			readLeaveFaces( this.bspData );
			readVisibility( this.bspData );
			readModels( this.bspData );
			readAreas( this.bspData );
			readAreaPortals( this.bspData );
			readEntities( this.bspData );
			readBrushes( this.bspData );
			readBrushSides( this.bspData );
			readTextureInfo( this.bspData );
									
			this.bitmaps = new Object();
			
			if( _texturesToLoad.length )
			{
				loadNextTexture();
			}
			else
			{
				
			}
			
			if( this._debug )
			{
				Papervision3D.log( "BSP version: " + this.header.version );
				Papervision3D.log( "# vertices: " + this.vertices.length );
				Papervision3D.log( "# faces: " + this.faces.length );
				Papervision3D.log( "# planes: " + this.planes.length );
				Papervision3D.log( "# nodes: " + this.nodes.length );
				Papervision3D.log( "# edges: " + this.edges.length );
				Papervision3D.log( "# face edges: " + this.face_edges.length );
				Papervision3D.log( "# leaves: " + this.leaves.length );
				Papervision3D.log( "# leave_faces: " + this.leave_faces.length );
				Papervision3D.log( "# clusters: " + this.visibility.clusters.length );
				Papervision3D.log( "# models: " + this.models.length );
				Papervision3D.log( "# areas: " + this.areas.length );
				Papervision3D.log( "# portals: " + this.portals.length );
				Papervision3D.log( "# brushes: " + this.brushes.length );
				Papervision3D.log( "# brush_sides: " + this.brush_sides.length );
				Papervision3D.log( "# textures: " + this.textures.length );
			}
		}

		/**
		 * 
		 * @param	event
		 */
        private function errorHandler(event:IOErrorEvent):void 
		{
			Papervision3D.log( "error:" + event.text );
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function palCompleteHandler(event:FileLoadEvent):void
		{
			Papervision3D.log( "PAL file loaded" );
			
			loadBsp();
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function palErrorHandler(event:FileLoadEvent):void
		{
			Papervision3D.log( "PAL file failed to load!" );
			
			loadBsp();
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function progressHandler(event:ProgressEvent):void
		{
			//Papervision3D.log( "loading: " + event.bytesLoaded + " of " + event.bytesTotal );
			
			progressText = "loading BSP";
			dispatchEvent( event );
		}
		
		/**
	 	 * 
		 */ 
		private function loadNextTexture():void
		{
			if( _texturesToLoad.length )
			{
				var url:String = _texturesToLoad.pop() as String;
				var wal:WALReader = new WALReader( url );
				wal.addEventListener( FileLoadEvent.LOAD_COMPLETE, walCompleteHandler );
				wal.addEventListener( FileLoadEvent.LOAD_ERROR, walErrorHandler );
				
				progressText = "loading texture #" + (this.textures.length-_texturesToLoad.length)+ " of " + this.textures.length;
				
				dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS, false, false, this.textures.length-_texturesToLoad.length, this.textures.length) );
			}
			else
			{
				Papervision3D.log( "BSP " + _filename + " complete!" );
				dispatchEvent( new FileLoadEvent(FileLoadEvent.LOAD_COMPLETE, _filename) );
			}
		}
		
		/**
		 *
		 */ 
		private function makeTexture( pWAL:WALReader ):BitmapData 
		{
			var w:uint = Math.floor(pWAL.header.width);
			var h:uint = Math.floor(pWAL.header.height);
			
 			var bm:BitmapData = new BitmapData( w, h );
			var ba:ByteArray = pWAL.data as ByteArray;
			
			ba.position = pWAL.header.offsets[0];
			
			for(var j:int = 0; j < h; j++) 
			{
				for( var i:int = 0; i < w; i++) 
				{
					var a:uint = ba[j*w+i]; 
					
					var r:uint = this._pal.texpal[a*3+0];
					var g:uint = this._pal.texpal[a*3+1];
					var b:uint = this._pal.texpal[a*3+2];
					var col:uint = (r<<16 | g<<8 | b);
					
					bm.setPixel( i, j, col );
				}
			}
			
			return bm;
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function walCompleteHandler( event:FileLoadEvent ):void
		{
			var wal:WALReader = event.target as WALReader;
			
			if( wal is WALReader && !(this.wals[wal.header.name] is WALReader) )
			{
				this.wals[wal.header.name] = wal;
				this.bitmaps[wal.header.name] = makeTexture( wal );	
			}
			
			loadNextTexture();
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function walErrorHandler( event:FileLoadEvent ):void
		{
			loadNextTexture();
		}
		
		/**
		 * each area has a list of portals that lead into other areas
		 * when portals are closed, other areas may not be visible or
		 * hearable even if the vis info says that it should be
		 * 
		 * @param	pData
		 */
		private function readAreaPortals( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.AREA_PORTALS];
			pData.position = lump.offset;
			
			this.portals = new Array();
			var num:uint = lump.length / 8;
			
			for( var i:int = 0; i < num; i++ )
			{
				var portal:BspAreaPortal = new BspAreaPortal();
				portal.read( pData );
				this.portals.push( portal );
			}
		}
		
		/**
		 * 
		 * @param	pData
		 */
		private function readAreas( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.AREAS];
			pData.position = lump.offset;
			
			this.areas = new Array();
			var num:uint = lump.length / 8;
			
			for( var i:int = 0; i < num; i++ )
			{
				var area:BspArea = new BspArea();
				area.read( pData );
				this.areas.push( area );
			}
		}
		
		/**
		 * 
		 * @param	pData
		 */
		private function readBrushes( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.BRUSHES];
			pData.position = lump.offset;
			
			this.brushes = new Array();
			
			var num:uint = lump.length / 12;
			for( var i:int = 0; i < num; i++ )
			{
				var brush:BspBrush = new BspBrush();
				brush.firstside = pData.readInt();
				brush.numsides = pData.readInt();
				brush.contents = pData.readInt();
				this.brushes.push( brush );
			}
		}
		
		/**
		 * 
		 * @param	pData
		 */
		private function readBrushSides( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.BRUSH_SIDES];
			pData.position = lump.offset;
			
			this.brush_sides = new Array();
			
			var num:uint = lump.length / 4;
			for( var i:int = 0; i < num; i++ )
			{
				var side:BspBrushSide = new BspBrushSide();
				side.planenum = pData.readUnsignedShort();
				side.texinfo = pData.readShort();
				this.brush_sides.push( side );
			}
		}
		
		
		/**
		 * Not only are vertices shared between faces, but edges are as well. 
		 * Each edge is stored as a pair of indices into the vertex array. 
		 * The storage is two 16-bit integers, so the number of edges in the edge array is 
		 * the size of the edge lump divided by 4. There is a little complexity here because an 
		 * edge could be shared by two faces with different windings, and therefore there is no 
		 * particular "direction" for an edge. 
		 * This is further discussed in the section on face edges.
		 * 
		 * @param	pData
		 */
		private function readEdges( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.EDGES];
			pData.position = lump.offset;
			
			this.edges = new Array();
			var num:uint = lump.length / 4;
			
			for( var i:int = 0; i < num; i++ )
			{
				var a:int = pData.readShort();
				var b:int = pData.readShort();
				this.edges.push( [a, b] );
			}
		}
		
		/**
		 * 
		 * @param	pData
		 */
		private function readEntities( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.ENTITIES];
			
			this.entities = new BspEntities();
			this.entities.read( pData, lump );
		}
		
		/**
		 * Instead of directly accessing the edge array, faces contain indices into the 
		 * face edge array which are in turn used as indices into the edge array. 
		 * The face edge lump is simply an array of unsigned 32-bit integers. 
		 * The number of elements in the face edge array is the size of the face edge lump 
		 * divided by 4 (note that this is not necessarily the same as the number of edges). 
		 * Since edges are referenced from multiple sources they don't have any particular direction. 
		 * If the edge index is positive, then the first point of the edge is the start of the edge; 
		 * if it's negative, then the second point is used as the start of the edge (and obviously 
		 * when you look it up in the edge array you drop the negative sign).
		 * 
		 * @param	pData
		 */
		private function readFaceEdges( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.FACE_EDGE_TABLE];
			pData.position = lump.offset;
			
			this.face_edges = new Array();
			var num:uint = lump.length / 4;
			
			for( var i:int = 0; i < num; i++ )
			{
				this.face_edges.push( pData.readInt() );
			}
		}
		
		/**
		 * The size of the bsp_face structure is 20 bytes, the number of faces can be determined 
		 * by dividing the size of the face lump by 20. The plane_side is used to determine 
		 * whether the normal for the face points in the same direction or opposite the plane's 
		 * normal. This is necessary since coplanar faces which share the same node in the 
		 * BSP tree also share the same normal, however the true normal for the faces could be 
		 * different. If plane_side is non-zero, then the face normal points in the opposite 
		 * direction as the plane's normal. 
		 * The details of texture and lightmap coordinate generation are discussed in the 
		 * section on texture information and lightmap sections.
		 * 
		 * @param	pData
		 */
		private function readFaces( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.FACES];
			pData.position = lump.offset;
			
			this.faces = new Array();
			
			// facelump is 20 bytes
			var nFaces:uint = lump.length / 20;
			
			for( var i:int = 0; i < nFaces; i++ )
			{
				var f:BspFace = new BspFace();
				f.read( pData );
				this.faces.push( f );
			}
		}

		/**
		 * Instead of directly accessing the face array, leaves contain indices into the leaf 
		 * face array which are in turn used as indices into the face array. The face edge lump 
		 * is simply an array of unsigned 16-bit integers. The number of elements in this array is 
		 * the size of the leaf face lump divided by 2; this is not necessarily the same as the 
		 * number of faces in the world.
		 * 
		 * @param	pData
		 */
		private function readLeaveFaces( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.LEAVE_FACE_TABLE];
			pData.position = lump.offset;
			
			this.leave_faces = new Array();
			
			// leave face-lump is 2 bytes
			var num:uint = lump.length / 2;
			
			for( var i:int = 0; i < num; i++ )
			{
				this.leave_faces.push( pData.readUnsignedShort() );
			}
		}
		
		/**
		 * The bsp_leaf structure is 28 bytes so the number of leaves is the size of the leaf lump 
		 * divided by 28. Leaves are grouped into clusters for the purpose of storing the PVS, 
		 * and the cluster field gives the index into the array stored in the visibility lump. 
		 * See the Visibility section for more information on this. If the cluster is -1, then 
		 * the leaf has no visibility information (in this case the leaf is not a place that is 
		 * reachable by the player).
		 * 
		 * @param	pData
		 */
		private function readLeaves( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.LEAVES];
			pData.position = lump.offset;
			
			this.leaves = new Array();
			
			// leaves-lump is 28 bytes
			var num:uint = lump.length / 28;
			
			for( var i:int = 0; i < num; i++ )
			{
				var leaf:BspLeaf = new BspLeaf();
				leaf.read( pData );
				this.leaves.push( leaf );
			}
		}
		
		/**
		 * 
		 * @param	pData
		 */
		private function readModels( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.MODELS];
			pData.position = lump.offset;
			
			this.models = new Array();
			var num:uint = lump.length / 48;
			
			for( var i:int = 0; i < num; i++ )
			{
				var model:BspModel = new BspModel();
				model.read( pData );
				this.models.push( model );
			}
		}
		
		/**
		 * Each bsp_node is 28 bytes, so the number of nodes is the size of the node lump divided 
		 * by 28. Since a child of a node may be a leaf and not a node, negative values for the 
		 * index are used to incate a leaf. The exact position in the leaf array for a negative index 
		 * is computed as -(index + 1) so that the first negative number maps to 0. 
		 * Since the bounding boxes are axis aligned, the eight coordinates of the box can be 
		 * found from the minimum and maximum coordinates stored in the bbox_min and bbox_max fields. 
		 * As mentioned earlier, the faces listed in the node are not used for rendering but rather 
		 * for collision detection.
		 * 
		 * @param	pData
		 */
		private function readNodes( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.NODES];
			pData.position = lump.offset;
			
			this.nodes = new Array();
			
			// nodes lump is 28 bytes
			var nNodes:uint = lump.length / 28;
			
			for( var i:int = 0; i < nNodes; i++ )
			{
				var node:BspNode = new BspNode();
				node.read( pData );
				this.nodes.push( node );
			}
		}
		
		/**
		 * Each bsp_plane structure is 20 bytes, so the number of planes is the size of the 
		 * plane lump divided by 20. The x, y and z components of the normal correspond to A, B, C 
		 * constants and the distance to the D constant in the plane equation: 
		 * F(x, y, z) = Ax + By + Cz - D
		 * A point is on the plane is F(x, y, z) = 0, in front of the plane if F(x, y, z) > 0 and 
		 * behind the plane if F(x, y, z) < 0. This is used in the traversal of the BSP tree is 
		 * traversed.
		 * 
		 * @param	pData
		 */
		private function readPlanes( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.PLANES];
			pData.position = lump.offset;
			
			this.planes = new Array();
			
			// planes lump is 20 bytes
			var nPlanes:uint = lump.length / 20;
			
			for( var i:int = 0; i < nPlanes; i++ )
			{
				var p:BspPlane = new BspPlane();
				p.read( pData );
				this.planes.push( p );
			}
		}
		
		/**
		 * The bsp_texinfo structure is 76 bytes, so the number of texture information structures is 
		 * the size of the lump divided by 76. 
		 * <p>Textures are applied to faces using a planar texture mapping scheme. Instead of 
		 * specifying texture coordinates for each of the vertices of the face, two texture axes 
		 * are specified which define a plane. Texture coordinates are generated by projecting 
		 * the vertices of the face onto this plane. 
		 * While this may seem to add some complexity to the task of the programmer, it greatly 
		 * reduces the burden of the level designer in aligning textures across multiple faces. 
		 * The texture coordinates (u, v) for a point(x, y, z) are found using the following 
		 * computation:
		 * 
		 * <code>
		 * u = x * u_axis.x + y * u_axis.y + z * u_axis.z + u_offset
		 * v = x * v_axis.x + y * v_axis.y + z * v_axis.z + v_offset
		 * </code>
		 * 
		 * The texture name is stored with a path but without any extension. Typically, if you are 
		 * loading a Quake 2 map you would append the extension "wal" to the name and then load it 
		 * from the PAK file. If you're loading a Kingpin map you would append the extension "tga" 
		 * and then load if from disk (Kingpin stires the textures outside of the PAK file). 
		 * See the section on the WAL texture format for more details.</p>
		 * 
		 * @param	pData
		 */
		private function readTextureInfo( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.TEXTURE_INFO];
			pData.position = lump.offset;
			
			_texturesToLoad = new Array();
			
			this.wals = new Object();
			this.textures = new Array();
			
			// textureinfo lump is 76 bytes
			var num:uint = lump.length / 76;
			
			for( var i:int = 0; i < num; i++ )
			{
				var texinfo:BspTexInfo = new BspTexInfo();
				texinfo.read( pData );
				
				_texturesToLoad.push( "baseq/textures/"+texinfo.texture+".wal" );
				
				this.textures.push( texinfo );
			}
		}
		
		/**
		 * The vertex lump is a list of all of the vertices in the world. 
		 * Each vertex is 3 floats which makes 12 bytes per vertex. 
		 * You can compute the numbers of vertices by dividing the length of the vertex lump by 12.
		 * Quake uses a coordinate system in which the z-axis is pointing in the "up" direction. 
		 * Keep in mind that if you modify the coordinates to use a different system, 
		 * you will also need to adjust the bounding boxes and the plane equations.
		 * 
		 * @param	pData
		 */
		private function readVertices( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.VERTICES];
			pData.position = lump.offset;
			
			this.vertices = new Array();
			var nVerts:uint = lump.length / 4 / 3;
			
			for( var i:int = 0; i < nVerts; i++ )
			{
				var pt:Vertex3D = new Vertex3D();
				pt.x = pData.readFloat();
				pt.y = pData.readFloat();
				pt.z = pData.readFloat();
				this.vertices.push( pt );
			}
		}
		
		/**
		 * Leaves are grouped into clusters for the purpose of storing the visibility information. 
		 * This is to conserve space in the PVS since it's likely that nearby leaves will have 
		 * similar potentially visible areas. The first 4 bytes of the visibility lump is a 
		 * 32-bit unsigned integer indicating the number of clusters in the map, and after that is 
		 * an array of bsp_vis_offset structures with the same number of elements as there are 
		 * clusters. 
		 * The rest of the visibility lump is the actual visibility information. 
		 * For every cluster the visibility state (either visible or occluded) is stored for 
		 * every other cluster in the world. Clusters are always visible from within themselves. 
		 * Because this is such a massive amount of data, this array is stored as a bit vector 
		 * (one bit per element) and 0's are run-length-encoded. 
		 * Here's an example of a C-routine to decompress the PVS into a byte array (this was 
		 * adapted from the "Quake Specifications" document):
		 * 
		 * 	int v = offset;
		 *
		 *	memset(cluster_visible, 0, num_clusters);
		 *
		 *	for (int c = 0; c < num_clusters; v++) {
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
		 */
		private function readVisibility( pData:ByteArray ):void
		{
			var lump:BspLump = this.header.lump[BspLump.VISIBILITY];
			pData.position = lump.offset;
			
			this.visibility = new BspVisibility();
			this.visibility.read( pData );
			
			var v:uint = pData.position;
			
			Papervision3D.log(this.visibility.clusters.length+" " + this.visibility.num_clusters);
		}
		
		private var _texturesToLoad:Array;
		private var _loader:URLLoader;
		private var _filename:String;
		private var _pal:PALReader;
		private var _debug:Boolean = true;
	}
}
