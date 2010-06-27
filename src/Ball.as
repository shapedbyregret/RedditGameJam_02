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
		
		public function Ball()
		{
			xVel = 0;
			yVel = 0;
			
			graphics.beginFill(0xFFFFFF, 1);
			graphics.drawCircle(0, 0, 2);
			graphics.endFill();
			
			var ballDef:b2BodyDef = new b2BodyDef();
			var ballShape:b2CircleDef = new b2CircleDef();
			ballShape.radius = 0.15;
			ballShape.density = 5;
			ballShape.friction = 10;
			ballShape.restitution = 1;
			var ballSprite:Sprite = new Sprite();
			ballSprite.graphics.beginFill(0xFFFFFF, 1);
			ballSprite.graphics.drawCircle(0, 0, 2);
			ballSprite.graphics.endFill();
			ballDef.userData = ballSprite;
			ballDef.userData.width = 0.15 * 2 * 30;
			ballDef.userData.height = 0.15 * 2 * 30;
			ballDef.userData.name = "ball";
			ballBody = Main.m_world.CreateBody(ballDef);
			ballBody.CreateShape(ballShape);
			ballBody.SetMassFromShapes();
			addChild(ballDef.userData);
			
			ballBody.SetXForm(new b2Vec2(Math.random() * 2, Math.random() * 2), 0);
			ballBody.GetXForm().position.x;
			
			Main.g.balls.append(this);
			Main.g.ballLayer.addChild(this);
		}
		
		public function update():void
		{
			ballBody.ApplyForce(new b2Vec2(xVel, yVel), ballBody.GetWorldCenter());
		}
		
	}

}