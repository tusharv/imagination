package com.neave.imagination
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	public class Imagination
	{
		// Main constants
		private const RED_STEP:Number = 0.02;
		private const GREEN_STEP:Number = 0.015;
		private const BLUE_STEP:Number = 0.025;
		private const MAX_LENGTH:uint = 100;
		private const SPREAD_MIN:uint = 1;
		private const SPREAD_MAX:uint = 24;
		private const SPREAD_TOUCH:uint = 8;
		
		private const ORIGIN:Point = new Point(0, 0);
		private const BLUR:BlurFilter = new BlurFilter(8, 8, 1);
		private const MATRIX:Matrix = new Matrix(0.5, 0, 0, 0.5, 0, 0);
		
		// Main variables
		private var stage:Stage;
		private var points:Vector.<ImaginationPoint>;
		private var px:int;
		private var py:int;
		private var tx:int;
		private var ty:int;
		private var size:Number;
		private var spread:uint;
		private var red:Number;
		private var green:Number;
		private var blue:Number;
		private var sprite:Sprite;
		private var graphics:Graphics;
		private var bitmap:Bitmap;
		private var bitmapData:BitmapData;
		private var blackBitmapData:BitmapData;
		private var rect:Rectangle;
		private var isTouch:Boolean;
		
		public function Imagination(stage:Stage)
		{
			this.stage = stage;
			
			initStage();
			initLines();
			initBitmap();
		}
		
		private function initStage():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onResize);
			
			isTouch = Multitouch.supportsTouchEvents;
			
			if (isTouch)
			{
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				spread = SPREAD_TOUCH;
				stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				stage.addEventListener(Event.ENTER_FRAME, update);
			}
			else
			{
				spread = SPREAD_MAX;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			px = stage.mouseX;
			py = stage.mouseY;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function initLines():void
		{
			points = new Vector.<ImaginationPoint>();
			size = 0;
			
			// Start using red
			red = 0;
			green = 0xff;
			blue = 0xff;
			
			// The main lines shape
			sprite = new Sprite();
			graphics = sprite.graphics;
		}
		
		private function initBitmap():void
		{
			// Stage sizes
			var sw:uint = stage.stageWidth;
			var sh:uint = stage.stageHeight;
			var sw2:uint = Math.ceil(sw * 0.5);
			var sh2:uint = Math.ceil(sh * 0.5);
			
			// Create the main bitmap to draw into (and half the size to run faster)
			bitmap = new Bitmap(new BitmapData(sw2, sh2, false, 0xff000000), PixelSnapping.NEVER, true);
			bitmapData = bitmap.bitmapData;
			rect = bitmapData.rect;
			bitmap.scaleX = bitmap.scaleY = 2;
			stage.addChild(bitmap);
			
			// Create bitmap data for fading into black
			blackBitmapData = bitmapData.clone();
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			// Allow a kind of drawing-mode when mouse is pressed
			spread = SPREAD_MIN;
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			// Spread lines out when mouse is released
			spread = SPREAD_MAX;
		}
		
		private function onTouchMove(event:TouchEvent):void
		{
			tx = event.stageX;
			ty = event.stageY;
		}
		
		private function onResize(event:Event):void
		{
			// Start again with the bitmap if the stage is resized
			stage.removeChild(bitmap);
			disposeBitmaps();
			initBitmap();
		}
		
		private function update(event:Event):void
		{
			if (isTouch) draw(tx, ty);
			else
			{
				draw(stage.mouseX, stage.mouseY);
				if (spread == SPREAD_MIN)
				{
					for (var i:uint = 8; i--; )
					{
						sprite.addChild(new Orb(points[points.length - 1].color, stage.mouseX + (Math.random() - 0.5) * 8, stage.mouseY + (Math.random() - 0.5) * 8, (Math.random() - 0.5) * 8, (Math.random() - 0.5) * 8));
					}
				}
			}
		}
		
		private function draw(mx:uint, my:uint):void
		{
			// Line movement
			var dx:int = (mx - px + (isTouch ? 0 : Math.random() * 4 - 2)) * 0.5;
			var dy:int = (my - py + (isTouch ? 0 : Math.random() * 4 - 2)) * 0.5;
			
			// Limit the amount of movement
			if (dx < -spread) dx = -spread;
			else if (dx > spread) dx = spread;
			if (dy < -spread) dy = -spread;
			else if (dy > spread) dy = spread;
			
			// Store the mouse position
			px = mx;
			py = my;
			
			// Create a new point on the line
			points.push(new ImaginationPoint(
				px, py,
				dx, dy,
				Math.sin(size += 0.125) * 7 + 1,
				(Math.sin(red += RED_STEP) * 128 + 127) << 16
				| (Math.sin(green += GREEN_STEP) * 128 + 127) << 8
				| (Math.sin(blue += BLUE_STEP) * 128 + 127)
			));
			
			// Remove the last point from the list if we've reached the maximum length
			if (points.length > MAX_LENGTH) points.shift();
			
			// Draw!
			drawLines();
			drawBitmap();
		}
		
		private function drawLines():void
		{
			// Clear the graphics before we draw the lines
			graphics.clear();
			graphics.moveTo(px, py);
			
			var p0:ImaginationPoint, p1:ImaginationPoint;
			
			// Draw a curve through the points
			for (var i:uint = points.length - 1; i > 0; i--)
			{
				p0 = points[i];
				p1 = points[i - 1];
				
				// Animate the points outwards
				p0.spread();
				
				// Draw the curve, fading out the last 32 points with alpha
				graphics.lineStyle(p0.size, p0.color, (points.length > (MAX_LENGTH - 32) && i < 32) ? i / 32 : 1);
				graphics.curveTo(p0.x, p0.y, (p0.x + p1.x) * 0.5, (p0.y + p1.y) * 0.5);
			}
		}
		
		private function drawBitmap():void
		{
			// Repeatedly fade out and blur the lines then draw in the new ones
			bitmapData.lock();
			bitmapData.applyFilter(bitmapData, rect, ORIGIN, BLUR);
			bitmapData.merge(blackBitmapData, bitmapData.rect, ORIGIN, 2, 2, 2, 0);
			bitmapData.draw(sprite, MATRIX, null, BlendMode.ADD);
			bitmapData.unlock();
		}
		
		private function disposeBitmaps():void
		{
			bitmap.bitmapData.dispose();
			bitmap.bitmapData = null;
			blackBitmapData.dispose();
			blackBitmapData = null;
		}
	}
}