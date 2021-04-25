--
-- Startscreen
--
local Gamestate = requireLibrary("hump.gamestate")
local timer = requireLibrary("hump.timer")
local Vector = requireLibrary("hump.vector")
local tween = timer.tween

Startscreen = Gamestate.new()
local music

Startscreen.enter = function()
    love.audio.stop()
    if not music then
        Music.startscreen:setVolume(0.2)
        Music.startscreen:setLooping(true)
        music = Music.startscreen:play()
    else
        local k = { vol = 0.0 }
        tween(0.5, k, {vol = 0.2})
        timer.during(0.5, function(dt)
            music:setVolume(k.vol)
        end,function()
            music:setVolume(0)
            music:pause()
            Gamestate.switch(Game)
        end)
    end
end

Startscreen.update = function(self, dt)
    timer.update(dt)
end

Startscreen.draw = function()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(Image.startscreen,250,150,0,2,2)
end

local done = false

Startscreen.keypressed = function()
    if done then return end
    done = true
    local k = { vol = 0.2 }
    tween(0.5, k, {vol = 0})
    timer.during(0.5, function(dt)
        music:setVolume(k.vol)
    end,function()
        music:setVolume(0)
        music:pause()
        Gamestate.switch(Game)
    end)
end

return Startscreen