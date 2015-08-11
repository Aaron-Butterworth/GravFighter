mainFont = love.graphics.newFont("font/neuropol.ttf", 20)
mainFontSmall = love.graphics.newFont("font/neuropol.ttf", 16)
mainFontDebug = love.graphics.newFont("font/neuropol.ttf", 10)

function GUIdraw()
	love.graphics.setFont(mainFont)
	love.graphics.print("AMMO: "..player.ammo, screen.w - mainFont:getWidth("AMMO: "..player.ammo) - 5, screen.h - 25)
	love.graphics.print("SCORE: "..score, 5, screen.h - 25)
	love.graphics.print("LIVES: "..player.lives, 5, screen.h - 25 - mainFont:getHeight("SCORE: "..score) - 2)
	if not DEBUG then
		love.graphics.setFont(mainFontSmall)
		love.graphics.print("FPS: "..love.timer.getFPS(), 5, 5)
	else
		love.graphics.setFont(mainFontDebug)
		love.graphics.print("FPS: "..love.timer.getFPS(), screen.w - mainFontDebug:getWidth("FPS: "..love.timer.getFPS()) - 5, 5)
	end
end

function deadDraw()
	love.graphics.setFont(mainFont)
	love.graphics.print("SCORE: "..score, (screen.w / 2) - (mainFont:getWidth("SCORE: "..score) / 2), (screen.h / 2) - (mainFont:getHeight("SCORE: "..score) / 2))
	love.graphics.setFont(mainFontSmall)
	love.graphics.print("Press 'r' to play again.", (screen.w / 2) - (mainFontSmall:getWidth("Press 'r' to play again.") / 2), (screen.h / 2) - (mainFontSmall:getHeight("Press 'r' to play again.") / 2) + (mainFont:getHeight("SCORE: "..score) / 2) + (screen.h / 20))
end