'Parallax Scrolling Demo
'Author Jesus Perez

#Import "<mojo>"
#Import "<std>"
#Import "data/runner.png"
#Import "data/sky.png"
#Import "data/mountains.png"
#Import "data/soil1.png"
#Import "data/soil2.png"
#Import "data/soil3.png"
#Import "data/mountains2.png"
#Import "data/cloud1.png"
#Import "data/cloud2.png"
#Import "data/cloud3.png"
#Import "data/cloud4.png"
#Import "data/runingdog.png"
#Import "data/cat.png"
#Import "data/tera.png"
#Import "data/bee.png"
#Import "data/bomb.png"
#Import "data/impact.png"
#Import "data/burnt.png"
		
#Import "data/explode.ogg"
#Import "data/don.ogg"
#Import "data/ouch.ogg"
#Import "data/proposition.ogg"

Using mojo..
Using std..

Global list:List <TileRow>
Global bombStore:List <Bomb>

Global background:Image
Global background1:Image
Global background2:Image
Global background3:Image
Global background4:Image
Global background5:Image
Global background7:Image
    
Global clouds1:Image
Global cloud2:Image
Global cloud3:Image
Global cloud4:Image
       
Global beastImg:Image[]
Global dogImg:Image[]
Global beeImg:Image[]
Global catImg:Image[]
Global teraImg:Image[]
Global flyImg:Image
Global bombImg:Image
Global snakeImg:Image
    
Global showBox:Int = False

Global bopSound:Sound
Global expSound:Sound
Global tuneSound:Sound
Global ouchSound:Sound

Global music:Sound

Global musicChannel:Channel
Global channel:Channel[]
Global channelIndex:Int
        
Global walkRight:Int[] =New Int[](0,6)
Global crouchRightDown:Int[] = New Int[](6,2)
Global crouchRightUp:Int[] = New Int[](7,2)
Global framed:Int[] = New Int [](9,3)

Global itMoving:Int[] = New Int[](0,6)
Global itMove2:Int[] = New Int[](0,7)
  
Global fps:Int
Global fpsTemp:Int
Global lastTime:Int
Global time:Int
Global font:Font

Function collided:Int (x1:Float,y1:Float,box1:HitBox,x2:Float,y2:Float,box2:HitBox)
	Local b1x1:Float = x1 + box1.offx
	Local b1y1:Float = y1 + box1.offy
	Local b1x2:Float = x1 + box1.width
	Local b1y2:Float = y1 + box1.height
	Local b2x1:Float = x2 + box2.offx
	Local b2y1:Float = y2 + box2.offy
	Local b2x2:Float = x2 + box2.width
	Local b2y2:Float = y2 + box2.height
	If b1x1 > b2x2 Return False
	If b1x2 < b2x1 Return False
	If b1y1 > b2y2 Return False
	If b1y2 < b2y1 Return False 	
	Return True
End Function

Function TileImageAcross:Void(canvas:Canvas,image:Image,x:Float,y:Float,width:Float)
	Local w:Int = width-1
	Local ox:Int = -w+1
	Local px:Int = x
	Local fx:Int = px - Int(px)
	Local tx:Int = Int(px) - ox

	If (tx >= 0)
		tx=tx Mod w + ox
	Else
		tx=w + tx Mod w + ox
	Endif
	Local vr:Int = 640
	Local ix:Int = tx
	While(ix < vr)
	   canvas.DrawImage(image,ix+fx,y)
	   ix=ix+w
	Wend
End Function

