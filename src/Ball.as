﻿package  
{
	import flash.display.*;
	
	public class Ball extends Sprite
	{
		
		public var xVel:Number;
		public var yVel:Number;
		
		public function Ball()
		{
			xVel = 0;
			yVel = 0;
			
			x = 100;
			y = 100;
			
			graphics.beginFill(0xFFFFFF, 1);
			graphics.drawCircle(0, 0, 6);
			graphics.endFill();
			
			Main.g.ballLayer.addChild(this);
		}
		
		public function update():void
		{
			x += xVel;
			y += yVel;
			
			xVel *= Main.g.friction;
			yVel *= Main.g.friction;
			
			if (x < 0 || x > 640) {
				xVel *= -1;
			}
			if (y < 0 || y > 480) {
				yVel *= -1;
			}
		}
		
	}

}