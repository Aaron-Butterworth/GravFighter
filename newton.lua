planets = {}

gravConst = 2

function getForce(m1, m2, r)
	force = gravConst * ((m1 * m2) / (r ^ 2))
	return force
end

--PF - Planet Force
function findPF(x, y, m)
	local xForce = 0
	local yForce = 0

	for i,v in ipairs(planets) do
		local force = getForce(m, v.m, findDist(x, y, v.x, v.y))
		local angle = findAngle(x, y, v.x, v.y)

		xForce = xForce + math.cos(angle) * force
		yForce = yForce + math.sin(angle) * force
	end

	return xForce, yForce
end

function findDist(x1,y1, x2,y2) 
	return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5 
end

function findAngle(x1,y1, x2,y2) 
	return math.atan2(y2 - y1, x2 - x1) 
end

function math.clamp(low, n, high) 
	return math.min(math.max(low, n), high) 
end

function checkCircularCollision(ax, ay, bx, by, ar, br)
	local dx = bx - ax
	local dy = by - ay
	local dist = math.sqrt(dx * dx + dy * dy)
	return dist < ar + br
end


function addPlanet(x, y, m)
	local pl = {}
	pl.x = x
	pl.y = y
	pl.m = m

	table.insert(planets, pl)
end

function planets.draw()
	love.graphics.setColor(200,200,200)

	for i,v in ipairs(planets) do
		love.graphics.circle("fill", v.x, v.y, v.m/100, 36)
	end
end

function makeMap()
	while #planets < 70 do
		local x = math.random(-7500, 7500)
		local y = math.random(-7500, 7500)
		local m = math.random(3500, 10000)

		local canSpawn = true

		for i,v in ipairs(planets) do
			if findDist(v.x, v.y, x, y) < 500 then
				canSpawn = false
			end
		end

		if findDist(player.x, player.y, x,y) < (300 + m/100) then
			canSpawn = false
		end

		if canSpawn == true then
			addPlanet(x,y,m)
		end
	end
end