Class Button
	Field x:Int
	Field y:Int
	Field tx:Int
	Field ty:Int
	Field text:String
	Field width:Int
	Field height:Int
	Field freeColor:Color
	Field overColor:Color
	Field selectedColor:Color
	Field currentColor:Color
	
	Method New(x:Int,y:Int,width:Int,height:Int,text:String,tx:Int,ty:Int)
		Self.x = x
		Self.y = y
		Self.width = width
		Self.height = height
		Self.text = text
		Self.tx = tx
		Self.ty = ty
		freeColor = New Color(.2,.2,.6) '(50,50,150)
		overColor = New Color(.2,.6,.6) '(50,150,150)
		selectedColor =  New Color(.6,.2,.2) '(150,50,50)
		currentColor = freeColor
	End Method
	
	Method activated:Int()
		Return (currentColor.R = selectedColor.R) And (currentColor.G = selectedColor.G) And (currentColor.B = selectedColor.B)
	End Method
	
	Method Update:Void()
	
		Local mx:Int = Mouse.X
		Local my:Int = Mouse.Y
		Local b1:Int = Mouse.ButtonDown(MouseButton.Left)
		
		If mx < x Or mx > (x+width) Or my < y Or my > (y+height)
			currentColor = freeColor
		Elseif b1
			currentColor = selectedColor
		Else
			currentColor = overColor
		Endif
		
	End Method
	
	Method Render:Void(canvas:Canvas)
		canvas.Color = currentColor
		canvas.DrawRect(x,y,width,height)
		If (currentColor.R = freeColor.R And currentColor.G = freeColor.G And currentColor.B = freeColor.B) Or (currentColor.R = overColor.R And currentColor.G = overColor.G And currentColor.B = overColor.B)
				canvas.Color = new Color(1,1,1)
				canvas.DrawLine( x,y,x+width,y)
				canvas.DrawLine( x,y,x,y+height)
				canvas.Color = new Color(0,0,0)
				canvas.DrawLine( x+width,y,x+width,y+height)
				canvas.DrawLine( x,y+height,x+width,y+height)
				font.Render(canvas,text,x+tx,y+ty)
		Elseif currentColor.R = selectedColor.R And currentColor.G = selectedColor.G And currentColor.B = selectedColor.G
				canvas.Color = new Color(0,0,0)
				canvas.DrawLine( x,y,x+width,y)
				canvas.DrawLine( x,y,x,y+height)
				canvas.Color = new Color(1,1,1)
				canvas.DrawLine( x+width,y,x+width,y+height)
				canvas.DrawLine( x,y+height,x+width,y+height)
				font.Render( canvas,text,x+tx-1,y+ty-1)
		End
		
				
	End Method
	
End Class

Class Enquire

	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
	Field text:String
	Field tx:Int
	Field ty:Int
	Field color:Color
	Field yesBtn:Button
	Field active:Int
	
	Method New(x:Int,y:Int,text:String)
		Self.x = x
		Self.y = y
		Self.width = 300
		Self.height = 120
		Self.tx = 90
		Self.ty = 10
		Self.text = text
		Self.color = New Color(100,200,100)
		self.yesBtn = New Button(x+100,y+30,80,40,"Yes",25,13)
	End method
	
	Method activated:Int()
		Return active
	End Method
	
	Method Update:Void()
		yesBtn.Update()
		active = yesBtn.activated()
	End Method

	Method Render:Void(canvas:Canvas)
		canvas.Alpha = .7
		canvas.Color = color
		canvas.DrawRect(x,y,width,height)
		yesBtn.Render(canvas)
		canvas.Color = new Color(1,1,1)
		canvas.DrawLine(x,y,x+width,y)
		canvas.DrawLine(x,y,x,y+height)
		canvas.Color = New Color(0,0,0)
		canvas.DrawLine(x,y+height,x+width,y+height)
		canvas.DrawLine(x+width,y,x+width,y+height)
		font.Render(canvas,text,x+tx,y+ty)
		canvas.Alpha = 1.0
		canvas.Color = new Color(1,1,1)
	End Method
	
End Class


Class Notify

	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
	Field text:String
	Field tx:Int
	Field ty:Int
	Field color:Color
	Field active:Int
	
	Method New(x:Int,y:Int,text:String,tx:Int,ty:Int,width:Int,height:Int,red:Int,green:Int,blue:int)
		Self.x = x
		Self.y = y
		Self.width = width
		Self.height = height
		Self.tx = tx
		Self.ty = ty
		Self.text = text
		Self.color = New Color(red,green,blue)
	End Method
	
	Method activated:Int()
		Return active
	End Method
	
	Method Update:Void()
		'yesBtn.Update()
		'active = yesBtn.activated()
	End Method

	Method Render:Void(canvas:Canvas)
		canvas.PushMatrix()
		canvas.BlendMode = BlendMode.Alpha
		canvas.Alpha = .8
		canvas.Color = color
		canvas.DrawRect(x,y,width,height)
		canvas.Color = new Color(1,1,1)
		canvas.DrawLine(x,y,x+width,y)
		canvas.DrawLine(x,y,x,y+height)
		canvas.Color = New Color(0,0,0)
		canvas.DrawLine(x,y+height,x+width,y+height)
		canvas.DrawLine(x+width,y,x+width,y+height)
		font.Render(canvas, text,x+tx,y+ty)
		font.Render(canvas, "Dessert Runner",x+170,y+60)
		font.Render(canvas, "Press SPACE To Jump Over Obstacles",x+40,y+210)
		font.Render(canvas, "               Music",x+10,y+235)
		font.Render(canvas, "Movement Proposition - By Kevin MacLeod",x+10,y+260)
		font.Render(canvas, "          incompetech.com",x+10,y+280)
		canvas.Alpha = 1.0
		canvas.PopMatrix()
		canvas.Color = new Color(1,1,1)
	End Method
	
