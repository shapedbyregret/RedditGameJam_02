package 
{
	import de.polygonal.ds.DLLNode;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	
	/**
	 * ...
	 * @author scy
	 */
	public class Main extends Sprite 
	{
		// Embed font
		//[Embed(source="Distant-Galaxy/DISTGRG_.ttf", fontFamily="Distant")]
		//private var Distant:String;
		
		public static var g:Variables;
		public static var _stage:Stage;
		public static var mainLayer:Sprite;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			_stage = stage;
			g = new Variables();
			mainLayer = new Sprite();
			mainLayer.addChild(g.magnetLayer);
			mainLayer.addChild(g.levelLayer);
			mainLayer.addChild(g.ballLayer);
			drawGrid();
			addChild(mainLayer);
			
			g.ball = new Ball();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mUp);
			stage.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event = null):void
		{
			if (!g.paused) {
				if (g.mouseDown) {
					//mainLayer.graphics.lineTo(stage.mouseX, stage.mouseY);
					g.magnetLayer.addChild(new Magnet(stage.mouseX, stage.mouseY));
				}
				
				// Updates
				g.ball.update();
				
				var aNode:DLLNode = g.magnets.head();
				while (aNode != null) {
					aNode.val.update();
					aNode = aNode.next;
				}
				
				// Collisions
				aNode = g.magnets.head();
				while (aNode != null) {
					if (g.ball.hitTestObject(aNode.val as Sprite)) {
						var ang:Number = Math.atan2(aNode.val.y - g.ball.y, aNode.val.x - g.ball.x);
						if(aNode.val.isPositive) {
							g.ball.xVel += Math.cos(ang);
							g.ball.yVel += Math.sin(ang);
						}
						else {
							g.ball.xVel -= Math.cos(ang);
							g.ball.yVel -= Math.sin(ang);
						}
					}
					aNode = aNode.next;
				}
				
				// Removal
				aNode = g.magnets.head();
				while (aNode != null) {
					if (aNode.val.life <= 0) {
						g.magnetLayer.removeChild(aNode.val as Sprite);
						aNode.remove();
					}
					aNode = aNode.next;
				}
			}
		}
		
		private function drawGrid():void
		{
			mainLayer.graphics.lineStyle(1, 0xFFFFFF, 0.2);
			for (var i:int = 0; i < 640; i += 40) {
				mainLayer.graphics.moveTo(i, 0);
				mainLayer.graphics.lineTo(i, 480);
			}
			for (var j:int = 0; j < 480; j += 40) {
				mainLayer.graphics.moveTo(0, j);
				mainLayer.graphics.lineTo(640, j);
			}
		}
		
		private function keyDown(ke:KeyboardEvent):void
		{
			if (ke.keyCode == 16) {
				g.shiftPressed = true;
			}
		}
		
		private function keyUp(ke:KeyboardEvent):void
		{
			if (ke.keyCode == 16) {
				g.shiftPressed = false;
			}
		}
		
		private function mDown(me:MouseEvent):void
		{
			g.mouseDown = true;
			mainLayer.graphics.lineStyle(40, 0xFF0000, 0.5);
			mainLayer.graphics.moveTo(stage.mouseX, stage.mouseY);
			//mainLayer.addChild(new Magnet(stage.mouseX, stage.mouseY));
		}
		
		private function mUp(me:MouseEvent):void
		{
			g.mouseDown = false;
		}
		
	}
	
}