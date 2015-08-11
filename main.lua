require "newton"
require "player"
require "gui"
require "ai"

DEBUG = false

gameState = "play"

score = 0

startTime = 0
currentTime = 0

function love.load()
	startTime = love.timer.getTime()
	love.graphics.setBackgroundColor(25, 25, 25)
	SetUpCamera()
	makeMap()
end

function love.update(dt)
	if gameState == "play" then
		player.update(dt)

		enemies.state(dt)
		enemies.ai(dt)
		enemies.spawn()

		bullets.update(dt)

		camUpdate(dt)

		currentTime = love.timer.getTime()
	end

	translatedMouseX = (love.mouse.getX() - cam.x) / cam.scale
	translatedMouseY = (love.mouse.getY() - cam.y) / cam.scale
end

function love.draw()
	love.graphics.setFont(mainFont)
	love.graphics.setColor(255,255,255)

	if gameState == "play" or DEBUG then 
		love.graphics.push()
		love.graphics.translate(cam.x,cam.y)
		love.graphics.scale(cam.scale)

		player.draw()
		enemies.draw()

		planets.draw()
		bullets.draw()

		if DEBUG then
			DEBUG_DRAW_TRANS()
		end

		love.graphics.pop()

		GUIdraw()

	elseif gameState == "dead" then
		love.graphics.push()
		love.graphics.translate(0,0)
		love.graphics.scale(1)

		deadDraw()

		love.graphics.pop()
	end

	if DEBUG then
		DEBUG_DRAW_NONETRANS()
	end
end

function love.mousepressed(x, y, button)
	if button == "wd" and cam.scale > 0.2 then
		cam.scale = cam.scale - 0.1
	elseif button == "wu" and cam.scale < 1.6 then 
		cam.scale = cam.scale + 0.1
	end

	translatedMouseX = (x - cam.x) / cam.scale
	translatedMouseY = (y - cam.y) / cam.scale


	player.mouse(translatedMouseX, translatedMouseY, button)
end


function love.keypressed(key)
	if key == "`" then
		DEBUG = not DEBUG
	end

	if key == "r" then
		while #planets > 0 do
			table.remove(planets, 1)
		end
		while #enemies > 0 do
			table.remove(enemies, 1)
		end
		while #bullets > 0 do
			table.remove(bullets, 1)
		end

		player.xvel = 0
		player.yvel = 0
		player.x = 0
		player.y = 0
		player.ammo = 200
		score = 0

		cam.x = screen.w/2
		cam.y = screen.h/2
		cam.scale = 0.5

		numEnemies = 1 
		enemyTimer = 0

		makeMap()
		gameState = "play"
	end
end

function camUpdate(dt)
	if love.keyboard.isDown("a") then
		cam.x = cam.x + cam.speed * dt
	end

	if love.keyboard.isDown("d") then
		cam.x = cam.x - cam.speed * dt	
	end	

	if love.keyboard.isDown("w") then
		cam.y = cam.y + cam.speed * dt
	end

	if love.keyboard.isDown("s") then
		cam.y = cam.y - cam.speed * dt	
	end	
end

function SetUpCamera()
	screen = {}
	screen.w = love.window.getWidth()
	screen.h = love.window.getHeight()

	cam = {}
	cam.x = screen.w/2
	cam.y = screen.h/2
	cam.tx = 0
	cam.ty = 0
	cam.scale = 0.5
	cam.speed = 300
end

function DEBUG_DRAW_NONETRANS()
	love.graphics.setFont(mainFontDebug)
	love.graphics.print("Mouse X: "..love.mouse.getX(), 5, 5)
	love.graphics.print("Mouse Y: "..love.mouse.getY(), 5, 20)
	love.graphics.print("Transformed Mouse X: "..translatedMouseX, 5, 35)
	love.graphics.print("Transformed Mouse Y: "..translatedMouseY, 5, 50)
	love.graphics.print("Enemies: "..#enemies, 5, 65)
	love.graphics.print("Current Time: "..currentTime, 5, 80)
	love.graphics.print("Last Spawn: "..lastSpawn, 5, 95)
end

function DEBUG_DRAW_TRANS()
	love.graphics.setFont(mainFontDebug)

	for i,v in ipairs(enemies) do
		love.graphics.print("STATE: "..v.state, v.x + 2, v.y)
		love.graphics.print("X: "..v.x, v.x + 2, v.y + mainFontDebug:getHeight("STATE: "..v.state) + 2)
		love.graphics.print("Y: "..v.y, v.x + 2, v.y + mainFontDebug:getHeight("X: "..v.x) + mainFontDebug:getHeight("STATE: "..v.state) + 4)
		love.graphics.print("ATP: "..findAngle(v.x, v.y, player.x, player.y), v.x + 2, v.y + mainFontDebug:getHeight("X: "..v.x) + mainFontDebug:getHeight("STATE: "..v.state) + 6 + mainFontDebug:getHeight("Y: "..v.y))
		love.graphics.print("VEL: "..math.sqrt((v.xvel ^ 2) + (v.yvel ^ 2)), v.x + 2, v.y + mainFontDebug:getHeight("X: "..v.x) + mainFontDebug:getHeight("STATE: "..v.state) + 8 + mainFontDebug:getHeight("Y: "..v.y) + mainFontDebug:getHeight("ATP: "..findAngle(v.x, v.y, player.x, player.y)))

		love.graphics.line(v.x, v.y, v.x + math.cos(findAngle(v.x, v.y, v.target.x, v.target.y)) * 20, v.y + math.sin(findAngle(v.x, v.y, v.target.x, v.target.y)) * 20)
	end
end