End Class

Class LifeGage
	Field x:Int
	Field y:Int
	Field life:Int
	Field width:Int
	Field height:Int
	Field rate:Int
	
	Method New(x:Int,y:Int,height:Int,life:Int)
		Self.x = x
		Self.y = y
		Self.rate = 20
		Self.height = height
		Self.width = life * self.rate
		Self.life = life
	End Method
	
	Method getLife:Int()
		Return life
	End Method
	Method decrease:Void(n:Int)
		life -= n
		If life < 0 life = 0
	End Method
	
	Method Render:Void(canvas:Canvas)
		canvas.Color = new Color(150,50,0)
		canvas.DrawRect(x,y,life*rate,height)
		canvas.DrawLine( x,y,x+width,y)
		canvas.DrawLine( x+width,y,x+width,y+height)
		canvas.DrawLine( x+width,y+height,x,y+height)
		canvas.DrawLine( x,y+height,x,y)
	End Method
	
End Class
    
Class Bomb
	Field x:Float
	Field y:Float
	Field speedy:Float
	Field image:Image
	
	Field HitBox:HitBox
	
	Method New(image:Image,x:Float,y:Float,speed:Float)
		Self.x = x
		Self.y = y
		Self.HitBox = New HitBox
		Self.HitBox.offx = 3
		Self.HitBox.offy = 3
		Self.HitBox.width = 14
		Self.HitBox.height = 14
		Self.speedy = speed
		self.image = image
	End Method
	
	Method init:Void(x:Float,y:Float,speed:Float)
		Self.x = x
		Self.y = y			
		Self.speedy = speed
	End Method
	
	Method Update:Int(dx:Float)
		x -= dx*3
		y += speedy
		If y > 420
			Return False
		Endif
		Return True
	End Method
	
	Method Render:Void(canvas:Canvas)
		If x > -30 And x < 640
			canvas.DrawImage(image,x,y)
			If showBox
				HitBox.Render(canvas,x,y)
			Endif
		Endif
	End Method
End Class

Class BombStore
	Field list:List<Bomb>
	Field image:Image
	Field x:Float
	Field y:Float
	Field speed:Float
	
	Function create:BombStore(image:Image)
		Local b:BombStore = New BombStore
		b.list = New List<Bomb>
		b.image = image
		b.x = 0
		b.y = 0
		b.speed = 0
		b.fill(10)
		Return b
	End Function
	
	Method fill:Void(total:Int)
		For Local i:Int = 0 Until total
			list.AddLast(New Bomb(image,x,y,speed))
		Next
	End Method
	
	Method get:Bomb()
		If Not list.Empty
			Return list.RemoveLast()
		Endif
		Return New Bomb(image,x,y,speed)
		
	End Method
	
	Method replace:Void(bomb:Bomb)
		list.AddLast(bomb)
	End Method
End Class

Class Impact
	Field x:Float
	Field y:Float
	Field animation:Sprite
	
	Method New(x:Float,y:Float,image:Image[],spr:Int[],wait:Float,count:Float,frame:Float)
		Self.x = x
		Self.y = y
		Self.animation = New Sprite(image,spr,wait,count,frame)
	End method

	Method init:Void(x:Float,y:Float)
		Self.x = x
		Self.y = y
		Self.animation.Reset()
	End Method

	Method Update:Int(dx:Float)
		x -= dx*3.0
		Local i:Int = animation.Update()
		Return i
	End Method
	
	Method Render:Void(canvas:Canvas)
		animation.Render(canvas,x,y)
	End Method
		
