size = 100
zMax = 5
speed = 0.2
aster_speed = 0.1

width = 399
height = 239

xPos = -20
yPos = 250
zPos = 5

blocked = false
lose = false
autofire = false
level = 0

if string.len(System.currentDirectory()) == 1 then
	System.currentDirectory("")
end

starfield = {}
asteroids = {}
shoots = {}
player = {}
h,m,s = System.getTime()
seed = s + m * 60 + h * 3600
math.randomseed(seed)
destroys = 0

function GarbageCollection()
	Timer.destroy(counter)
	Timer.destroy(aster_time)
	Timer.destroy(speed_time)
end

function Xor(op1,op2)
	return not((op1 and (not op2)) or ((not op1) and op2))
end

function createStar(i)
	starfield[i] = {}
	starfield[i].x = math.random(2*width) - width
	starfield[i].y = math.random(2*height) - height
	starfield[i].z = zMax
end

function createAsteroid(i,colour)
	asteroids[i] = {}
	asteroids[i].x = math.random(-250,250)
	asteroids[i].y = math.random(-250,250)
	asteroids[i].z = 10
	asteroids[i].color = colour
end

function createShoot(i)
	shoots[i] = {}
	shoots[i].x = xPos + 25
	shoots[i].y = yPos
	shoots[i].z = zPos
end
for i = 1, size do
	createStar(i)
	starfield[i].z = math.random(zMax)
end

white = Color.new(255, 255, 255)
red = Color.new(255, 0, 0)
cyan = Color.new(0, 255, 255)
green = Color.new(0, 255, 0)
yellow = Color.new(255,255,0)
oldpad = KEY_A
colors = {green,cyan,red,white,yellow}

if restart == nil then
	gpu = false
	rtype = "CPU"
	menu = {"Start game","Render: "..rtype,"Exit game"}
	menu_x = {150,145,157}
	menu_index = 1
	if init == nil then
		logo = Screen.loadImage(System.currentDirectory().."/AsteroidsFiles/logo.png")
		Screen.refresh()
		Screen.drawImage(100,10,logo,TOP_SCREEN)
		Screen.debugPrint(157,115,"Loading...",white,TOP_SCREEN)
		Screen.flip()
		Screen.waitVblankStart()
		Sound.init()
		snd = Sound.openOgg(System.currentDirectory().."/AsteroidsFiles/theme.ogg")
		Sound.play(snd,LOOP,0x08,0x09)
		init = true
	end
end

