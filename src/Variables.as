package  
{
	import Box2D.Dynamics.b2Body;
	import flash.display.*;
	import flash.filters.GlowFilter;
	import flash.media.*;
	import flash.text.*;
	import flash.utils.Timer;
	import views.Title;
	
	import de.polygonal.ds.*;
	
	public class Variables
	{
		public var timer:Timer;
		public var timeGoal:Number;
		public var paused:Boolean;
		public var shiftPressed:Boolean;
		public var mouseDown:Boolean;
		public var friction:Number;
		public var levelWidth:Number;
		public var levelPosition:Number;
		public var score:Number;
		public var hiscore:Number;
		
		public var sndChannel:SoundChannel;
		public var sndTrans:SoundTransform;
		
		public var goal:b2Body;
		public var balls:DLL;
		public var magnets:DLL;
		
		public var magnetLayer:Sprite;
		public var levelLayer:Sprite;
		public var ballLayer:Sprite;
		public var hudLayer:Sprite;
		
		public var titleScreen:Title;
		
		public var redFilter:GlowFilter;
		public var blueFilter:GlowFilter;
		
		public var styles:StyleSheet;
		public var scoreKeeper:TextField;
		public var timeKeeper:TextField;
		
		public function Variables() 
		{
			timer = new Timer(1000);
			timeGoal = 50;
			paused = true;
			shiftPressed = false;
			mouseDown = false;
			friction = 0.85;
			levelWidth = 2500;
			levelPosition = 0;
			score = 0;
			hiscore = 0;
			
			sndChannel = new SoundChannel();
			sndTrans = new SoundTransform(0.5);
			
			balls = new DLL();
			magnets = new DLL();
			
			magnetLayer = new Sprite();
			levelLayer = new Sprite();
			ballLayer = new Sprite();
			hudLayer = new Sprite();
			
			redFilter = new GlowFilter(0xFF0000, 0.3, 15, 15, 3);
			blueFilter = new GlowFilter(0x0000FF, 0.3, 15, 15, 3);
			
			styles = new StyleSheet();
			styles.parseCSS("h1{color:#FFFFFF;font-size:48px;}" +
							"h2{color:#FFFFFF;font-size:36px;}" +
							"h3{color:#CC3333;font-size:36px;}" +
							"h4{color:#FFFFFF;font-size:24px;}");
			buildHud();
		}
		
		private function buildHud():void
		{
			scoreKeeper = tfHelper(320,0);
			scoreKeeper.htmlText = "<font face='Laconic'><h4>Score: 0</h4></font>";
			hudLayer.addChild(scoreKeeper);
			
			timeKeeper = tfHelper(310, 450);
			timeKeeper.autoSize = TextFieldAutoSize.LEFT;
			timeKeeper.htmlText = "<font face='Laconic'><h4>9999</h4></font>";
			hudLayer.addChild(timeKeeper);
		}
		
		public function updateScore(amount:Number):void
		{
			score += amount;
			if (score > hiscore) { hiscore = score; }
			scoreKeeper.htmlText = "<font face='Laconic'><h4>Score: " + score + "</h4></font>";
		}
		
		public function updateTime():void
		{
			var timeLeft:Number = (timeGoal - timer.currentCount);
			timeKeeper.htmlText = "<font face='Laconic'><h4>" + timeLeft + "</h4></font>";
		}
		
		private function tfHelper(newX:Number, newY:Number):TextField
		{
			var tf:TextField = new TextField();
			tf.styleSheet = styles;
			tf.embedFonts = true;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.x = newX;
			tf.y = newY;
			
			return tf;
		}
		
	}

}