End Class

Class ImpactStore
    Field list:List <Impact>
	Field image:Image[]
	Field spr:Int[]
	Field frame:Int
	Field rate:Int
	Field wait:Int
	Field count:Int
	Field x:Float
	Field y:Float
	
	Method New(image:Image[],spr:Int[],wait:Float,count:Float,frame:Float)
		Self.list = New List <Impact>
		Self.image = image
		Self.spr = spr
		Self.wait = wait
		Self.count = count
		Self.frame = frame
		Self.x = 0
		Self.y = 0
	End method
	
	Method fill:Void(total:Int)
		For Local i:Int = 0 Until total
			list.AddLast(New Impact(x,y,image,spr,wait,count,frame))
		Next
	End Method
	
	Method get:Impact()
		If Not list.Empty
			Return list.RemoveLast()
		Endif
		Return New Impact(x,y,image,spr,wait,count,frame)
	End Method
	
	Method replace:Void(impact:Impact)
		list.AddLast(impact)
	End Method
End Class

Class Sprite
	Field name:string
	Field spr:Int[]
	Field wait:Int
	Field frame:Int
	Field count:Int
	Field rate:Int
	Field image:Image[]
	
    Method New(image:Image[],spr:Int[],wait:Float,count:Float,frame:Float)
		Self.spr = spr
		Self.wait = wait
		Self.frame = frame
		Self.count = count
		Self.rate = Millisecs()+wait
		Self.image = image
	End Method
	
	Method Reset:Void()
		If count > 1
			frame = 0
			rate = Millisecs() + wait
		Endif
	End Method
            
	Method Update:Int()
		If (count > 1)
			If (Millisecs() > rate)
				frame = (frame + 1) Mod count
				rate = Millisecs() + wait
				If (frame=0)
					Return True
				Endif
			Endif
		Endif
		Return False
	End Method
        
	Method Render:Void(canvas:Canvas,x:Float,y:Float,scale:Float=1.5)
		canvas.PushMatrix()
		canvas.Scale(scale, scale)
		canvas.DrawImage(image[spr[0]+frame],x/scale,y/scale)
		canvas.PopMatrix()
	End Method

End Class
    
Class Entity
	Field x:Float
	Field y:Float
	Field speedx:Float
	Field seq:Int[]
	
	Field HitBox:HitBox
	
	Method New()
		HitBox = New HitBox
	End Method
	
	Method Update(dx:Float) Abstract
	Method Render(canvas:Canvas,scale:Float = 1.0) Abstract
	Method Reset() Abstract
	
End Class

Class Tleft Extends Entity
	
	Field moveL:Sprite
	
	Method New()
	
	End Method
	
	Function create:Tleft(image:Image[],move:Int[],x:Float,y:Float,speed:Float,delay:Int,hitOx:Float,hitOy:Float,hitWidth:Float,hitHeight:Float)
		Local d:Tleft = New Tleft
		d.x = x
		d.y = y
		d.HitBox.offx = hitOx
		d.HitBox.offy = hitOy
		d.HitBox.width = hitOx+hitWidth
		d.HitBox.height = hitOy+hitHeight
		d.speedx = speed
		d.moveL = New Sprite(image,move,delay,6,0)
		Return d
	End Function
	
	Method Update(dx:Float) Override
		x = x - (speedx + dx*3.0)
		If x < -40
			Reset()
		Endif
		moveL.Update()			
	End Method
	
	Method Reset() Override
		x = 800
		speedx = 1+Rnd(1,5) 
	End Method
	
	Method Render(canvas:Canvas,scale:Float=1.0) Override
		moveL.Render(canvas,x,y,scale)
		canvas.Color = New Color(1,1,1)
		If showBox
			HitBox.Render(canvas,x,y)
		Endif
	End Method
		
End Class 

