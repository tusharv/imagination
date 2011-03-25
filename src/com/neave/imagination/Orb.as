package com.neave.imagination
{
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;

	internal class Orb extends Shape
	{
		private var dx:Number;
		private var dy:Number;
		
		public function Orb(color:uint, x:Number, y:Number, dx:Number, dy:Number)
		{
			this.x = x;
			this.y = y;
			this.dx = dx;
			this.dy = dy;
			
			var size:Number = Math.random() * 6 + 2;
			size *= size;
			
			var m:Matrix = new Matrix();
			m.createGradientBox(size, size);
			m.translate(size / -2, size / -2);
			graphics.beginGradientFill(GradientType.RADIAL, [0xffffff, color], [0.5, 0], [0x00, 0xff], m);
			graphics.drawCircle(0, 0, size / 2);
			
			alpha = Math.random() * 0.8 + 0.2;
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(event:Event):void
		{
			x += dx;
			y += dy;
			dx += Math.random() * 16 - 8;
			dy += Math.random() * 16 - 8;
			dx *= 0.9;
			dy *= 0.9;
			width *= 1.1;
			height = width;
			alpha -= 0.05;
			if (alpha < 0.06) dispose();
		}
		
		public function dispose():void
		{
			removeEventListener(Event.ENTER_FRAME, update);
			if (parent) parent.removeChild(this);
		}
	}
}