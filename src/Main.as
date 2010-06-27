package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.media.Sound;
	import views.Title;
	
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
		[Embed(source="Laconic_Regular.otf", fontFamily="Laconic")]
		private var Laconic:String;
		
		// Embed sounds
		[Embed(source = "sounds/goal.mp3")]
		private var Goal:Class;
		[Embed(source = "sounds/magnetized2.mp3")]
		private var Magnetized:Class;
		
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
			mainLayer.addChild(g.hudLayer);
			g.titleScreen = new Title();
			g.hudLayer.addChild(g.titleScreen);
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
			/*var dbgDraw:b2DebugDraw = new b2DebugDraw();
			var dbgSprite:Sprite = new Sprite();
			addChild(dbgSprite);
			dbgDraw.m_sprite = dbgSprite;
			dbgDraw.m_drawScale = 30.0;
			dbgDraw.m_fillAlpha = 0.0;
			dbgDraw.m_lineThickness = 1.0;
			dbgDraw.m_drawFlags = 0xFFFFFFFF;
			m_world.SetDebugDraw(dbgDraw);*/
			
			buildWalls();
			for (var i:int = 0; i < 100; i++) {
				new Ball();
			}
			addObstacles();
			
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
				g.updateTime();
				
				// Game Over
				if (g.timeGoal - g.timer.currentCount <= 0) {
					g.paused = true;
					g.timer.stop();
					g.titleScreen.toggleVisibility();
					for (var bb:b2Body = m_world.m_bodyList; bb; bb = bb.m_next) {
						if (bb.GetUserData() != null && bb.GetUserData().name == "ball") {
							var p:Sprite = bb.GetUserData().parent;
							m_world.DestroyBody(bb);
							p.removeChild(bb.GetUserData());
							g.ballLayer.removeChild(p);
						}
						else if (bb.GetUserData() != null && bb.GetUserData().name == "obstacle") {
							var p2:Sprite = bb.GetUserData().parent;
							m_world.DestroyBody(bb);
							p2.removeChild(bb.GetUserData());
							//g.levelLayer.removeChild(p2);
						}
						else {
							m_world.DestroyBody(bb);
						}
					}
					buildWalls();
					for (var i:int = 0; i < 100; i++) {
						new Ball();
					}
					addObstacles();
				}
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
				if (stage.mouseX > 600 && stage.mouseX<620 && g.levelPosition<=g.levelWidth) {
					newX = bb.GetXForm().position.x - 0.1;
					newY = bb.GetXForm().position.y;
					bb.SetXForm(new b2Vec2(newX, newY), bb.GetAngle());
					g.levelPosition += 0.1;
				}
				else if (stage.mouseX >= 620 && g.levelPosition <= g.levelWidth) {
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
				
				// Remove ball and score point
				if (bb.GetUserData() != null && bb.GetUserData().name == "ball") {
					var p:Sprite = bb.GetUserData().parent;
					if (bb.GetUserData().hitTestObject(g.goal.GetUserData())) {
						g.updateScore(1);
						//var goal:Sound = new Goal() as Sound;
						//g.sndChannel = goal.play(0, 0, g.sndTrans);
						m_world.DestroyBody(bb);
						p.removeChild(bb.GetUserData());
						g.ballLayer.removeChild(p);
					}
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
						//var magnetized:Sound = new Magnetized() as Sound;
						//g.sndChannel = magnetized.play(0, 0, g.sndTrans);
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
			for (var i:int = 40; i < 640; i += 40) {
				mainLayer.graphics.moveTo(i, 0);
				mainLayer.graphics.lineTo(i, 480);
			}
			for (var j:int = 0; j < 480; j += 40) {
				mainLayer.graphics.moveTo(0, j);
				mainLayer.graphics.lineTo(640, j);
			}
			
			mainLayer.graphics.lineStyle(2, 0xFFFFFF, 1);
			mainLayer.graphics.moveTo(0, 0);
			mainLayer.graphics.lineTo(640, 0);
			mainLayer.graphics.moveTo(0, 0);
			mainLayer.graphics.lineTo(0, 480);
			mainLayer.graphics.moveTo(0, 480);
			mainLayer.graphics.lineTo(640, 480);
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
			var rightWallSprite:Sprite = new Sprite();
			rightWallSprite.graphics.beginFill(0xFFFFFF, 1);
			rightWallSprite.graphics.drawRect(-0.5 * 30, -5 * 30, 0.5 * 2 * 30, 5 * 2 * 30);
			rightWallSprite.graphics.endFill();
			rightWallSprite.name = "obstacle";
			rightWallDef.userData = rightWallSprite;
			body = m_world.CreateBody(rightWallDef);
			body.CreateShape(rightWallBox);
			body.SetMassFromShapes();
			mainLayer.addChild(rightWallDef.userData);
			
			var rightWallDef2:b2BodyDef = new b2BodyDef();
			rightWallDef2.position.Set(41, 14);
			var rightWallBox2:b2PolygonDef = new b2PolygonDef();
			rightWallBox2.SetAsBox(0.5, 5);
			rightWallBox2.friction = 0;
			rightWallBox2.density = 0;
			var rightWallSprite2:Sprite = new Sprite();
			rightWallSprite2.graphics.beginFill(0xFFFFFF, 1);
			rightWallSprite2.graphics.drawRect(-0.5 * 30, -5 * 30, 0.5 * 2 * 30, 5 * 2 * 30);
			rightWallSprite2.graphics.endFill();
			rightWallSprite2.name = "obstacle";
			rightWallDef2.userData = rightWallSprite2;
			body = m_world.CreateBody(rightWallDef2);
			body.CreateShape(rightWallBox2);
			body.SetMassFromShapes();
			mainLayer.addChild(rightWallDef2.userData);
			
			var goalDef:b2BodyDef = new b2BodyDef();
			goalDef.position.Set(41, 8);
			var goalBox:b2PolygonDef = new b2PolygonDef();
			goalBox.filter.groupIndex = -2;
			goalBox.SetAsBox(0.5, 1);
			goalBox.friction = 0;
			goalBox.density = 0;
			var goalSprite:Sprite = new Sprite();
			goalSprite.graphics.beginFill(0xFFFF00, 0.3);
			goalSprite.graphics.drawRect(-0.5 * 30, -1 * 30, 0.5 * 2 * 30, 1 * 2 * 30);
			goalSprite.graphics.endFill();
			goalSprite.name = "obstacle";
			goalDef.userData = goalSprite;
			g.goal = m_world.CreateBody(goalDef);
			g.goal.CreateShape(goalBox);
			g.goal.SetMassFromShapes();
			mainLayer.addChild(goalDef.userData);
			
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
		
		private function addObstacles():void
		{
			for (var i:int = 0; i < 20; i++) {
				var newW:Number = 0.5 + Math.random() * 0.5;
				var newH:Number = 0.5 + Math.random() * 0.5;
				var newX:Number = 5 + Math.random() * 30;
				var newY:Number = 1 + Math.random() * 14;
				
				var obstacleDef:b2BodyDef = new b2BodyDef();
				obstacleDef.position.Set(newX, newY);
				var obstacleBox:b2PolygonDef = new b2PolygonDef();
				obstacleBox.SetAsBox(newW, newH);
				obstacleBox.friction = 0.1;
				obstacleBox.density = 0.3;
				var obstacleSprite:Sprite = new Sprite();
				obstacleSprite.graphics.beginFill(0xFFFFFF, 0.3);
				obstacleSprite.graphics.drawRect(-newW * 30, -newH * 30, newW * 2 * 30, newH * 2 * 30);
				obstacleSprite.graphics.endFill();
				obstacleSprite.name = "obstacle";
				obstacleDef.userData = obstacleSprite;
				body = m_world.CreateBody(obstacleDef);
				body.CreateShape(obstacleBox);
				body.SetMassFromShapes();
				g.levelLayer.addChild(obstacleDef.userData);
			}
		}
		
		// Keyboard Down Listener
		private function keyDown(ke:KeyboardEvent):void
		{
			if (ke.keyCode == 80 && !g.titleScreen.visible) {
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
			if(!g.paused) {
				g.mouseDown = true;
				g.magnetLayer.addChild(new Magnet(stage.mouseX, stage.mouseY));
			}
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