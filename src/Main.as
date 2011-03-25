package
{
	import com.neave.imagination.Imagination;
	
	import flash.display.Sprite;

	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="31")]	
	public class Main extends Sprite
	{
		private var imagination:Imagination;
		
		public function Main()
		{
			stage.showDefaultContextMenu = false;
			imagination = new Imagination(stage);
		}
	}
}