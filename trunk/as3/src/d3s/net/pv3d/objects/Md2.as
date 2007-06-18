package d3s.net.pv3d.objects
{
	import d3s.net.pv3d.anim.Frame;
	
	import flash.events.Event;
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
	
	/**
	 * Loades Quake 2 MD2 file with animation!
	 * </p>
	 * Please feel free to use, but please mention me!
	 * </p>
	 * @author Philippe Ajoux (philippe.ajoux@gmail.com)
	 * @website www.d3s.net
	 * @version 01.10.07:11:56
	 */
	public class Md2 extends KeyframeMesh
	{
		/**
		 * Variables used in the loading of the file
		 */
		private var file:String;
		private var loader:URLLoader;
		private var loadScale:Number;
		
		/**
		 * MD2 Header data
		 * These are all the variables found in the md2_header_t
		 * C style struct that starts every MD2 file.
		 */
		private var ident:int, version:int;
		private var skinwidth:int, skinheight:int;
		private var framesize:int;
		private var num_skins:int, num_vertices:int, num_st:int;
		private var num_tris:int, num_glcmds:int, num_frames:int;
		private var offset_skins:int, offset_st:int, offset_tris:int;
		private var offset_frames:int, offset_glcmds:int, offset_end:int;
		
		/**
		 * Md2 class lets you load a Quake 2 MD2 file with animation!
		 * </p>
		 */
		public function Md2(material:MaterialObject3D, filename:String, fps:int = 6, scale:Number = 1, initObject:Object = null)
		{
			super(material, fps, scale, initObject);
			loadScale = scale;
			file = filename;
			visible = false;
			load(filename);
		}
		
		/**
		 * Mirrored from Ase, Wavefron, and Max3DS
		 */
		private function load(filename:String):void
		{
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, parse);
			
			try
			{
	            loader.load(new URLRequest(filename));
			}
			catch(e:Error)
			{
				Papervision3D.log("error in loading MD2 file (" + filename + ")");
			}
		}
		
		/**
		 * Parse the MD2 file. This is actually pretty straight forward.
		 * Only complicated parts (bit convoluded) are the frame loading
		 * and "metaface" loading. Hey, it works, use it =)
		 */
		private function parse(event:Event):void
		{
			var i:int, uvs:Array = new Array();
			var data:ByteArray = loader.data;
			var metaface:Object;
			data.endian = Endian.LITTLE_ENDIAN;
			
			// Read the header and make sure it is valid MD2 file
			readMd2Header(data);
			if (ident != 844121161 || version != 8)
				throw new Error("error loading MD2 file (" + file + "): Not a valid MD2 file/bad version");
				
			//---Vertice setup
			// be sure to allocate memory for the vertices to the object
			for (i = 0; i < num_vertices; i++)
				vertices.push(new Vertex3D());

			//---UV coordinates
			data.position = offset_st;
			for (i = 0; i < num_st; i++)
				uvs.push(new NumberUV(data.readShort() / skinwidth, data.readShort() / skinheight));

			//---Faces
			// make sure to push the faces with allocated vertices to the object!
			data.position = offset_tris;
			for (i = 0; i < num_tris; i++)
			{
				metaface = {a: data.readUnsignedShort(), b: data.readUnsignedShort(), c: data.readUnsignedShort(),
					        ta: data.readUnsignedShort(), tb: data.readUnsignedShort(), tc: data.readUnsignedShort()};
				
				metafaces.push(metaface);
				faces.push(new Face3D([new Vertex3D(), new Vertex3D(), new Vertex3D()], material,
									  [uvs[metaface.ta], uvs[metaface.tb], uvs[metaface.tc]]));
				// !! TODO IMPORTANT NOTE WARNING !! I don't know what PV3D does with id's but
				// I am using it here and it is VERY important that this line is here.
				// The KeyframeMesh class relies on it!
				faces[faces.length - 1].id = i;
			}
			
			//---Frame animation data
			data.position = offset_frames;
			readFrames(data);
			
			loader.close();
			visible = true;
			
			Papervision3D.log("Parsed MD2: " + file + "\n vertices:" + 
							  vertices.length + "\n texture vertices:" + uvs.length +
							  "\n faces:" + faces.length + "\n frames: " + frames.length);
		}
		
		/**
		 * Reads in all the frames
		 */
		private function readFrames(data:ByteArray):void
		{
			var sx:Number, sy:Number, sz:Number;
			var tx:Number, ty:Number, tz:Number;
			var verts:Array, frame:Frame;
			var i:int, j:int, char:int;
			
			for (i = 0; i < num_frames; i++)
			{
				verts = new Array();
				frame = new Frame("", verts);
				
				sx = data.readFloat();
				sy = data.readFloat();
				sz = data.readFloat();
				
				tx = data.readFloat();
				ty = data.readFloat();
				tz = data.readFloat();
				
				for (j = 0; j < 16; j++)
					if ((char = data.readUnsignedByte()) != 0)
						frame.name += String.fromCharCode(char);
				
				// Note, the extra data.position++ in the for loop is there 
				// to skip over a byte that holds the "vertex normal index"
				for (j = 0; j < num_vertices; j++, data.position++)
					verts.push(new Vertex3D(
						((sx * data.readUnsignedByte()) + tx) * loadScale, 
						((sy * data.readUnsignedByte()) + ty) * loadScale,
						((sz * data.readUnsignedByte()) + tz) * loadScale));
						
				frames.push(frame);
			}
		}
		
		/**
		 * Reads in all that MD2 Header data that is declared as private variables.
		 * I know its a lot, and it looks ugly, but only way to do it in Flash
		 */
		private function readMd2Header(data:ByteArray):void
		{
			ident = data.readInt();
			version = data.readInt();
			skinwidth = data.readInt();
			skinheight = data.readInt();
			framesize = data.readInt();
			num_skins = data.readInt();
			num_vertices = data.readInt();
			num_st = data.readInt();
			num_tris = data.readInt();
			num_glcmds = data.readInt();
			num_frames = data.readInt();
			offset_skins = data.readInt();
			offset_st = data.readInt();
			offset_tris = data.readInt();
			offset_frames = data.readInt();
			offset_glcmds = data.readInt();
			offset_end = data.readInt();
		}
	}
}