package
{
	import com.neave.imagination.Imagination;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	[SWF(width="800", height="600", backgroundColor="#ffffff", frameRate="31")]	
	public class Main extends Sprite
	{
		private var imagination:Imagination;
		
		public function Main()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.showDefaultContextMenu = false;
			
			imagination = new Imagination(stage.stageWidth, stage.stageHeight);
			addChild(imagination);
			
			stage.addEventListener(Event.RESIZE, resizeImagination);			
		}
		
		private function resizeImagination(event:Event):void
		{
			imagination.setSize(stage.stageWidth, stage.stageHeight);
		}
	}
}