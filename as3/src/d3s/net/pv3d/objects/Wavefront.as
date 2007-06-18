package d3s.net.pv3d.objects
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.NumberUV;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.geom.Vertex3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.objects.Mesh;
	
	/**
	 * The Wavefront DisplayObject3D class lets you load a Wavefront OBJ (.obj) file.
	 * </p>
	 * Wavefront OBJ file format is a popular file format for 3D modeling software.
	 * All data from the file is used except vertex normal computed data.
	 * </p>
	 * NOTE: The Wavefront format relies on vertices and texture vertices being defined
	 * before faces. This is probably the case, but I am unsure as to the proper standard.
	 * </p>
	 * Please feel free to use, but please mention me!
	 * </p>
	 * @version 01.09.07:23:15
	 * @author Philippe Ajoux (philippe.ajoux@gmail.com)
	 */
	public class Wavefront extends Mesh
	{
		private var loader:URLLoader;
		private var file:String;
		
		/**
		 * Vertex RegExp parameters:
		 *   1) x:Number
		 *   2) y:Number
		 *   3) z:Number
		 */ 
		private static const VERTEX:RegExp = /^v\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)/;
		
		/**
		 * Texture Vertex RegExp parameters:
		 *   1) u:Number
		 *   2) v:Number
		 */
		private static const T_VERTEX:RegExp = /^vt\s+([^\s]+)\s+([^\s]+)/;
		
		/**
		 * Face RegExp parameters:
		 *   Vertex Index			Texture Vertex Index
		 *   1) a:int				2) ta:int
		 *   3) b:int				4) tb:int
		 *   5) c:int				6) tc:int
		 */
		private static const FACE:RegExp = /^f\s+(\d+)\/(\d+)\/?\d*\s+(\d+)\/(\d+)\/?\d*\s+(\d+)\/(\d+)\/?\d*\s+/;
		
		/**
		 * Wavefront class lets you load in a Wavefront OBJ (.obj) file
		 * </p>
		 * @param material
		 * @param filename 	The file to be loaded
		 * @param scale		Any custom scaling to apply when loading file
		 * @param initObject
		 */
		public function Wavefront(material:MaterialObject3D, filename:String, scale:Number = 1, initObject:Object = null)
		{
			super(material, new Array(), new Array(), initObject);
			this.scale = scale;
			file = filename;
			loadWavefront(filename);
		}
		
		/**
		 * Setup and Load the file
		 */
		private function loadWavefront(filename:String):void
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseWavefront);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			try
			{
	            loader.load(new URLRequest(filename));
			}
			catch(e:Error)
			{
				Papervision3D.log("error in loading wavefront file (" + filename + ")");
			}
		}
		
		/**
		 * Actually parse the Wavefront OBJ file.
		 * Synopsis:
		 * 		loop through each line
		 * 			if it is a vertex definition, create/add vertex
		 * 			if it is a texture vertex definition, create texture vertex
		 * 			if it is a face definition, create/add face
		 */
		private function parseWavefront(event:Event):void
		{
			var lines:Array = loader.data.split("\n");
			var params:Array, line:String;
			var uvs:Array = new Array();
			
			for each(line in lines)
				//--- Add vertices to the mesh scaling each point
				// NOTE: y value is negated for Papervision3D special purposes
				if ((params = line.match(VERTEX)) != null)
					vertices.push(new Vertex3D(Number(params[1]) * scale, -Number(params[2]) * scale, Number(params[3]) * scale));
				
				//--- Add texture vertices to a temoporary array to be processed
				// NOTE: v value is inverted for Papervision3D special purposes
				else if ((params = line.match(T_VERTEX)) != null)
					uvs.push(new NumberUV(Number(params[1]), 1 - Number(params[2])));
					
				//--- Use the vertices and texture vertices to add a face
				// IMPORTANT NOTE! Wavefront OBJ file seem to have the faces defined backwards.
				//                 so Papervision3D renders the faces wrong. This is just wierd
				//                 that is does not conform to standards.
				else if ((params = line.match(FACE)) != null)
					// Add NON texturemapping faces
					if (uvs.length == 0)
						faces.push(new Face3D([vertices[int(params[5]) - 1], vertices[int(params[3]) - 1], vertices[int(params[1]) - 1]],
											   material));
					// Add faces with texturmaping
					else
						faces.push(new Face3D([vertices[int(params[5]) - 1],vertices[int(params[3]) - 1],vertices[int(params[1]) - 1]],
										  	   material, [uvs[int(params[6]) - 1],uvs[int(params[4]) - 1],uvs[int(params[2]) - 1]]));
			
			loader.close();
			Papervision3D.log("Parsed Wavefront: " + file + "\n vertices:" + vertices.length + "\n texture vertices:" + uvs.length + "\n faces:" + faces.length);
		}
		
		/**
		 * Mirrored from the Ase DisplayObject3D class
		 * In case of error in loading, throw it =)
		 */
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			throw new Error("could not load wavefront file (" + file + ")");
		}

	}
}