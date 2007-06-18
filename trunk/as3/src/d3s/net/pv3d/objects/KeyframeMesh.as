package d3s.net.pv3d.objects
{
	import com.theriabook.utils.Logger;
	import d3s.net.pv3d.anim.Frame;
	
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.geom.Vertex3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.objects.Mesh;
	import flash.display.Sprite;
	import flash.utils.getTimer;
	
	/**
	 * KeyframeMesh provides framework for objects that have keyframed animation.
	 * Note that is class is [abstract] in that in itself provides no functionality.
	 * </p>
	 * There are a couple very specific details that must be adhered to by all subclasses
	 * in order for this to work properly:
	 * </p>
	 * [1] The subclass MUST allocate properly sized arrays with memory for <i>faces</i> and <i>vertices</i><br>
	 * [2] The <i>Face3D</i> objects in <i>faces</i> must have an <i>id</i> cooresponding to their original array order
	 * </p>
	 * Please feel free to use, but please mention me!
	 * </p>
	 * @author Philippe Ajoux (philippe.ajoux@gmail.com)
	 * @website www.d3s.net
	 * @version 01.11.07:11:58
	 */
	public class KeyframeMesh extends Mesh
	{
		/**
		 * Three kinds of animation sequences:
		 *  [1] Normal (sequential, just playing)
		 *  [2] Loop   (a loop)
		 *  [3] Stop   (stopped, not animating)
		 */
		public static const ANIM_NORMAL:int = 1;
		public static const ANIM_LOOP:int = 2;
		public static const ANIM_STOP:int = 4;
		
		/**
		 * A "meta face" is a simple Object with six properties:
		 *  	a:int, b:int, c:int, ta:int, tb:int, tc:int
		 * Which all the vertex indices and texture vertex indices for each face.
		 */
		public var metafaces:Array = new Array();
		
		/**
		 * The array of frames that make up the animation sequence.
		 */
		public var frames:Array = new Array();
		
		/**
		 * Keep track of the current frame number and animation
		 */
		private var _currentFrame:int = 0;
		private var interp:Number = 0;
		private var start:int, end:int, type:int;
		private var ctime:Number = 0, otime:Number = 0;
		
		/**
		 * Number of animation frames to display per second
		 */
		public var fps:int;
		
		/**
		 * KeyframeMesh is a class used [internal] to provide a "keyframe animation"/"vertex animation"/"mesh deformation"
		 * framework for subclass loaders. There are some subtleties to using this class, so please, I suggest you
		 * don't (not yet). Possible file formats are MD2, MD3, 3DS, etc...
		 */
		public function KeyframeMesh(material:MaterialObject3D, fps:int = 6, scale:Number = 1, initObject:Object = null)
		{
			super(material, new Array(), new Array(), initObject);
			this.fps = fps;
			scale = scale;
		}
		
		public function gotoAndPlay(frame:int):void
		{
			keyframe = frame;
			type = ANIM_NORMAL;
		}
		
		public function loop(start:int, end:int):void
		{
			this.start = (start % frames.length);
			keyframe = start;
			this.end = (end % frames.length);
			type = ANIM_LOOP;
		}
		
		public function stop():void
		{
			type = ANIM_STOP;
		}
		
		public function gotoAndStop(frame:int):void
		{
			keyframe = frame;
			type = ANIM_STOP;
		}
		
		/**
		 * Custom Mesh render routine to include animation while not taking too much away from processing speed.
		 */
		public override function render(scene:SceneObject3D):void
		{
			var cframe:Frame, nframe:Frame;
			var metaface:Object;
			var face:Face3D;
			var i:int, a:int, b:int, c:int;
			
			if (!visible) return;
			
			var rendered       :Number           = 0;
			var container:Sprite = this._container || scene.container;
			var objectMaterial:MaterialObject3D = this._material;
			var showFaces:Boolean = this.showFaces;
			
			cframe = frames[_currentFrame];
			nframe = frames[(_currentFrame + 1) % frames.length];
			
			// Z-Sort
			if (this.sortFaces)
				faces.sortOn('screenZ', Array.DESCENDING | Array.NUMERIC);
			
			for (i = 0; i < faces.length; i++)
			{
				face = faces[i];
				metaface = metafaces[face.id];
				
				// Render the old frame's face
				if (face.visible)
					rendered += face.render(container, objectMaterial, showFaces);
				
				// Prefetch
				a = metaface.a;
				b = metaface.b;
				c = metaface.c;
				
				// Interpolate the vertices
				interplateVertex(vertices[a], cframe.vertices[a], nframe.vertices[a]);
				interplateVertex(vertices[b], cframe.vertices[b], nframe.vertices[b]);
				interplateVertex(vertices[c], cframe.vertices[c], nframe.vertices[c]);
				
				// Set the vertices to the face
				face.vertices[0] = vertices[c];
				face.vertices[1] = vertices[b];
				face.vertices[2] = vertices[a];
			}
			
			// Update the timer part, to get time based animation
			ctime = getTimer();
			if (type != ANIM_STOP)
			{
				interp += fps * (ctime - otime) / 1000;
				if (interp >= 1)
				{
					if (type == ANIM_LOOP && _currentFrame + 1 == end)
						keyframe = start;
					else
						keyframe++;
					interp = 0;
				}
			}
			otime = ctime;
			
			// Update stats
			scene.stats.rendered += rendered;
		}
		
		/**
		 * Do a simple linear-interpolation of two vertices and apply it to a vertex
		 */
		private function interplateVertex(dst:Vertex3D, a:Vertex3D, b:Vertex3D):void
		{
			dst.x = dst.toScale.x = dst.toRotate.x = a.x + interp * (b.x - a.x);
			dst.y = dst.toScale.y = dst.toRotate.y = a.y + interp * (b.y - a.y);
			dst.z = dst.toScale.z = dst.toRotate.z = a.z + interp * (b.z - a.z); 
		}
		
		public function get keyframe():int { return _currentFrame; }
		public function set keyframe(i:int):void { _currentFrame = i % frames.length; }
	}
}