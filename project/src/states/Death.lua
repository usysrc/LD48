--
-- Death
--
local Gamestate = requireLibrary("hump.gamestate")
local timer = requireLibrary("hump.timer")
local Vector = requireLibrary("hump.vector")
local tween = timer.tween

Death = Gamestate.new()

Death.enter = function()
    love.audio.stop()
end

Death.draw = function()
    Game:draw()
    love.graphics.setColor(0.5,0,0,0.75)
    love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.scale(2,2)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("you died!", 200, 100)
end

Death.keypressed = function()
    Gamestate.switch(Startscreen)
end