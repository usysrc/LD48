--
-- Logoscreen
--
local Gamestate = requireLibrary("hump.gamestate")
local timer = requireLibrary("hump.timer")
local Vector = requireLibrary("hump.vector")
local tween = timer.tween

Logoscreen = Gamestate.new()

Logoscreen.enter = function()
    timer.after(2, function()
        Gamestate.switch(Startscreen)
    end)    
end

Logoscreen.update = function(self, dt)
    timer.update(dt)
end

Logoscreen.draw = function(self)
    love.graphics.setColor(1,1,1)
    -- love.graphics.rectangle("fill", 0,0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.draw(Image.logo, 100, 0, 0, 0.5, 0.5)
end
