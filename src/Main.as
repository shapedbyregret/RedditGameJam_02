package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	
	// 3rd party imports
	import de.polygonal.ds.*;
	
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	
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
		public static var m_world:b2World;
		private var m_iterations:int = 10;
		private var m_timeStep:Number = 1.0/30.0;
		private var body:b2Body;
		
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
			
			// Create world AABB
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-100.0, -10.0);
			worldAABB.upperBound.Set(100.0, 20.0);
			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 0.0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;
			
			// Construct a world object
			m_world = new b2World(worldAABB, gravity, doSleep);
			
			// Contact Listener
			var m_contactListener:b2ContactListener = new b2ContactListener();
			m_world.SetContactListener(m_contactListener);
			
			// Set debug draw
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			var dbgSprite:Sprite = new Sprite();
			addChild(dbgSprite);
			dbgDraw.m_sprite = dbgSprite;
			dbgDraw.m_drawScale = 30.0;
			dbgDraw.m_fillAlpha = 0.0;
			dbgDraw.m_lineThickness = 1.0;
			dbgDraw.m_drawFlags = 0xFFFFFFFF;
			m_world.SetDebugDraw(dbgDraw);
			
			buildWalls();
			for (var i:int = 0; i < 100; i++) {
				new Ball();
			}
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mUp);
			stage.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event = null):void
		{
			if (!g.paused) {
				
				updateEntities();
				collisions();
				removeEntities();
				
			}
		}
		
		private function updateEntities():void
		{
			m_world.Step(m_timeStep, m_iterations);
			for (var bb:b2Body = m_world.m_bodyList; bb; bb = bb.m_next) {
				// Go through body list and update sprite positions/rotations
				if (bb.m_userData is Sprite) {
					bb.m_userData.x = bb.GetPosition().x * 30;
					bb.m_userData.y = bb.GetPosition().y * 30;
					bb.m_userData.rotation = bb.GetAngle() * (180 / Math.PI);
				}
				
				var newX:Number;
				var newY:Number;
				//trace(g.levelPosition);
				if (stage.mouseX > 600 && stage.mouseX<620 && g.levelPosition<g.levelWidth) {
					newX = bb.GetXForm().position.x - 0.1;
					newY = bb.GetXForm().position.y;
					bb.SetXForm(new b2Vec2(newX, newY), bb.GetAngle());
					g.levelPosition += 0.1;
				}
				else if (stage.mouseX >= 620 && g.levelPosition < g.levelWidth) {
					newX = bb.GetXForm().position.x - 0.2;
					newY = bb.GetXForm().position.y;
					bb.SetXForm(new b2Vec2(newX, newY), bb.GetAngle());
					g.levelPosition += 0.2;
				}
				else if (stage.mouseX<40 && stage.mouseX>20 && g.levelPosition >= 0) {
					newX = bb.GetXForm().position.x + 0.1;
					newY = bb.GetXForm().position.y;
					bb.SetXForm(new b2Vec2(newX, newY), bb.GetAngle());
					g.levelPosition -= 0.1;
				}
				else if (stage.mouseX<=20 && g.levelPosition >= 0) {
					newX = bb.GetXForm().position.x + 0.2;
					newY = bb.GetXForm().position.y;
					bb.SetXForm(new b2Vec2(newX, newY), bb.GetAngle());
					g.levelPosition -= 0.2;
				}
			}
			
			// Updates
			var aNode:DLLNode = g.balls.head();
			while (aNode != null) {
				aNode.val.update();
				aNode = aNode.next;
			}
			
			var bNode:DLLNode = g.magnets.head();
			while (bNode != null) {
				bNode.val.update();
				bNode = bNode.next;
			}	
		}
		
		private function collisions():void
		{
			var aNode:DLLNode;
			var bNode:DLLNode;
			
			bNode = g.magnets.head();
			while (bNode != null) {
				aNode = g.balls.head();
				while(aNode!=null) {
					if (aNode.val.ballDef.userData.hitTestObject(bNode.val as Sprite)) {
						var ang:Number = Math.atan2(bNode.val.y - aNode.val.getY(), bNode.val.x - aNode.val.getX());
						if(bNode.val.isPositive) {
							aNode.val.xVel += (Math.cos(ang) * 0.01);
							aNode.val.yVel += (Math.sin(ang) * 0.01);
						}
						else {
							aNode.val.xVel -= (Math.cos(ang) * 0.01);
							aNode.val.yVel -= (Math.sin(ang) * 0.01);
						}
					}
					aNode = aNode.next;
				}
				bNode = bNode.next;
			}
		}
		
		private function removeEntities():void
		{
			// Removal
			var aNode:DLLNode;
			aNode = g.magnets.head();
			while (aNode != null) {
				if (aNode.val.life <= 0) {
					g.magnetLayer.removeChild(aNode.val as Sprite);
					aNode.remove();
				}
				aNode = aNode.next;
			}
		}
		
		private function drawGrid():void
		{
			mainLayer.graphics.lineStyle(1, 0xFFFFFF, 0.2);
			for (var i:int = 40; i < 2100; i += 40) {
				mainLayer.graphics.moveTo(i, 0);
				mainLayer.graphics.lineTo(i, 480);
			}
			for (var j:int = 0; j < 480; j += 40) {
				mainLayer.graphics.moveTo(0, j);
				mainLayer.graphics.lineTo(640, j);
			}
			
			mainLayer.graphics.lineStyle(10, 0xFFFFFF, 1);
			mainLayer.graphics.moveTo(0, 0);
			mainLayer.graphics.lineTo(1000, 0);
			mainLayer.graphics.moveTo(0, 0);
			mainLayer.graphics.lineTo(0, 480);
			mainLayer.graphics.moveTo(0, 480);
			mainLayer.graphics.lineTo(1000, 480);
		}
		
		private function buildWalls():void
		{
			var leftWallDef:b2BodyDef = new b2BodyDef();
			leftWallDef.position.Set(-0.5, 8);
			var leftWallBox:b2PolygonDef = new b2PolygonDef();
			leftWallBox.SetAsBox(0.5, 10);
			leftWallBox.friction = 0.3;
			leftWallBox.density = 0;
			body = m_world.CreateBody(leftWallDef);
			body.CreateShape(leftWallBox);
			body.SetMassFromShapes();
			
			var rightWallDef:b2BodyDef = new b2BodyDef();
			rightWallDef.position.Set(41, 2);
			var rightWallBox:b2PolygonDef = new b2PolygonDef();
			rightWallBox.SetAsBox(0.5, 5);
			rightWallBox.friction = 0;
			rightWallBox.density = 0;
			body = m_world.CreateBody(rightWallDef);
			body.CreateShape(rightWallBox);
			body.SetMassFromShapes();
			
			var rightWallDef2:b2BodyDef = new b2BodyDef();
			rightWallDef2.position.Set(41, 14);
			var rightWallBox2:b2PolygonDef = new b2PolygonDef();
			rightWallBox2.SetAsBox(0.5, 5);
			rightWallBox2.friction = 0;
			rightWallBox2.density = 0;
			body = m_world.CreateBody(rightWallDef2);
			body.CreateShape(rightWallBox2);
			body.SetMassFromShapes();
			
			var topWallDef:b2BodyDef = new b2BodyDef();
			topWallDef.position.Set(20.5, 0.0);
			var topWallBox:b2PolygonDef = new b2PolygonDef();
			topWallBox.SetAsBox(21, 0.1);
			topWallBox.friction = 0.3;
			topWallBox.density = 0;
			body = m_world.CreateBody(topWallDef);
			body.CreateShape(topWallBox);
			body.SetMassFromShapes();
			
			var bottomWallDef:b2BodyDef = new b2BodyDef();
			bottomWallDef.position.Set(20.5, 16.1);
			var bottomWallBox:b2PolygonDef = new b2PolygonDef();
			bottomWallBox.SetAsBox(21, 0.1);
			bottomWallBox.friction = 0.3;
			bottomWallBox.density = 0;
			body = m_world.CreateBody(bottomWallDef);
			body.CreateShape(bottomWallBox);
			body.SetMassFromShapes();
		}
		
		// Keyboard Down Listener
		private function keyDown(ke:KeyboardEvent):void
		{
			if (ke.keyCode == 80) {
				g.paused = !g.paused;
			}
			if (ke.keyCode == 16) {
				g.shiftPressed = true;
			}
		}
		
		// Keyboard Up Listener
		private function keyUp(ke:KeyboardEvent):void
		{
			if (ke.keyCode == 16) {
				g.shiftPressed = false;
			}
		}
		
		// Mouse Down Listener
		private function mDown(me:MouseEvent):void
		{
			g.mouseDown = true;
			g.magnetLayer.addChild(new Magnet(stage.mouseX, stage.mouseY));
			//mainLayer.graphics.lineStyle(40, 0xFF0000, 0.5);
			//mainLayer.graphics.moveTo(stage.mouseX, stage.mouseY);
			//mainLayer.addChild(new Magnet(stage.mouseX, stage.mouseY));
		}
		
		// Mouse Up Listener
		private function mUp(me:MouseEvent):void
		{
			g.mouseDown = false;
		}
		
	}
	
}