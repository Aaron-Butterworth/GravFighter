player  = {x = 20, y = 20, m = 10, xvel = 0, yvel = 0, ammo = 200, lives = 3}
bullets = {}
bulletSpeed = 200
shotForce = 1
bulletMass = 5

function player.update(dt)
	local xForce, yForce = findPF(player.x, player.y, player.m)
	player.xvel = player.xvel + (xForce * player.m * dt)
	player.yvel = player.yvel + (yForce * player.m * dt)

	player.xvel = math.clamp(-1000, player.xvel, 1000)
	player.yvel = math.clamp(-1000, player.yvel, 1000)

	player.x = player.x + player.xvel * dt
	player.y = player.y + player.yvel * dt

	for i,v in ipairs(planets) do
		if checkCircularCollision(player.x, player.y, v.x, v.y, 8, v.m/100) then
			gameState = "dead"
		end
	end

	for i,v in ipairs(bullets) do
		if v.owner == "enemy" then
			if checkCircularCollision(v.x, v.y, player.x, player.y, 2, 8) then
				player.lives = player.lives - 1 
				table.remove(bullets, i)
			end
		end
	end

	if player.lives == 0 then
		gameState = "dead"
	end
end

function bullets.update(dt)
	for i,v in ipairs(bullets) do
		local xForce = 0
		local yForce = 0

		for k,b in ipairs(planets) do
			if checkCircularCollision(v.x, v.y, b.x, b.y, 2, b.m/100) then
				table.remove(bullets, i)
			end

			local force = getForce(bulletMass, b.m, findDist(v.x, v.y, b.x, b.y))
			local angle = findAngle(v.x, v.y, b.x, b.y)

			xForce = xForce + math.cos(angle) * force
			yForce = yForce + math.sin(angle) * force
		end

		v.xvel = v.xvel + (xForce * bulletMass * dt)
		v.yvel = v.yvel + (yForce * bulletMass * dt)

		v.x = v.x + (v.xvel * dt)
		v.y = v.y + (v.yvel * dt)

		v.life = v.life - 1 * dt

		if v.life <= 0 then
			table.remove(bullets, i)
		end
	end
end

function player.draw()
	love.graphics.setColor(119,190,119)

	love.graphics.circle("line", player.x, player.y, 8, 24)
end

function bullets.draw()
	for i,v in ipairs(bullets) do
		love.graphics.circle("fill", v.x, v.y, 2)
	end
end

function player.mouse(x, y, button)
	if button == "l" and player.ammo > 0 then
		addBullet(player.x, player.y, x,y, player.xvel, player.yvel, "player")

		player.xvel = player.xvel - (math.cos(findAngle(player.x, player.y, x,y)) * shotForce) * player.m
 		player.yvel = player.yvel - (math.sin(findAngle(player.x, player.y, x,y)) * shotForce) * player.m

 		player.ammo = player.ammo - 1
	end
end

function addBullet(x, y, tx, ty, xvel, yvel, owner)
	local startX = x
	local startY = y
	local targetX = tx
	local targetY = ty
 
	local angle = math.atan2((targetY - startY), (targetX - startX))
 
	local bulletDx = bulletSpeed * math.cos(angle) + xvel
	local bulletDy = bulletSpeed * math.sin(angle) + yvel

 	table.insert(bullets, {x = startX, y = startY, xvel = bulletDx, yvel = bulletDy, owner = owner, life = 500})
end