while (restart == nil) do

	-- Native 3D support
	if Screen.get3DLevel() == 0 then
		Screen.disable3D()
		three = nil
	else
		if three == nil then
			Screen.enable3D()
			three = true
		end
		level = Screen.get3DLevel()
	end
	
	pad = Controls.read()
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
	if gpu then
		Graphics.initBlend(TOP_SCREEN)
		Graphics.drawImage(100,10,logo_gpu)
		Graphics.termBlend()
		if Screen.get3DLevel() > 0 then
			Graphics.initBlend(TOP_SCREEN,RIGHT_EYE)
			Graphics.drawImage(100,10,logo_gpu)
			Graphics.termBlend()
		end
	else
		Screen.drawImage(100,10,logo,TOP_SCREEN)
		if Screen.get3DLevel() > 0 then
			Screen.drawImage(100,10,logo,TOP_SCREEN,RIGHT_EYE)
		end
	end
	
	-- Generate background effect
	for i = 1, size do
		starfield[i].z = starfield[i].z - speed
		if starfield[i].z < speed then createStar(i) end
		x = width / 2 + starfield[i].x / starfield[i].z
		y = height / 2 + starfield[i].y / starfield[i].z
		if x < 5 or y < 0 or x >= width-5 or y >= height then
			createStar(i)
		else
			if Screen.get3DLevel() > 0 then
				Screen.drawPixel(math.floor(x-(starfield[i].z*level)/2), math.floor(y), white, TOP_SCREEN,LEFT_EYE)
				Screen.drawPixel(math.floor(x+(starfield[i].z*level)/2), math.floor(y), white, TOP_SCREEN,RIGHT_EYE)
			else
				Screen.drawPixel(math.floor(x), math.floor(y), white, TOP_SCREEN)
			end
		end
	end
	
	-- Blit menu
	y = 100
	for i,voice in pairs(menu) do
		if i == menu_index then
			color = yellow
		else
			color = white
		end
		Screen.debugPrint(menu_x[i],y,voice,color,TOP_SCREEN)
		if Screen.get3DLevel() > 0 then
			Screen.debugPrint(menu_x[i],y,voice,color,TOP_SCREEN,RIGHT_EYE)
		end
		y = y+15
	end
	
	if Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A) then
		if menu_index == 1 then
			break
		elseif menu_index == 2 then
			gpu = not gpu
			if gpu then
				Graphics.init()
				logo_gpu = Graphics.loadImage(System.currentDirectory().."/AsteroidsFiles/logo.png")
				rtype = "GPU"
			else
				if logo_gpu ~= nil then
				end
				Graphics.term()
				rtype = "CPU"
			end
			menu[2] = "Render: " .. rtype
		else
			Screen.freeImage(logo)
			Sound.pause(snd)
			Sound.close(snd)
			Sound.term()
			System.exit()
		end
	end
	if Controls.check(pad,KEY_DUP) and not Controls.check(oldpad,KEY_DUP) then
		menu_index = menu_index - 1
		if menu_index < 0 then
			menu_index = #menu
		end
	elseif Controls.check(pad,KEY_DDOWN) and not Controls.check(oldpad,KEY_DDOWN) then
		menu_index = menu_index + 1
		if menu_index > #menu then
			menu_index = 1
		end
	end
	oldpad = pad
	Screen.debugPrint(0,225,"v.0.5 ALPHA",white,TOP_SCREEN)
	if Screen.get3DLevel() > 0 then
		Screen.debugPrint(0,225,"v.0.5 ALPHA",white,TOP_SCREEN,RIGHT_EYE)
	end
	Screen.waitVblankStart()
	Screen.flip()
end

counter = Timer.new()
aster_time = Timer.new()
speed_time = Timer.new()
malus_time = Timer.new()
bonus_time = Timer.new()

