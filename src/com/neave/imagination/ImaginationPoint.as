package com.neave.imagination
{
	internal class ImaginationPoint
	{
		internal var x:int;
		internal var y:int;
		internal var dx:int;
		internal var dy:int;
		internal var size:Number;
		internal var color:uint;
		
		public function ImaginationPoint(x:int, y:int, dx:int, dy:int, size:Number, color:uint)
		{
			this.x = x;
			this.y = y;
			this.dx = dx;
			this.dy = dy;
			this.size = size;
			this.color = color;
		}
		
		public function spread():void
		{
			x += dx;
			y += dy;
		}
	}
}