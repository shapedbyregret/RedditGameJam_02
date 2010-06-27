package  
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	
	public class Magnet extends Sprite
	{
		public var life:Number;
		private var decay:Number;
		public var isPositive:Boolean;
		
		public function Magnet(newX:Number,newY:Number) 
		{
			life = 100;
			decay = 1 / (life >> 1);
			isPositive = true;
			
			draw();
			x = newX;
			y = newY;
			
			Main.g.magnets.append(this);
		}
		
		public function update():void
		{
			life -= 1;
			if(life<50) {
				alpha -= decay;
			}
		}
		
		private function draw():void
		{
			var col:uint;
			if(Main.g.shiftPressed) {
				col = 0x0000FF;
				filters = [Main.g.blueFilter];
				isPositive = false;
				graphics.lineStyle(2, 0xFFFFFF, 1);
				graphics.moveTo(-5, 0);
				graphics.lineTo(5, 0);
			}
			else {
				col = 0xFF0000;
				filters = [Main.g.redFilter];
				isPositive = true;
				graphics.lineStyle(2, 0xFFFFFF, 1);
				graphics.moveTo(-5, 0);
				graphics.lineTo(5, 0);
				graphics.moveTo(0, 5);
				graphics.lineTo(0, -5);
			}
			graphics.beginFill(col, 0.3);
			graphics.drawCircle(0, 0, 20);
			graphics.endFill();
			
			graphics.lineStyle(1, 0x333333, 1);
			graphics.drawCircle(0, 0, 100);
		}
	}

}