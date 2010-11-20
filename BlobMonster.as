package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.BlendMode;
	import flash.geom.Point;
	
	public class BlobMonster extends Entity
	{
		[Embed(source="blob.png")]
		public static const BLOB: Class;
		
		public static var segments:int = 10 // Number of nodes along the body, try changing it to 100
		
		public var speed:Number = 1; // Speed, try changing it
	
		private var blob:Image; // Image used for all rendering
		private var time:Number = 0; // Time is a bit misleading, it's used for all sorts of things
		private var tail:Vector.<Point>; // Array to hold the points along the body
	
		public function BlobMonster ()
		{
			blob = new Image(BLOB); // Create an Image for the embedded blob.png
			blob.blend = BlendMode.ADD; // Additive blending
			blob.smooth = true;
			
			tail = new Vector.<Point>(segments, true);
			
			// Give the tail some coordinates, just make them the same as the main x and y for now
			for (var i:int = 0; i < segments; i++) {
				tail[i] = new Point;
			}
			
			// Don't make it go crazy at the start
			
			update();
			for (i = 0; i < segments; i++) {
				tail[i].x = x;
				tail[i].y = y;
			}
		}
		
		public override function update (): void
		{
			time += speed;
			
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
			y = (15 * Math.cos(time * -6 * FP.RAD)) + 240 + (180 * Math.sin(time * 1.3 * FP.RAD));
			x = (15 * Math.sin(time * -6 * FP.RAD)) + 320 + (200 * Math.cos(time / 1.5 * FP.RAD));
			
			// Put the head of the tail at x,y coords
			tail[0].x = x
			tail[0].y = y
	
			/*
			 * update the tail
			 * basically, the points don't move unless they're further that 7 pixels 
			 * from the previous point. this gives the kind of springy effect as the 
			 * body stretches
			 */
			for (var i:int = 1; i < tail.length; i++) {
	   			// Calculate distance between the current point and the previous
			    	var distX:Number = (tail[i - 1].x - tail[i].x);
				var distY:Number = (tail[i - 1].y - tail[i].y);
				var dist:Number = Math.sqrt(distX * distX + distY * distY);
				
	      			// Move if too far away
		 		if (dist > 7) {
					/*
					 * the (distX*0.3) bit makes the point move 
					 * just 30% of the distance. this makes the 
					 * movement smoother, and the point decelerate
					 * as it gets closer to the target point.
					 * try changing it to 1 (i.e 100%) to see what happens
					 */
					tail[i].x = tail[i].x + (distX * (0.3));
	    				tail[i].y = tail[i].y + (distY * (0.3));
		 		}
			}
	
		}
		
		public override function render (): void
		{
			blob.angle = 0;
			blob.color = 0x00C896; // 0, 200, 150
			
			var i:int;
			
			/*
			 * ###########
			 * draw the main bit of the body
			 * start by setting the images handle (i.e the origin of the image) to it's center
			 */
			setBlobOrigin(0.5, 0.5);
		
			// begin looping through the segments of the body
			for (i = 0; i < tail.length; i++) {
				blob.alpha = 0.15; // set the alpha transparency vaue to 0.15, pretty transparent
				
				// the  (0.5*sin(i*35)) bit basically bulges the size of the images being
				// drawn as it gets closer to the center of the monsters body, and tapers off in size as it gets 
				// to the end. try changing the 0.5 to a higher number to see the effect.
				blob.scaleX = blob.scaleY = 1 + (0.5 * Math.sin(i * 35 * FP.RAD));
				// draw the image
				blob.render(FP.buffer, tail[i], FP.camera);
				
				// this next chunk just draws smaller dots in the center of each segment of the body
				blob.alpha = 0.8;
				blob.scaleX = blob.scaleY = 0.1;
				blob.render(FP.buffer, tail[i], FP.camera);
			}
			
			/*
			 * #########################
			 * draw little spikes on tail
			 */
			blob.color = 0xFFFFFF // 255, 255, 255
			blob.scaleX = 0.6;
			blob.scaleY = 0.1;
		
			/*
			 * move the image handle to halfway down the left edge, this'll make the image
			 * appear to the side of the coordinate it is drawn too, rather than the 
			 * center as we had for the body sections
			 */
			setBlobOrigin(0, 0.5);
		
			/*
			 * rotate the 1st tail image. basically, we're calculating the angle between
			 * the last 2 points of the tail, and then adding an extra wobble (the 10*sin(time*10) bit)
			 * to make the pincer type effect.
			 */
			blob.angle = 10 * Math.sin(time * 10 * FP.RAD) + calculateAngle(
				tail[segments - 1].x, tail[segments - 1].y,
				tail[segments - 5].x, tail[segments - 5].y
			);
			blob.render(FP.buffer, tail[tail.length-1], FP.camera);
		
			// second tail image uses negative time to make it move in the opposite direction
			blob.angle = 10 * Math.sin(-time * 10 * FP.RAD) + calculateAngle(
				tail[segments - 1].x, tail[segments - 1].y,
				tail[segments - 5].x, tail[segments - 5].y
			);
			blob.render(FP.buffer, tail[tail.length-1], FP.camera);
			
			
			/*
			 * #####################
			 * draw little fins/arms
			 */
			blob.alpha = 1;
		
			// begin looping through the body sections again. Note that we don't want fins
			// on the first and last section because we want other things at those coords.
			for (i = 1; i < tail.length - 2; i++) {
				// like the bulging body, we want the fins to grow larger in the center, and smaller
				// at the end, so the same sort of thing is used here.
				blob.scaleX = 0.1 + (0.6 * Math.sin(i * 30 * FP.RAD));
				blob.scaleY = 0.05
			
				// rotate the image. We want the fins to stick out sideways from the body (the calculateangle() bit)
				// and also to move a little on their own. the 33 * Sin(time * 5 + i * 30) makes the 
				// fin rotate based in the i index variable, so that all the fins look like they're moving 
				// one after the other.
				blob.angle = 33 * Math.sin((time * 5 + i * 30) * FP.RAD) + calculateAngle(tail[i].x, tail[i].y, tail[i - 1].x, tail[i - 1].y) - 90;
				blob.render(FP.buffer, tail[i], FP.camera);
				
				// rotate the opposte fin, note that the signs have changes (-time and -i*30)
				// to reflect the rotations of the other fin
				blob.angle = 33 * Math.sin((-time * 5 - i * 30) * FP.RAD) + calculateAngle(tail[i].x, tail[i].y, tail[i - 1].x, tail[i - 1].y) + 90
				blob.render(FP.buffer, tail[i], FP.camera);
			}
			
			// ###################
			
			// center the image handle
			setBlobOrigin(0.5, 0.5);
			
			// Draw the eyes. These are just at 90 degrees to the head of the tail.
			blob.color = 0xFF0000; // 255, 0, 0
			blob.scaleX = blob.scaleY = 0.6;
			blob.alpha = 0.3;
			
			var ang:Number = calculateAngle(tail[0].x, tail[0].y, tail[1].x, tail[1].y);
			var ang1:Number = (ang - 45) * FP.RAD;
			var ang2:Number = (ang + 45) * FP.RAD;
			var p1:Point = new Point(x + (7 * Math.cos(ang1)), y + (7 * Math.sin(ang1)));
			var p2:Point = new Point(x + (7 * Math.cos(ang2)), y + (7 * Math.sin(ang2)));
			
			blob.render(FP.buffer, p1, FP.camera);
			blob.render(FP.buffer, p2, FP.camera);
			
			blob.color = 0xFFFFFF; // 255, 255, 255
			blob.scaleX = blob.scaleY = 0.1;
			blob.alpha = 0.5;
			blob.render(FP.buffer, p1, FP.camera);
			blob.render(FP.buffer, p2, FP.camera);
			
			// draw beaky thing
			blob.color = 0x00C89B; // 0, 200, 155
			blob.scaleX = 0.3;
			blob.scaleY = 0.1;
			blob.alpha = 0.8;
			
			setBlobOrigin(0, 0.5);
			blob.angle = ang;
			
			var p:Point = new Point(x, y);
			blob.render(FP.buffer, p, FP.camera);
			
			// yellow light
			blob.angle = 0;
			setBlobOrigin(0.5, 0.5);
			blob.color = 0xFFFF00; // 255, 255, 0
			blob.alpha = 0.2;
			blob.scaleX = blob.scaleY = 4;
			blob.render(FP.buffer, p, FP.camera);
		
			// Finished!
		}
		
		private function setBlobOrigin (originX:Number, originY:Number):void
		{
			blob.originX = originX * blob.width;
			blob.originY = originY * blob.width;
			
			// Have to set x/y as well because FlashPunk's origin system is stupid.
			blob.x = -blob.originX;
			blob.y = -blob.originY;
		}
		
		// This function calculates and returns the angle between two 2D coordinates
		private static function calculateAngle (x1:Number,y1:Number,x2:Number,y2:Number):Number
		{
			var theX:Number = x1-x2
			var theY:Number = y1-y2
			var theAngle:Number = Math.atan2(theY,theX);
			return theAngle * FP.DEG;
		}
	}
}

