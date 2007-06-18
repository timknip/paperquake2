package d3s.net.util
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	/**
	 * My own FPS counter thingy =)
	 * 
	 * @author Philippe Ajoux (philippe.ajoux@gmail.com)
	 */
	public class FPSCounter extends Sprite
	{
		private static const UPDATE_COUNT:int = 10;
		
		private var display:TextField;
		private var last:Number = 0;
		private var current:Number;
		private var fps:Number;
		private var frames:int;
		private var total:Number = 0;
		
		public function FPSCounter()
		{
			display = new TextField();
			display.width = 50;
			display.height = 15;
			display.background = true;
			display.backgroundColor = 0xFFFFFF;
			addEventListener(Event.ENTER_FRAME, update);
			addChild(display);
		}
		
		public function update(event:Event):void
		{
			current = getTimer();
			fps = 1 / (current - last) * 1000;
			last = current;
			frames = (frames + 1) % UPDATE_COUNT;
			total += fps;
			if (frames == 0)
			{
				display.text = "FPS: " + Math.round(total / UPDATE_COUNT);
				total = 0;
			}	
		}
	}
}