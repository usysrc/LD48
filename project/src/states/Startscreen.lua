--
-- Startscreen
--
local Gamestate = requireLibrary("hump.gamestate")
local timer = requireLibrary("hump.timer")
local Vector = requireLibrary("hump.vector")
local tween = timer.tween

Startscreen = Gamestate.new()

Startscreen.draw = function()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(Image.startscreen,250,150,0,2,2)
end

Startscreen.keypressed = function()
    Gamestate.switch(Game)
end

return Startscreen