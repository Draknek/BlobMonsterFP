'How to make an Irukandji style blob monster.
'By Charlie Knight, 2009/2010
'http://www.charliesgames.com
'
'This code is public domain. Feel free to use as you please.
'If you use the code as a basis for your own blob monsters, let me know! I'd love to
'see what you came up with!
'
'The code is written using the Blitzmax language, but it should be fairly easy to port
'to C++/Java/Whatever with a suitable graphics library.
'
'the image blob.png can be found at http://www.charliesgames.com/wpimages/blob.png
'
'Cheers
'Charlie

SuperStrict

AppTitle=("Charlie's Blob Monster!")

'open a graphics window
Graphics 640, 480, 0, 60

'load the image
Global blob:TImage = LoadImage("blob.png")

'simple class (type in Blitzmax) to hold a 2d coordinate
Type point
	Field x:Float, y:Float
End Type

'here's the blob monster type
Type blobMonster
	
	'x and y coords
	Field x:Float, y:Float
	
	'speed, try changing it
	Field speed:Float = 1
	
	'number of nodes along the body, try changing it to 100
	Field segments:Float = 10
	
	'array to hold the points along the body
	Field tail:point[segments]
	
	Field time:Float = 0
	
	'function that returns a new blob monster object. Blitzmax equivalent (kind of)
	'of a constructor in C++/Java
	Function Create:blobMonster(inX:Float, iny:Float)
		Local n:blobMonster = New blobMonster
		'starting point of the blob monster
		n.x = inX
		n.y = iny
		'give the tail some coordinates, just make them the same as the main x and y for now
		For Local i:Int = 0 To n.segments - 1
			n.tail[i] = New point
			n.tail[i].x = inX
			n.tail[i].y = iny
		
		Next
		
		Return n
	End Function
	
	Method Update:Int()
		'time is a bit misleading, it's used for all sorts of things
		time:+speed
		
		'here the x and y coordinates are updated.
		'this uses the following as a basic rule for moving things
		'around a point in 2d space:
		'x=radius*cos(angle)+xOrigin
		'y=raduis*sin(angle)+yOrigin
		'this basically is the basis for anything that moves in this example
		'
		'the 2 lines of code below make the monster move around, but
		'you can change this to anything you like, try setting x and y to the mouse
		'coordinates for example
		y = (15 * Cos(time * -6)) + (240 + (180 * Sin(time * 1.3)))
		x = (15 * Sin(time * -6)) + (320 + (200 * Cos(time / 1.5)))
		
		'put the head of the tail at x,y coords
		tail[0].x = x
		tail[0].y = y
	
		'update the tail
		'basically, the points don't move unless they're further that 7 pixels 
		'from the previous point. this gives the kind of springy effect as the 
		'body stretches
		For Local i:Int = 1 To segments - 1
   				'calculate distance between the current point and the previous
		    	Local distX:Float = (tail[i - 1].x - tail[i].x)
        		Local distY:Float = (tail[i - 1].y - tail[i].y)
				Local dist:Float = Sqr(distX * distX + distY * distY)
      			'move if too far away
         		If dist > 7 Then
					'the (distX*0.2) bit makes the point move 
					'just 20% of the distance. this makes the 
					'movement smoother, and the point decelerate
					'as it gets closer to the target point.
					'try changing it to 1 (i.e 100%) to see what happens
					tail[i].x = tail[i].x + (distX * (0.3))
            		tail[i].y = tail[i].y + (distY * (0.3))
         		EndIf
			
		Next
	
		Return False
	End Method
	
	Method Draw()
		'time to draw stuff!
		
		'this sets the blend mode to LIGHTBLEND, or additive blending, which makes
		'the images progressively more bright as they overlap
		SetBlend LIGHTBLEND
		SetColor 0, 200, 150
		
		
		'###########
		'draw the main bit of the body
		'start by setting the images handle (i.e the origin of the image) to it's center
		MidHandleImage blob
		
		'begin looping through the segments of the body
		For Local i:Int = 0 To segments - 1
			'set the alpha transparency vaue to 0.15, pretty transparent
			SetAlpha 0.15
			'the  (0.5*sin(i*35)) bit basically bulges the size of the images being
			'drawn as it gets closer to the center of the monsters body, and tapers off in size as it gets 
			'to the end. try changing the 0.5 to a higher number to see the effect.
			SetScale 1 + (0.5 * Sin(i * 35)), 1 + (0.5 * Sin(i * 35))
			'draw the image
			DrawImage blob, tail[i].x, tail[i].y
			
			'this next chunk just draws smaller dots in the center of each segment of the body
			SetAlpha 0.8
			SetScale 0.1, 0.1
			DrawImage blob, tail[i].x, tail[i].y
		Next
		
		'#########################
		'draw little spikes on tail
		SetColor 255, 255, 255
		'note that the x and y scales are different
		SetScale 0.6, 0.1
		
		'move the image handle to halfway down the left edge, this'll make the image
		'appear to the side of the coordinate it is drawn too, rather than the 
		'center as we had for the body sections
		SetImageHandle blob, 0, ImageHeight(blob) / 2
		
		'rotate the 1st tail image. basically, we're calculating the angle between
		'the last 2 points of the tail, and then adding an extra wobble (the 10*sin(time*10) bit)
		'to make the pincer type effect.
		SetRotation 10 * Sin(time * 10) + calculateAngle(tail[segments - 1].x, tail[segments - 1].y, tail[segments - 5].x, tail[segments - 5].y) + 90
		DrawImage blob, tail[segments - 1].x, tail[segments - 1].y
		
		'second tail image uses negative time to make it move in the opposite direction
		SetRotation 10 * Sin(-time * 10) + calculateAngle(tail[segments - 1].x, tail[segments - 1].y, tail[segments - 5].x, tail[segments - 5].y) + 90
		DrawImage blob, tail[segments - 1].x, tail[segments - 1].y

		
		
		'#####################
		'draw little fins/arms
		SetAlpha 1
		
		'begin looping through the body sections again. Note that we don't want fins
		'on the first and last section because we want other things at those coords.
		For Local i:Int = 1 To segments - 2
			'like the bulging body, we want the fins to grow larger in the center, and smaller
			'at the end, so the same sort of thing is used here.
			SetScale 0.1 + (0.6 * Sin(i * 30)), 0.05
			
			'rotate the image. We want the fins to stick out sideways from the body (the calculateangle() bit)
			'and also to move a little on their own. the 33 * Sin(time * 5 + i * 30) makes the 
			'fin rotate based in the i index variable, so that all the fins look like they're moving 
			'one after the other.
			SetRotation 33 * Sin(time * 5 + i * 30) + calculateAngle(tail[i].x, tail[i].y, tail[i - 1].x, tail[i - 1].y)
			DrawImage blob, tail[i].x, tail[i].y
			
			'rotate the opposte fin, note that the signs have changes (-time and -i*30)
			'to reflect the rotations of the other fin
			SetRotation 33 * Sin(-time * 5 - i * 30) + calculateAngle(tail[i].x, tail[i].y, tail[i - 1].x, tail[i - 1].y) + 180
			DrawImage blob, tail[i].x, tail[i].y
			
		Next
		
		
		'###################
		'center the image handle
		MidHandleImage blob
		'Draw the eyes. These are just at 90 degrees to the head of the tail.
		SetColor 255, 0, 0
		SetScale 0.6, 0.6
		SetAlpha 0.3
		Local ang:Float = calculateangle(tail[0].x, tail[0].y, tail[1].x, tail[1].y)
		DrawImage blob, x + (7 * Cos(ang + 50)), y + (7 * Sin(ang + 50))
		DrawImage blob, x + (7 * Cos(ang + 140)), y + (7 * Sin(ang + 140))
		SetColor 255, 255, 255
		SetScale 0.1, 0.1
		SetAlpha 0.5
		DrawImage blob, x + (7 * Cos(ang + 50)), y + (7 * Sin(ang + 50))
		DrawImage blob, x + (7 * Cos(ang + 140)), y + (7 * Sin(ang + 140))
	
		'draw beaky thing
		SetColor 0, 200, 155
		SetScale 0.3, 0.1
		SetAlpha 0.8
		SetImageHandle blob, 0, ImageWidth(blob) / 2
		SetRotation ang + 95
		DrawImage blob, x, y
		
		'yellow light
		MidHandleImage blob
		SetColor 255, 255, 0
		SetAlpha 0.2
		SetScale 4, 4
		DrawImage blob, x, y
		
		'Finished!
	End Method
	
EndType

'This function calculates and returns the angle between two 2d coordinates
Function calculateAngle:Float(x1:Float,y1:Float,x2:Float,y2:Float)
	Local theX:Float=x1-x2
	Local theY:Float=y1-y2
	Local theAngle:Float=-ATan2(theX,theY)
	Return theAngle
End Function



'create a blobMonster object
Local test:blobMonster = New blobMonster.Create(10, 10)

'main loop
While Not KeyHit(KEY_ESCAPE)
	'update and draw the blobmonster
	test.Update()
	test.Draw()
	
	Flip;Cls
Wend

EndGraphics()
End
'Finished!