Class Tright Extends Entity
	
	Field moveR:Sprite
	
	Method New()
	
	End Method
	
	Function create:Tright(image:Image[],move:Int[],x:Float,y:Float,speed:Float,delay:Int,hitOx:Float,hitOy:Float,hitWidth:Float,hitHeight:Float)
		Local d:Tright = New Tright()
		d.x = x
		d.y = y
		d.HitBox.offx = hitOx
		d.HitBox.offy = hitOy
		d.HitBox.width = hitOx+hitWidth
		d.HitBox.height = hitOy+hitHeight
		d.speedx = speed
		d.moveR = New Sprite(image,move,delay,6,0)
		Return d
	End Function
	
	Method Update:Void(dx:Float) Override
		x += speedx - dx*3.0
		If x > 640
			Reset()
		Endif
		moveR.Update()			
	End Method
	
	Method Reset() Override
		x = -300
		speedx = 2.0+Rnd(1.0,4.0)
	End Method
	
	Method Render(canvas:Canvas,scale:Float=1.0) Override
		moveR.Render(canvas,x,y,scale)
		canvas.Color = New Color(1,1,1)
		If showBox
			HitBox.Render(canvas,x,y)
		Endif
	End Method
	
End Class 

Class HitBox
	Field offx:Float
	Field offy:Float
	Field width:Float
	Field height:Float
	
	Method New()
	
	End method
	
	Method New(offx:Float,offy:Float,width:Float,height:Float)
		Self.offx = offx
		Self.offy = offy
		Self.width = width
		Self.height = height
	End Method
	
	Method Render:Void(canvas:Canvas,x:Float,y:Float)
		canvas.DrawLine(x+offx,y+offy,x+width,y+offy)
		canvas.DrawLine(x+width,y+offy,x+width,y+height)
		canvas.DrawLine(x+width,y+height,x+offx,y+height)
		canvas.DrawLine(x+offx,y+height,x+offx,y+offy)
	End Method

End Class

Class Tplayer

	Field x:Float
	Field y:Float
	Field fixedx:Float
	Field fixedy:Float
	Field posy:Float
	Field speedy:Float
	Field jump:Int
	Field punch:Int
	
	Field HitBox:HitBox
	
	Field boxWalking:HitBox
	Field boxDucking:HitBox
	Field boxJumping:HitBox
	
	Field walkR:Sprite
	Field standR:Sprite
	Field crouchDR:Sprite
	Field crouchUR:Sprite
	Field knealedR:Sprite
	Field jumpR:Sprite
	Field animation:Sprite

	Const MOVEL:Int = -1
	Const MOVER:Int =  1
	Const MOVED:Int =  1
	Const MOVEJ:Int = -1
	
	Method New()
		boxWalking = New HitBox()
		boxDucking = New HitBox()
		boxJumping = New HitBox()
	End Method
        
	Function create:Tplayer(x:Float,y:Float)
		Local p:Tplayer = New Tplayer
		p.x = x
		p.y = y
		p.fixedx = x
		p.fixedy = y
		p.posy = y
		p.speedy = 0
		p.jump = 0
		
		p.boxWalking.offx = 33
		p.boxWalking.offy = 16
		p.boxWalking.width = 20+33
		p.boxWalking.height = 54+16
		
		p.boxDucking.offx = 33
		p.boxDucking.offy = 30
		p.boxDucking.width = 20+33
		p.boxDucking.height = 40+30
		
		p.boxJumping.offx = 35
		p.boxJumping.offy = 22
		p.boxJumping.width = 20+35
		p.boxJumping.height = 48+22
		
		p.HitBox = p.boxWalking
		
		p.walkR = New Sprite(beastImg,walkRight,75,6,0)
		p.walkR.name = "walkR"
		p.standR = New Sprite(beastImg,framed,75,1,0)
		p.standR.name = "StandR"
		p.crouchDR = New Sprite(beastImg,crouchRightDown,50,2,0)
		p.crouchDR.name = "crouchDR"
		p.crouchUR = New Sprite(beastImg,crouchRightUp,50,2,0)
		p.crouchUR.name = "crouchUR"
		p.knealedR = New Sprite(beastImg,framed,50,1,1)
		p.knealedR.name = "knealedR"
		p.jumpR = New Sprite(beastImg,framed,50,1,2)
		p.jumpR.name = "jumpR"
		p.animation = p.standR
		Return p
	End Function
	
	Method Reset:Void()
		animation = standR
		x = fixedx
		y = fixedy
		speedy = 0
	End Method
			
	Method Update:Float(dirx:Float,diry:Float,action:Float)
	    Select animation
			Case standR
				if (diry = MOVED)
					animation = crouchDR
					animation.Reset()
					dirx = 0
				Elseif (diry = MOVEJ)
					animation = jumpR
					HitBox = boxJumping
					animation.Reset()
					jump = True
					speedy = 1.0
				Elseif (dirx = MOVER)
					animation = walkR
					animation.Reset()
				Endif
			Case walkR
				if diry = MOVED
					animation = crouchDR
					animation.Reset()
					dirx = 0
				Else If (diry = MOVEJ)
					animation = jumpR
					HitBox = boxJumping
					animation.Reset()
					jump = True
					speedy = 1.0
				ElseIf (dirx = MOVER)
					animation.Update()
				Else
					animation = standR
				Endif
			Case crouchDR
				If animation.Update()
					animation = knealedR
					HitBox = boxDucking
					animation.Reset()
				Endif
				dirx = 0
			Case knealedR
				If (diry <> MOVED)
					animation = crouchUR
					animation.Reset()
				Endif
				dirx = 0
			Case crouchUR
				If animation.Update()
					animation = standR
					HitBox = boxWalking
					animation.Reset()
				Endif
				dirx = 0
				
			Case jumpR
				If (jump)
					If (diry = MOVEJ)
						speedy += 1.5
						If (speedy>9) 
							speedy = 9
							jump = False
						Endif
					Else
						jump = False
					Endif
				Else
					speedy -= 0.6
				Endif
				y -= speedy
				If (y >= posy)
					If (dirx = MOVER)
						animation = walkR
						HitBox = boxWalking
						animation.Reset()
					Else
						animation = standR
						HitBox = boxWalking
						animation.Reset()
					Endif
					speedy = 0
					y = posy
				Endif
				
		End Select
		Return dirx
	End Method
	
	Method Render:Void(canvas:Canvas)
		animation.Render(canvas,x,y)
		canvas.Color = New Color(1,1,1)
		If showBox
			HitBox.Render(canvas,x,y)
		Endif
	End Method
