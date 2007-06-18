package d3s.net.pv3d.anim
{
	/**
	 * Used in combination with KeyframeMesh DisplayObject3D and all sub-classes
	 * to provided keyframe-based animation to objects.
	 * </p>
	 * A Frame object has a list of vertices and a name which define the animation.
	 */
	public class Frame
	{
		public var name:String;
		public var vertices:Array;
		
		public function Frame(name:String, vertices:Array)
		{
			this.name = name;
			this.vertices = vertices;
		}
		
		public function toString():String
		{
			return "[Frame][name:" + name + "][vertices:" + vertices.length + "]";
		}	
	}
}