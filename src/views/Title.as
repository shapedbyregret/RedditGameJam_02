package views 
{
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.*;
	
	public class Title extends Sprite
	{
		
		private var hiscoreKeeper:TextField;
		
		public function Title() 
		{
			graphics.beginFill(0x111111, 0.9);
			graphics.drawRect(0, 0, 640, 480);
			graphics.endFill();
			
			var title:TextField = tfHelper(320, 40);
			title.htmlText = "<font face='Laconic'><h1>F*ckin Magnets</h1></font>";
			addChild(title);
			
			hiscoreKeeper = tfHelper(320, 200);
			hiscoreKeeper.htmlText = "<font face='Laconic'><h2>High Score: 0</h2></font>";
			addChild(hiscoreKeeper);
			
			var play:TextField = tfHelper(0, 0);
			play.htmlText = "<font face='Laconic'><h2>Play</h2></font>";
			var playHover:TextField = tfHelper(0, 0);
			playHover.htmlText = "<font face='Laconic'><h3>Play</h3></font>";
			var playButton:SimpleButton = new SimpleButton(play, playHover, playHover, playHover);
			playButton.x = 320;
			playButton.y = 400;
			playButton.addEventListener(MouseEvent.CLICK, beginGame);
			addChild(playButton);
		}
		
		private function beginGame(me:MouseEvent = null):void
		{
			Main.g.paused = false;
			Main.g.score = 0;
			Main.g.updateScore(0);
			Main.g.timer.reset();
			Main.g.timer.start();
			Main.g.timeGoal = 50;
			Main.g.levelPosition = 0;
			toggleVisibility();
		}
		
		public function toggleVisibility():void
		{
			visible = !visible;
			hiscoreKeeper.htmlText = "<font face='Laconic'><h2>High Score: " + Main.g.hiscore + "</h2></font>";
		}
		
		private function tfHelper(newX:Number, newY:Number):TextField
		{
			var tf:TextField = new TextField();
			tf.selectable = false;
			tf.styleSheet = Main.g.styles;
			tf.embedFonts = true;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.x = newX;
			tf.y = newY;
			
			return tf;
		}
	}

}