End Class

Class TileRow
	Field x:Float
	Field y:Float
	Field vw:Float
	Field vh:Float
	Field width:Float
	Field speed:Float
	Field image:Image
	
	Method New(x:Float,y:Float,speed:Float,image:Image)
		Self.x = x
		Self.y = y
		Self.vw = 640
		Self.vh = 480
		Self.width = image.Width
		Self.speed = speed
		Self.image = image
	End method
		
	Method Update:Void(dirx:Float)
		x = (x+speed*dirx) Mod width
	End Method

	Method Render:Void(canvas:Canvas)
		TileImageAcross(canvas,image,x,y,width)
	End Method
End Class

Class BackGround 
	Method New()
		list.AddLast(New TileRow(0,0,0.0,background1))
		list.AddLast(New TileRow(0,200,-2.0,background7))
		list.AddLast(New TileRow(0,200,-3.0,background2))
		list.AddLast(New TileRow(0,420,-4.0,background3))
		list.AddLast(New TileRow(0,430,-6.0,background4))
		list.AddLast(New TileRow(0,450,-10.0,background5))
		list.AddLast(New TileRow(0,140,-2.0,cloud4))
		list.AddLast(New TileRow(0,100,-4.0,cloud3))
		list.AddLast(New TileRow(0, 60,-6.0,cloud2))
		list.AddLast(New TileRow(0,  0,-8.0,clouds1))
	End Method
	
	Method Update:Void(dirx:Float)
		For Local row:TileRow = Eachin list
			row.Update(dirx)
		Next
	End Method
End Class

Function LoadFrames:Image[](url:String,count:Int)
	Local image := New Image[count]
	Local atlas:Image = Image.Load(url)
	Local height:Int = atlas.Height
	For Local i:Int = 0 Until count
		image[i] = New Image(atlas,i*height,0,height,height)
	Next
	Return image
End Function

Function LoadFrames:Image[](url:String,width:Int,height:Int,count:Int)
	Local image:= New Image[count]
	Local atlas:= Image.Load(url)
	Local x:Int = 0,y:Int = 0
	For Local i:Int = 0 Until count
		If x >= atlas.Width
			x = 0
			y += height
		Endif
		image[i] = New Image(atlas,x,y,width,height)
		x+= width
	Next
	Return image
