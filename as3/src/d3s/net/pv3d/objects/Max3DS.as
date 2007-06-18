package d3s.net.pv3d.objects
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.NumberUV;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.geom.Vertex3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.objects.Mesh;
	
	/**
	 * The Max3DS DisplayObject3D class lets you load a 3D Studio Max 3DS (.3ds) file.
	 * </p>
	 * 3DS file format is another popular model format and it is represented in binary
	 * rather than ASCII (like ASE and Wavefront) which results in much smaller file sizes.
	 * </p>
	 * NOTE: Only the object data (vertices, texture coordinates, faces) are processed
	 * </p>
	 * Please feel free to use, but please mention me!
	 * </p>
	 * @version 01.09.07:11:29
	 * @author Philippe Ajoux (philippe.ajoux@gmail.com)
	 */
	public class Max3DS extends Mesh
	{
		private var file:String;
		private var loader:URLLoader;
		private var objectName:String;
		
		/**
		 * Return the name of this object as defined in the 3DS file
		 */
		public function get name():String { return objectName; }
		 
		/**
		 * Max3DS class lets you load in a 3D Studio Max (.3ds) file
		 * </p>
		 * @param material
		 * @param filename 	The file to be loaded
		 * @param scale		Any custom scaling to apply when loading file
		 * @param initObject
		 */
		public function Max3DS(material:MaterialObject3D, filename:String, scale:Number = 1, initObject:Object = null)
		{
			super(material, new Array(), new Array(), initObject);
			this.scale = scale;
			file = filename;
			load3DS(filename);
		}
		
		/**
		 * Setup and Load the file
		 */
		private function load3DS(filename:String):void
		{
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, parse3DS);
			
			try
			{
	            loader.load(new URLRequest(filename));
			}
			catch(e:Error)
			{
				Papervision3D.log( "error in loading 3DS file (" + filename + ")");
			}
		}
		
		/**
		 * Parse the 3DS binary file format:
		 * The way this is done is a bit more involved than ASE and Wavefront
		 * and is not fully explained via commenting. However, do note that
		 * this version of the parse does NOT rely the TEXTURE_VERTEX block
		 * coming prior to the FACE_BLOCK; But there must exist a 
		 * TEXTURE_VERTEX block!!
		 */
		private function parse3DS(event:Event):void
		{
			var chunkID:uint, chunkLength:uint;
			var tempFaces:Array = new Array();
			var data:ByteArray = loader.data;
			var uvs:Array = new Array();
			var i:uint, size:uint;
			var name:String;
			var face:Object;
			
			// Endian needed to read in the binary data
			data.endian = Endian.LITTLE_ENDIAN;
			
			while (data.bytesAvailable > 0)
			{
				chunkID = data.readUnsignedShort();
				chunkLength = data.readUnsignedInt();
				
				switch (chunkID)
				{
					//---MAIN_CHUNK
					case 0x4d4d: break;
					
					//---EDITOR_CHUNK 
					case 0x3d3d: break;
					
					//---OBJECT_BLOCK 
					// contains object name and sub-chunks
					case 0x4000:
						name = "";
						while ((size = data.readByte()) != 0)
							name += String.fromCharCode(size);
						objectName = name;
						break;
					
					//---TRIANGLE_MESH_BLOCK 
					case 0x4100: break;
					
					//---VERTEX_BLOCK 
					// has a list of all the vertices in the object
					case 0x4110:
						size = data.readUnsignedShort();
						for (i = 0; i < size; i++)
							vertices.push(new Vertex3D(data.readFloat() * scale, 
													   data.readFloat() * scale,
													   data.readFloat() * scale));
						break;
						
					//---FACE_BLOCK
					// list of all the faces in the polygon
					case 0x4120:
						size = data.readUnsignedShort();
						for (i = 0; i < size; i++)
							tempFaces.push({a: data.readUnsignedShort(),
											b: data.readUnsignedShort(),
											c: data.readUnsignedShort(),
											flags: data.readUnsignedShort()});
						break;
					
					//---TEXTURE_VERTEX_BLOCK
					// uv coordinates to be added, a parallel list to the vertex list
					case 0x4140:
						size = data.readUnsignedShort();
						for (i = 0; i < size; i++)
							uvs.push(new NumberUV(data.readFloat(), 1 - data.readFloat()));
						break;
							
					// Other, superfluous blocks are just skipped
					default:
						data.position += chunkLength - 6;
				}
			}
			
			// Loop through the temporary face objects and actually add the Face3D's
			// NOTE: Must be done this way because of the 3DS format setup =(
			for each (face in tempFaces)
				if (uvs.length != vertices.length)
				// Add faces without any texturing
					faces.push(new Face3D([vertices[face.a], vertices[face.b], vertices[face.c]], material));
				else
				// Add faces WITH texture mapping
					faces.push(new Face3D([vertices[face.a], vertices[face.b], vertices[face.c]], 
									  	  material, [uvs[face.a], uvs[face.b], uvs[face.c]]));
			
			loader.close();
			Papervision3D.log("Parsed 3DS: " + file + "\n vertices:" + vertices.length + "\n texture vertices:" + uvs.length + "\n faces:" + faces.length);
		}
	}
}