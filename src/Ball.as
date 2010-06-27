package  
{
	import flash.display.*;
	
	// 3rd Party Imports
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	
	public class Ball extends Sprite
	{
		
		public var xVel:Number;
		public var yVel:Number;
		public var ballBody:b2Body;
		public var ballDef:b2BodyDef;
		
		public function Ball()
		{
			xVel = 0;
			yVel = 0;
			
			graphics.beginFill(0xFFFFFF, 1);
			graphics.drawCircle(0, 0, 2);
			graphics.endFill();
			
			ballDef = new b2BodyDef();
			var ballShape:b2CircleDef = new b2CircleDef();
			ballShape.radius = 0.15;
			ballShape.density = 0.1;
			ballShape.friction = 1;
			ballShape.restitution = 0.2;
			var ballSprite:Sprite = new Sprite();
			ballSprite.graphics.lineStyle(0.5, 0xFFFFFF, 1);
			ballSprite.graphics.beginFill(0x0000FF, 1);
			ballSprite.graphics.drawCircle(0, 0, 2);
			ballSprite.graphics.endFill();
			ballSprite.graphics.moveTo(-1, 0);
			ballSprite.graphics.lineTo(1, 0);
			ballDef.userData = ballSprite;
			ballDef.userData.width = 0.15 * 2 * 30;
			ballDef.userData.height = 0.15 * 2 * 30;
			ballDef.userData.name = "ball";
			ballBody = Main.m_world.CreateBody(ballDef);
			ballBody.CreateShape(ballShape);
			ballBody.SetMassFromShapes();
			addChild(ballDef.userData);
			
			ballBody.SetXForm(new b2Vec2(1 + Math.random() * 8, 1 + Math.random() * 8), 0);
			ballBody.GetXForm().position.x;
			
			Main.g.balls.append(this);
			Main.g.ballLayer.addChild(this);
		}
		
		public function update():void
		{
			ballBody.ApplyForce(new b2Vec2(xVel, yVel), ballBody.GetWorldCenter());
			xVel *= Main.g.friction;
			yVel *= Main.g.friction;
		}
		
		public function getX():Number
		{
			return ballBody.GetWorldCenter().x * 30;
		}
		
		public function getY():Number
		{
			return ballBody.GetWorldCenter().y * 30;
		}
		
	}

}