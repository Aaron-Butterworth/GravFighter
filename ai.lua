--[[


				Shitty Code Lies Within.
				Stay Away.


]]


enemies = {}
numEnemies = 1
lastSpawn = 0

function enemies.ai(dt)
	for i,v in ipairs(enemies) do
		if v.state == "avoid" then
			for k,b in ipairs(planets) do
				if findDist(v.x, v.y, b.x, b.y) < 300 then
					v.target.x = b.x
					v.target.y = b.y
				end
			end
		elseif v.state == "shoot" then
			v.target.x = player.x + math.random(-5, 5)
			v.target.y = player.y + math.random(-5, 5)
		elseif v.state == "moveToPlayer" then
			local angleToPlayer = findAngle(v.x, v.y, player.x, player.y)

			v.target.x = v.x + math.cos(angleToPlayer + math.pi) * 10
			v.target.y = v.y + math.sin(angleToPlayer + math.pi) * 10
		elseif v.state == "reduceVel" then
			local angleToVel = findAngle(v.x, v.y, v.x + v.xvel, v.y + v.yvel)
			v.target.x = v.x + math.cos(angleToVel) * 10
			v.target.y = v.y + math.sin(angleToVel) * 10
		else
			local rngAngle = math.random(0, math.pi * 2)
			v.target.x = v.x + math.cos(rngAngle) * 10
			v.target.y = v.y + math.cos(rngAngle) * 10
		end

		if v.canShoot == true then
			addBullet(v.x, v.y, v.target.x, v.target.y, 0, 0, "enemy")

			v.xvel = v.xvel - (math.cos(findAngle(v.x, v.y, v.target.x, v.target.y)) * shotForce) * v.m
 			v.yvel = v.yvel - (math.sin(findAngle(v.x, v.y, v.target.x, v.target.y)) * shotForce) * v.m

 			if v.state == "avoid" then
 				v.timer = 15
 			else
 				v.timer = 30
 			end

 			v.canShoot = false
 		end

		local xForce, yForce = findPF(v.x, v.y, v.m)
		v.xvel = v.xvel + (xForce * v.m * dt)
		v.yvel = v.yvel + (yForce * v.m * dt)

		v.xvel = math.clamp(-250, v.xvel, 250)
		v.yvel = math.clamp(-250, v.yvel, 250)

 		v.x = v.x + v.xvel * dt
 		v.y = v.y + v.yvel * dt

 		if currentTime - lastSpawn > 5 then
 			numEnemies = numEnemies + 1
 		end

 		if v.timer > 0 then	
 			v.timer = v.timer - 1
 		else
 			v.canShoot = true 
 		end

 		for k,b in ipairs(bullets) do
			if b.owner == "player" then
				if checkCircularCollision(v.x, v.y, b.x, b.y, 8, 2) then
					table.remove(enemies, i)
					score = score + 10
					player.ammo = player.ammo + 50
					table.remove(bullets, k)
				end
			end
		end

		for k,b in ipairs(planets) do
			if checkCircularCollision(v.x, v.y, b.x, b.y, 8, b.m/100) then
				table.remove(enemies, i)
			end
		end
	end
end

function enemies.state(dt)
	for i,v in ipairs(enemies) do
		local tooClose = false
		local canSee   = true

		for k,b in ipairs(planets) do
			if findDist(v.x, v.y, b.x, b.y) < (100 + b.m/100 + (math.sqrt((v.xvel ^ 2) + (v.yvel ^ 2)))) then
				tooClose = true
			end

			if ray2circle(v.x, v.y, findAngle(v.x, v.y, player.x, player.y), b.x, b.y, b.m/100) == true then
				canSee = false
			end
		end


		if tooClose == true then
			v.state = "avoid"
		elseif math.sqrt((v.xvel ^ 2) + (v.yvel ^ 2)) > 300 then
			v.state = "reduceVel"
		elseif canSee == true and findDist(player.x, player.y, v.x, v.y) <= 300 then
			v.state = "shoot"
		elseif findDist(player.x, player.y, v.x, v.y) > 300 then
			v.state = "moveToPlayer"
		else
			v.state = "idle"
		end
	end
end

function enemies.spawn()
	if #enemies < numEnemies and #enemies < 20 then
		local canSpawn = true
		local x = math.random(player.x - 2000, player.x + 2000)
		local y = math.random(player.y - 2000, player.y + 2000)

		if checkCircularCollision(x, y, player.x, player.y, 8, 1000) then
			canSpawn = false
		end

		for i,v in ipairs(planets) do
			if findDist(x,y, v.x,v.y) < (300 + v.m/100) then
				canSpawn = false
			end
		end

		if canSpawn == true then
			addEnemy(x,y,10)
			lastSpawn = love.timer.getTime()
		end
	end
end

function enemies.draw()
	love.graphics.setColor(194,59,34)

	for i,v in ipairs(enemies) do
		love.graphics.circle("line", v.x, v.y, 8, 24)
	end
end

function addEnemy(x, y, m)
	local em = {}
	em.x 		= x
	em.y 		= y
	em.m 		= m
	em.xvel 	= 0 
	em.yvel 	= 0
	em.state 	= "idle"

	em.canShoot = true
	em.timer	= 0

	em.target	= {x = 0, y = 0}

	table.insert(enemies, em)
end


--[[
Does a ray-circle intersection test.
Parameters:
	x1, y1, di - x, y, direction (radians) of ray
	x, y, r - position & radius of circle
Returns:
	result - whether collision occurred
	x - collision X
	y - collision Y
	distance - distance from ray start to collision point
]]
function ray2circle(x1, y1, di, x, y, r)
	local tx, ty, tl, rx, ry, th
	local vx, vy = math.cos(di), math.sin(di)
	-- relative x, y of circle center:
	x = x - x1
	y = y - y1
	-- rotate point
	tx = x * vx + y * vy
	ty = x * vy + y * -vx
	-- no intersection:
	if (ty > r) or (ty < -r) then return false, nil, nil, nil end
	-- find X coordinate that line hits rotated circle at
	th = math.cos(math.asin(ty / r)) * r
	-- too far behind
	if (tx + th < 0) then return false, nil, nil, nil end
	-- line start is in circle:
	tx = tx - th
	if (tx < 0) then return true, x1, y1, 0 end
	--
	return true, x1 + tx * vx, y1 + tx * vy, tx
end

function range(from, to, step)
  step = step or 1
  return function(_, lastvalue)
    local nextvalue = lastvalue + step
    if step > 0 and nextvalue <= to or step < 0 and nextvalue >= to or
       step == 0
    then
      return nextvalue
    end
  end, nil, from - step
end