while true do

	-- Native 3D support
	if Screen.get3DLevel() == 0 then
		Screen.disable3D()
		three = nil
	else
		if three == nil then
			Screen.enable3D()
			three = true
		end
		level = Screen.get3DLevel()
	end
	
	
	survival_time = math.floor(Timer.getTime(counter) / 1000)
	speed_survival = survival_time / 50
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
	
	-- Auto-increasing difficulty
	if (Timer.getTime(speed_time) / 1000) > 25 then
		aster_speed = aster_speed + 0.1
		speed = speed + 0.1
		if speed > 1.2 then
			speed = 1.2
		end
		Timer.reset(speed_time)
	end
	
	-- Generate asteroids
	if Timer.getTime(aster_time) > (400 / speed_survival) then
		createAsteroid(#asteroids + 1,yellow)
		Timer.reset(aster_time)
	end

	-- Generate pickups
	if Timer.getTime(bonus_time) > 25000 then
		createAsteroid(#asteroids + 1,cyan)
		Timer.reset(bonus_time)
	end	
	if Timer.getTime(malus_time) > 10000 then
		createAsteroid(#asteroids + 1,red)
		Timer.reset(malus_time)
	end	
	
	-- Generate ship coords
	x_ship = math.floor(width / 2 + xPos / (zPos - 2))
	x2_ship = math.floor(width / 2 + (xPos + 50) / (zPos-2))
	y_ship = math.floor(height / 2 + yPos / zPos)
	xF_ship = math.floor(width / 2 + (xPos + 25) / zPos)
	yF_ship = math.floor(height / 2 + (yPos) / (zPos-2))
	yF2_ship = math.floor(height / 2 + (yPos + 25) / (zPos-2))
	
	if gpu then
		Graphics.initBlend(TOP_SCREEN)
	end
	
	-- Blit asteroids
	i = 1
	while i <= #asteroids do
		asteroids[i].z = asteroids[i].z - aster_speed
		x = math.floor(width / 2 + asteroids[i].x / asteroids[i].z)
		y = math.floor(height / 2 + asteroids[i].y / asteroids[i].z)
		x2 = math.floor(width / 2 + (asteroids[i].x + 50) / asteroids[i].z)
		y2 = math.floor(height / 2 + (asteroids[i].y + 50) / asteroids[i].z)
		if not (x < 0 or y < 0 or x >= width - 50 or y >= height - 50) then
			-- Collision triggering
				if asteroids[i].z <= zPos then
					if asteroids[i].z > zPos - 0.5 and asteroids[i].z < zPos + 0.5 and ((x >= xF_ship and x2 <= xF_ship) or (x <= xF_ship and x2 >= xF_ship)) and ((y >= y_ship and y2 <= y_ship) or (y <= y_ship and y2 >= y_ship)) then
						if asteroids[i].color == yellow then
							lose = true
							Timer.pause(aster_time)
							Timer.pause(counter)
							Timer.pause(bonus_time)
							Timer.pause(malus_time)
						elseif asteroids[i].color == red then
							blocked = true
							block_time = Timer.new()
						else
							autofire = true
							autofire_time = Timer.new()
						end
					elseif asteroids[i].z < zPos - 0.5 and asteroids[i].z >= zPos - 2 and (Xor((asteroids[i].x + 50) >= xPos,asteroids[i].x <= (xPos + 50))) and (Xor((asteroids[i].y + 50) >= yPos,asteroids[i].y <= (yPos + 25))) then
						if asteroids[i].color == yellow then
							lose = true
							Timer.pause(aster_time)
							Timer.pause(counter)
							Timer.pause(bonus_time)
							Timer.pause(malus_time)
						elseif asteroids[i].color == red then
							blocked = true
							block_time = Timer.new()
						else
							autofire = true
							autofire_time = Timer.new()
						end
					end
				end
			if Screen.get3DLevel() > 0 then	
				if gpu then
					Graphics.fillRect(math.floor(x-(asteroids[i].z*level)/2),math.floor(x2-(asteroids[i].z*level)/2),y,y2,asteroids[i].color)
					Graphics.termBlend()
					Graphics.initBlend(TOP_SCREEN,RIGHT_EYE)
					Graphics.fillRect(math.floor(x+(asteroids[i].z*level)/2),math.floor(x2+(asteroids[i].z*level)/2),y,y2,asteroids[i].color)
					Graphics.termBlend()
					Screen.waitVblankStart()
					Graphics.initBlend(TOP_SCREEN)
				else				
					Screen.fillRect(math.floor(x-(asteroids[i].z*level)/2),math.floor(x2-(asteroids[i].z*level)/2),y,y2,asteroids[i].color,TOP_SCREEN,LEFT_EYE)
					Screen.fillRect(math.floor(x+(asteroids[i].z*level)/2),math.floor(x2+(asteroids[i].z*level)/2),y,y2,asteroids[i].color,TOP_SCREEN,RIGHT_EYE)
				end
			else
				if gpu then
					Graphics.fillRect(x,x2,y,y2,asteroids[i].color)
				else
					Screen.fillRect(x,x2,y,y2,asteroids[i].color,TOP_SCREEN)
				end
			end
		end
		if asteroids[i].z < 2.5 then
			table.remove(asteroids,i)
		else
			i = i + 1
		end
	end
	
	-- Draw ship
	left_hide = false
	right_hide = false
	top_hide = false
	bottom_hide = false
	if xF_ship >= x_ship then
		left_hide = true
	end
	if x2_ship >= xF_ship then
		right_hide = true
	end
	if yF2_ship >= y_ship  then
		bottom_hide = true
	end
	if y_ship >= yF_ship  then
		top_hide = true
	end
		if Screen.get3DLevel() > 0 then
			if gpu then
				if ((not top_hide) or (not left_hide)) then Graphics.drawLine(math.floor(x_ship-(zPos*level)/2),math.floor(xF_ship-(zPos*level)/2),yF_ship,y_ship,green) end
				if ((not top_hide) or (not right_hide)) then Graphics.drawLine(math.floor(x2_ship-(zPos*level)/2),math.floor(xF_ship-(zPos*level)/2),yF_ship,y_ship,green) end
				if ((not bottom_hide) or (not left_hide)) then Graphics.drawLine(math.floor(x_ship-(zPos*level)/2),math.floor(xF_ship-(zPos*level)/2),yF2_ship,y_ship,green) end
				if ((not bottom_hide) or (not right_hide)) then Graphics.drawLine(math.floor(x2_ship-(zPos*level)/2),math.floor(xF_ship-(zPos*level)/2),yF2_ship,y_ship,green) end
				Graphics.drawLine(math.floor(x_ship-(zPos*level)/2),math.floor(x_ship-(zPos*level)/2),yF_ship,yF2_ship,green)
				Graphics.drawLine(math.floor(x_ship-(zPos*level)/2),math.floor(x2_ship-(zPos*level)/2),yF_ship,yF_ship,green)
				Graphics.drawLine(math.floor(x_ship-(zPos*level)/2),math.floor(x2_ship-(zPos*level)/2),yF2_ship,yF2_ship,green)
				Graphics.drawLine(math.floor(x2_ship-(zPos*level)/2),math.floor(x2_ship-(zPos*level)/2),yF_ship,yF2_ship,green)
				Graphics.termBlend()
				Graphics.initBlend(TOP_SCREEN,RIGHT_EYE)
				if ((not top_hide) or (not left_hide)) then Graphics.drawLine(math.floor(x_ship+(zPos*level)/2),math.floor(xF_ship+(zPos*level)/2),yF_ship,y_ship,green) end
				if ((not top_hide) or (not right_hide)) then Graphics.drawLine(math.floor(x2_ship+(zPos*level)/2),math.floor(xF_ship+(zPos*level)/2),yF_ship,y_ship,green) end
				if ((not bottom_hide) or (not left_hide)) then Graphics.drawLine(math.floor(x_ship+(zPos*level)/2),math.floor(xF_ship+(zPos*level)/2),yF2_ship,y_ship,green) end
				if ((not bottom_hide) or (not right_hide)) then Graphics.drawLine(math.floor(x2_ship+(zPos*level)/2),math.floor(xF_ship+(zPos*level)/2),yF2_ship,y_ship,green) end
				Graphics.drawLine(math.floor(x_ship+(zPos*level)/2),math.floor(x_ship+(zPos*level)/2),yF_ship,yF2_ship,green)
				Graphics.drawLine(math.floor(x_ship+(zPos*level)/2),math.floor(x2_ship+(zPos*level)/2),yF_ship,yF_ship,green)
				Graphics.drawLine(math.floor(x_ship+(zPos*level)/2),math.floor(x2_ship+(zPos*level)/2),yF2_ship,yF2_ship,green)
				Graphics.drawLine(math.floor(x2_ship+(zPos*level)/2),math.floor(x2_ship+(zPos*level)/2),yF_ship,yF2_ship,green)
				Graphics.termBlend()
			else
				if ((not top_hide) or (not left_hide)) then Screen.drawLine(math.floor(x_ship-(zPos*level)/2),math.floor(xF_ship-(zPos*level)/2),yF_ship,y_ship,green,TOP_SCREEN) end
				if ((not top_hide) or (not right_hide)) then Screen.drawLine(math.floor(x2_ship-(zPos*level)/2),math.floor(xF_ship-(zPos*level)/2),yF_ship,y_ship,green,TOP_SCREEN) end
				if ((not bottom_hide) or (not left_hide)) then Screen.drawLine(math.floor(x_ship-(zPos*level)/2),math.floor(xF_ship-(zPos*level)/2),yF2_ship,y_ship,green,TOP_SCREEN) end
				if ((not bottom_hide) or (not right_hide)) then Screen.drawLine(math.floor(x2_ship-(zPos*level)/2),math.floor(xF_ship-(zPos*level)/2),yF2_ship,y_ship,green,TOP_SCREEN) end
				Screen.drawLine(math.floor(x_ship-(zPos*level)/2),math.floor(x_ship-(zPos*level)/2),yF_ship,yF2_ship,green,TOP_SCREEN)
				Screen.drawLine(math.floor(x_ship-(zPos*level)/2),math.floor(x2_ship-(zPos*level)/2),yF_ship,yF_ship,green,TOP_SCREEN)
				Screen.drawLine(math.floor(x_ship-(zPos*level)/2),math.floor(x2_ship-(zPos*level)/2),yF2_ship,yF2_ship,green,TOP_SCREEN)
				Screen.drawLine(math.floor(x2_ship-(zPos*level)/2),math.floor(x2_ship-(zPos*level)/2),yF_ship,yF2_ship,green,TOP_SCREEN)
				if ((not top_hide) or (not left_hide)) then Screen.drawLine(math.floor(x_ship+(zPos*level)/2),math.floor(xF_ship+(zPos*level)/2),yF_ship,y_ship,green,TOP_SCREEN,RIGHT_EYE) end
				if ((not top_hide) or (not right_hide)) then Screen.drawLine(math.floor(x2_ship+(zPos*level)/2),math.floor(xF_ship+(zPos*level)/2),yF_ship,y_ship,green,TOP_SCREEN,RIGHT_EYE) end
				if ((not bottom_hide) or (not left_hide)) then Screen.drawLine(math.floor(x_ship+(zPos*level)/2),math.floor(xF_ship+(zPos*level)/2),yF2_ship,y_ship,green,TOP_SCREEN,RIGHT_EYE) end
				if ((not bottom_hide) or (not right_hide)) then Screen.drawLine(math.floor(x2_ship+(zPos*level)/2),math.floor(xF_ship+(zPos*level)/2),yF2_ship,y_ship,green,TOP_SCREEN,RIGHT_EYE) end
				Screen.drawLine(math.floor(x_ship+(zPos*level)/2),math.floor(x_ship+(zPos*level)/2),yF_ship,yF2_ship,green,TOP_SCREEN,RIGHT_EYE)
				Screen.drawLine(math.floor(x_ship+(zPos*level)/2),math.floor(x2_ship+(zPos*level)/2),yF_ship,yF_ship,green,TOP_SCREEN,RIGHT_EYE)
				Screen.drawLine(math.floor(x_ship+(zPos*level)/2),math.floor(x2_ship+(zPos*level)/2),yF2_ship,yF2_ship,green,TOP_SCREEN,RIGHT_EYE)
				Screen.drawLine(math.floor(x2_ship+(zPos*level)/2),math.floor(x2_ship+(zPos*level)/2),yF_ship,yF2_ship,green,TOP_SCREEN,RIGHT_EYE)
			end
		else
			if gpu then
				if ((not top_hide) or (not left_hide)) then Graphics.drawLine(x_ship,xF_ship,yF_ship,y_ship,green) end
				if ((not top_hide) or (not right_hide)) then Graphics.drawLine(x2_ship,xF_ship,yF_ship,y_ship,green) end
				if ((not bottom_hide) or (not left_hide)) then Graphics.drawLine(x_ship,xF_ship,yF2_ship,y_ship,green) end
				if ((not bottom_hide) or (not right_hide)) then Graphics.drawLine(x2_ship,xF_ship,yF2_ship,y_ship,green) end
				Graphics.drawLine(x_ship,x_ship,yF_ship,yF2_ship,green)
				Graphics.drawLine(x_ship,x2_ship,yF_ship,yF_ship,green)
				Graphics.drawLine(x_ship,x2_ship,yF2_ship,yF2_ship,green)
				Graphics.drawLine(x2_ship,x2_ship,yF_ship,yF2_ship,green)
				Graphics.termBlend()
			else
				if ((not top_hide) or (not left_hide)) then Screen.drawLine(x_ship,xF_ship,yF_ship,y_ship,green,TOP_SCREEN) end
				if ((not top_hide) or (not right_hide)) then Screen.drawLine(x2_ship,xF_ship,yF_ship,y_ship,green,TOP_SCREEN) end
				if ((not bottom_hide) or (not left_hide)) then Screen.drawLine(x_ship,xF_ship,yF2_ship,y_ship,green,TOP_SCREEN) end
				if ((not bottom_hide) or (not right_hide)) then Screen.drawLine(x2_ship,xF_ship,yF2_ship,y_ship,green,TOP_SCREEN) end
				Screen.drawLine(x_ship,x_ship,yF_ship,yF2_ship,green,TOP_SCREEN)
				Screen.drawLine(x_ship,x2_ship,yF_ship,yF_ship,green,TOP_SCREEN)
				Screen.drawLine(x_ship,x2_ship,yF2_ship,yF2_ship,green,TOP_SCREEN)
				Screen.drawLine(x2_ship,x2_ship,yF_ship,yF2_ship,green,TOP_SCREEN)
			end
		end
	
	-- Generate background effect
	for i = 1, size do
		starfield[i].z = starfield[i].z - speed
		if starfield[i].z < speed then createStar(i) end
		x = width / 2 + starfield[i].x / starfield[i].z
		y = height / 2 + starfield[i].y / starfield[i].z
		if x < 5 or y < 0 or x >= width-5 or y >= height then
			createStar(i)
		else
			if Screen.get3DLevel() > 0 then
				Screen.drawPixel(math.floor(x-(starfield[i].z*level)/2), math.floor(y), white, TOP_SCREEN)
				Screen.drawPixel(math.floor(x+(starfield[i].z*level)/2), math.floor(y), white, TOP_SCREEN,RIGHT_EYE)
			else
				Screen.drawPixel(math.floor(x), math.floor(y), white, TOP_SCREEN)
			end
		end
	end

	-- Blit shoots
	while i <= #shoots do
		found = false
		shoots[i].z = shoots[i].z + 0.1
		x = width / 2 + shoots[i].x / shoots[i].z
		y = height / 2 + shoots[i].y / shoots[i].z
		if not (x < 0 or y < 0 or x >= width or y >= height) then
			for j = 1, #asteroids do
				if asteroids[j].color == yellow then
					if shoots[i].z >= asteroids[j].z - 0.1 and shoots[i].z <= asteroids[j].z + 0.1 then
						if shoots[i].x >= asteroids[j].x and shoots[i].x <= asteroids[j].x + 50 then
							if shoots[i].y >= asteroids[j].y and shoots[i].y <= asteroids[j].y + 50 then
								table.remove(asteroids,j)
								table.remove(shoots,i)
								destroys = destroys + 1
								found = true
								break
							end
						end
					end
				end
			end
			if not found then
				color = colors[math.random(1,5)]
				Screen.drawPixel(math.floor(x), math.floor(y), color, TOP_SCREEN)
				if Screen.get3DLevel() > 0 then	
					Screen.drawPixel(math.floor(x+shoots[i].z), math.floor(y), color, TOP_SCREEN,RIGHT_EYE)
				end
			end
		end
		if found then
			-- dummy, prevents interpreter bugs
		elseif shoots[i].z > 10 then
			table.remove(shoots,i)
		else
			i = i + 1
		end
	end
	
	-- Draw info
	Screen.debugPrint(0,0,"Points: "..(survival_time + (destroys * 50)),white,BOTTOM_SCREEN)
	Screen.debugPrint(0,15,"Asteroids destroyed: " .. destroys,white,BOTTOM_SCREEN)
	Screen.debugPrint(0,45,"Special objects:",white,BOTTOM_SCREEN)
	Screen.debugPrint(0,60,"Cyan objects = Laser",cyan,BOTTOM_SCREEN)
	Screen.debugPrint(0,75,"Red objects = Ship breakdown",red,BOTTOM_SCREEN)
	
	-- Controls triggering
	pad = Controls.read()
	xpad,ypad = Controls.readCirclePad()
	if not blocked and not lose then
		if (xpad < - 50) then
			xPos = xPos - 15
			if xPos < -250 then
				xPos = -250
			end
		end
		if (ypad > 50) then
			yPos = yPos - 15
			if yPos < -250 then
				yPos = -250
			end
		end
		if (xpad > 50) then
			xPos = xPos + 15
			if xPos > 250 then
				xPos = 250
			end
		end
		if (ypad < - 50) then
			yPos = yPos + 15
			if yPos > 250 then
				yPos = 250
			end
		end
		if Controls.check(pad,KEY_DLEFT) then
			xPos = xPos - 15
			if xPos < -250 then
				xPos = -250
			end
		elseif Controls.check(pad,KEY_DRIGHT) then
			xPos = xPos + 15
			if xPos > 250 then
				xPos = 250
			end
		end
		if Controls.check(pad,KEY_DUP) then
			yPos = yPos - 15
			if yPos < -250 then
				yPos = -250
			end
		elseif Controls.check(pad,KEY_DDOWN) then
			yPos = yPos + 15
			if yPos > 250 then
				yPos = 250
			end
		end
		if Controls.check(pad,KEY_L) and (not Controls.check(oldpad,KEY_L) or autofire) then
			createShoot(#shoots + 1)
		elseif Controls.check(pad,KEY_R) and (not Controls.check(oldpad,KEY_R) or autofire) then
			createShoot(#shoots + 1)
		end
	elseif lose then
		Screen.debugPrint(150,110,"You lose!",red,TOP_SCREEN)
		Screen.debugPrint(110,125,"Points: "..(survival_time + (destroys * 50)),white,TOP_SCREEN)
		Screen.debugPrint(110,140,"Press X to restart",white,TOP_SCREEN)
		Screen.debugPrint(110,155,"Press START to exit",white,TOP_SCREEN)
		if Screen.get3DLevel() > 0 then
			Screen.debugPrint(150,110,"You lose!",red,TOP_SCREEN,RIGHT_EYE)
			Screen.debugPrint(110,125,"Points: "..(survival_time + (destroys * 50)),white,TOP_SCREEN,RIGHT_EYE)
			Screen.debugPrint(110,140,"Press X to restart",white,TOP_SCREEN,RIGHT_EYE)
			Screen.debugPrint(110,155,"Press START to exit",white,TOP_SCREEN,RIGHT_EYE)
		end
		if Controls.check(Controls.read(),KEY_X) then
			GarbageCollection()
			restart = true
			dofile(System.currentDirectory().."/asteroids.lua") 
		elseif Controls.check(Controls.read(),KEY_START) then
			GarbageCollection()
			restart = nil
			dofile(System.currentDirectory().."/asteroids.lua") 
		end
	else
		tmp = Timer.getTime(block_time) / 1000
		Screen.debugPrint(180,1,(5-math.floor(tmp)),red,TOP_SCREEN)
		if Screen.get3DLevel() > 0 then
			Screen.debugPrint(180,1,(5-math.floor(tmp)),red,TOP_SCREEN,RIGHT_EYE)
		end
		if tmp > 5 then
			Timer.destroy(block_time)
			blocked = false
		end
	end
	if autofire then
		tmp = Timer.getTime(autofire_time) / 1000
		Screen.debugPrint(200,1,(5-math.floor(tmp)),cyan,TOP_SCREEN)
		if Screen.get3DLevel() > 0 then
			Screen.debugPrint(200,1,(5-math.floor(tmp)),cyan,TOP_SCREEN,RIGHT_EYE)
		end
		if tmp > 5 then
			Timer.destroy(autofire_time)
			autofire = false
		end
	end
	Screen.debugPrint(0,225,"v.0.5 ALPHA",white,TOP_SCREEN)
	if Screen.get3DLevel() > 0 then
		Screen.debugPrint(0,225,"v.0.5 ALPHA",white,TOP_SCREEN,RIGHT_EYE)
	end
	--if Controls.check(pad,KEY_SELECT) and (not Controls.check(oldpad,KEY_SELECT)) then
	--	if screen_idx == nil then
	--		screen_idx = 0
	--	end
	--	System.takeScreenshot("/aster"..screen_idx..".jpg",true)
	--	screen_idx = screen_idx + 1
	--end
	oldpad = pad
	Screen.waitVblankStart()
	Screen.flip()
	
end