End Function

Class Font
	Field image:Image[]
	
	Method New(image:Image[])
		Self.image = image
	End Method
	
	Method Render(canvas:Canvas,text:String,x:Float,y:Float)
		For Local i:Int = 0 Until text.Length
			canvas.DrawImage(image[text[i]-32],x+i*image[text[i]-32].Width,y)
		Next
	End Method
End Class

Class Game Extends Window

	Field background:BackGround
	Field lastItem:TileRow
    Field player:Tplayer
	Field dog:Tleft
	Field fly:Tleft
	Field bee:Tleft
	Field cat:Tright
	Field tera:Tleft
	Field snake:Tleft
	
	Field bombList:List <Bomb>
	Field enemyList:List <Entity>
	Field impactList:List <Impact>
	
	Field impactStore:ImpactStore
	Field bombStore:BombStore
	
	Field hitCount:Int
	Field lifeGage:LifeGage
	Field enquire:Enquire
	Field firstGame:Int
	Field playing:Int
	Field counter:Int
	Field secs:float
	Field impactImg:Image[]
	Field mTime:Int
	Field delay:Int
	Field notify:Notify

	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )

		list = New List <TileRow>
		bombList = New List <Bomb>
		enemyList = New List <Entity>
		impactList = New List <Impact>
		hitCount = 0
		
		beastImg = LoadFrames("asset::runner.png",12)
		background1 = Image.Load("asset::sky.png")
		background2 = Image.Load("asset::mountains.png")
		background3 = Image.Load("asset::soil1.png")
		background4 = Image.Load("asset::soil2.png")
		background5 = Image.Load("asset::soil3.png")
		background7 = Image.Load("asset::mountains2.png")
		clouds1 = Image.Load("asset::cloud1.png")
		cloud2 = Image.Load("asset::cloud2.png")
		cloud3 = Image.Load("asset::cloud3.png")
		cloud4 = Image.Load("asset::cloud4.png")
		dogImg = LoadFrames("asset::runingdog.png",6)
		catImg = LoadFrames("asset::cat.png",55,32,6)
		teraImg = LoadFrames("asset::tera.png",54,32,6)
		beeImg = LoadFrames("asset::bee.png",6)
		bombImg = Image.Load("asset::bomb.png")
		impactImg = LoadFrames("asset::impact.png",41,32,6)
		font = New Font(LoadFrames("asset::burnt.png",12,16,96))
		
		bopSound = Sound.Load("asset::explode.ogg")
		expSound = Sound.Load("asset::don.ogg")
		ouchSound = Sound.Load("asset::ouch.ogg")
		
		music = Sound.Load("asset::proposition.ogg")
		
		
		background = New BackGround()
		
		For Local thisItem:TileRow = Eachin list
			lastItem= thisItem
		Next
		channel = New Channel[15]
		For channelIndex = 0 Until 15
			channel[channelIndex] = New Channel
		Next
		channelIndex = 0
		player = Tplayer.create(300,360)
		musicChannel = New Channel
		
		dog = Tleft.create(dogImg,itMoving,640,413,3,100,6,10,15,12)
		cat = Tright.create(catImg,itMoving,640,412,8,100,10,5,30,16)
		tera = Tleft.create(teraImg,itMoving,640,150,2,100,10,15,40,15)
		bee = Tleft.create(beeImg,itMoving,740,380,3.5,25,8,17,23,11)
		enemyList.AddLast(dog)
		enemyList.AddLast(cat)
		enemyList.AddLast(tera)
		enemyList.AddLast(bee)
		
		impactStore = New ImpactStore(impactImg,itMoving,50,6,0)
		impactStore.fill(10)
		
		bombStore = BombStore.create(bombImg)
		bombStore.fill(10)
		
		lifeGage = new LifeGage(530,5,16,5)
		
		enquire = New Enquire(180,130,"Play Game?")
		notify = New Notify(90,50," Welcome To The Summer Games",50,20,500,300,80,200,180)
		firstGame = True
		playing = False
		mTime = Millisecs()
		delay = 200
		SwapInterval = .5
	End

	Method Reset:Void()
		For Local e:Entity = Eachin enemyList
			e.Reset()
		Next
		For Local b:Bomb = Eachin bombList
			bombList.Remove(b)
			bombStore.replace(b)
		Next
		For Local i:Impact = Eachin impactList
			impactList.Remove(i)
			impactStore.replace(i)
		Next
		counter = Millisecs()
	End Method

	Method OnRender( canvas:Canvas ) Override
		canvas.BlendMode = BlendMode.Alpha
		Local dirx:Float
		Local diry:Float
		Local action:Float
		If playing = False
			enquire.Update()
			If enquire.activated() = True
				If firstGame = True
					firstGame = False
					enquire.text = "Game Over, Play again?"
					enquire.tx = 30
					counter = Millisecs()
				Else
					enquire.Update()
					lifeGage.life = 5
					Reset()
					player.Reset()
				Endif
				musicChannel.Play(music,True)
				playing = True
			Endif
		Else
			dirx = 1
			diry = -Int(Touch.FingerDown(0))
			If diry dirx = 0
			dirx = player.Update(dirx,diry,action)
		    
			For Local e:Entity = Eachin enemyList
				e.Update(dirx)
				If collided(player.x,player.y,player.HitBox,e.x,e.y,e.HitBox)
					e.x = 800
					hitCount += 1
					channel[channelIndex].Play(ouchSound)
					channelIndex = (channelIndex+1) Mod 15
					lifeGage.decrease(1)
				Endif
			Next
			
			For Local i:Impact = Eachin impactList
				If i.Update(dirx) = True
					impactList.Remove(i)
				Endif
			Next
			
			For Local b:Bomb = Eachin bombList
				If collided(player.x,player.y,player.HitBox,b.x,b.y,b.HitBox)
					hitCount += 1
					lifeGage.decrease(1)
					bombList.Remove(b)
					bombStore.replace(b)
					Local i:Impact = impactStore.get()
					i.init(b.x-20,b.y-20)
					impactList.AddLast(i)
					channel[channelIndex].Play(expSound)
					channelIndex = (channelIndex+1) Mod 15
					channel[channelIndex].Play(ouchSound)
					channelIndex = (channelIndex+1) Mod 15
				Elseif b.Update(dirx) = False
					bombList.Remove(b)
					bombStore.replace(b)
					Local i:Impact = impactStore.get()
					i.init(b.x-20,b.y-20)
					impactList.AddLast(i)
					channel[channelIndex].Play(expSound)
					channelIndex = (channelIndex+1) Mod 15
				Endif
			Next
			If (mTime+delay)< Millisecs()
				Local n:Int = Int(Rnd(0,30))
				If n = 15
					Local b:Bomb = bombStore.get()
					b.init(tera.x+16,tera.y+16,8.0)
					bombList.AddLast(b)
					channel[channelIndex].Play(bopSound)
					channelIndex = (channelIndex+1) Mod 15
					mTime = Millisecs()
				Endif
			Endif
		Endif
	    background.Update(dirx)
		If lifeGage.life = 0
			musicChannel.Stop()
			playing = False
		Endif
	
		App.RequestRender()
	
		For Local item:TileRow = Eachin list
			item.Render(canvas)
			If(item = lastItem)
			
				If playing = False
					notify.Render(canvas)
					enquire.Render(canvas)
					If secs > 0
						font.Render(canvas,"score "+Int(secs),240,215)
					Endif
				Else
					player.Render(canvas)
					For Local e:Entity = Eachin enemyList
						e.Render(canvas)
					Next
					For Local b:Bomb = Eachin bombList
						b.Render(canvas)
					Next
					For Local i:Impact = Eachin impactList
						i.Render(canvas)
					Next
					secs = (Millisecs() - counter)
				Endif
			
			Endif
		Next
		canvas.Color = new Color(0,1,0)
		font.Render(canvas,"seconds: "+Int(secs/1000),30,5)
		font.Render(canvas,"Life",480,5)
		canvas.Color = new Color(1,1,1)
		lifeGage.Render(canvas)
		time = Millisecs()
		fpsTemp += 1
		If(time > lastTime + 1000)
			fps			= fpsTemp
			fpsTemp		= 0
			lastTime	= time
		Endif
	End
	
End

Function Main()

	New AppInstance
	
	New Game
	
	App.Run()
End
