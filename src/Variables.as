package  
{
	import flash.display.*;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	
	import de.polygonal.ds.*;
	
	public class Variables
	{
		public var timer:Timer;
		public var paused:Boolean;
		public var shiftPressed:Boolean;
		public var mouseDown:Boolean;
		public var friction:Number;
		public var levelWidth:Number;
		public var levelPosition:Number;
		
		public var ball:Ball;
		public var balls:DLL;
		public var magnets:DLL;
		
		public var magnetLayer:Sprite;
		public var levelLayer:Sprite;
		public var ballLayer:Sprite;
		
		public var redFilter:GlowFilter;
		public var blueFilter:GlowFilter;
		
		public function Variables() 
		{
			timer = new Timer(500);
			timer.start();
			paused = false;
			shiftPressed = false;
			mouseDown = false;
			friction = 0.85;
			levelWidth = 2100;
			levelPosition = 0;
			
			balls = new DLL();
			magnets = new DLL();
			
			magnetLayer = new Sprite();
			levelLayer = new Sprite();
			ballLayer = new Sprite();
			
			redFilter = new GlowFilter(0xFF0000, 0.3, 15, 15, 3);
			blueFilter = new GlowFilter(0x0000FF, 0.3, 15, 15, 3);
		}
		
	}

}