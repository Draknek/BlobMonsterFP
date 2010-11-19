package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.BlendMode;
	
	public class BlobMonster extends Entity
	{
		[Embed(source="blob.png")]
		public static const BLOB: Class;
		
		public var speed:Number = 1; // Speed, try changing it
		
		private var blob:Image; // Image used for all rendering
		private var time:Number = 0; // Time is a bit misleading, it's used for all sorts of things
		
		public function BlobMonster ()
		{
			blob = new Image(BLOB); // Create an Image for the embedded blob.png
			blob.centerOO(); // Center the image
			blob.blend = BlendMode.LIGHTEN; // Additive blending
		}
		
		public override function update (): void
		{
			time += speed / 60;
			
			/*
			 * here the x and y coordinates are updated.
			 * this uses the following as a basic rule for moving things
			 * around a point in 2d space:
			 * x=radius*cos(angle)+xOrigin
			 * y=raduis*sin(angle)+yOrigin
			 * this basically is the basis for anything that moves in this example
			 * 
			 * the 2 lines of code below make the monster move around, but
			 * you can change this to anything you like, try setting x and y to the mouse
			 * coordinates for example
			*/
			y = (15 * Math.cos(time * -6)) + (240 + (180 * Math.sin(time * 1.3)));
			x = (15 * Math.sin(time * -6)) + (320 + (200 * Math.cos(time / 1.5)));
		}
		
		public override function render (): void
		{
			blob.color = 0x00C896; // 0, 200, 150
			//blob.alpha = 0.15;
			Draw.graphic(blob, x, y);
		}
	}
}

