--
-- Startscreen
--
local Gamestate = requireLibrary("hump.gamestate")
local timer = requireLibrary("hump.timer")
local Vector = requireLibrary("hump.vector")
local tween = timer.tween

Startscreen = Gamestate.new()
local music
local at, bt
local done = false

local scale = 1
local time = 0
local overlay = 0

Startscreen.enter = function()
    overlay = 0
    if at then timer.cancel(at) end
    if bt then timer.cancel(bt) end
    done = false
    timer:clear()
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
        end)
    end
end

Startscreen.update = function(self, dt)
    timer.update(dt)
    time = time + dt
    scale = (1 + math.sin(time*5)) * 0.1
end

Startscreen.draw = function()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(Image.startscreen,350+64,180+64,0,2+scale,2+scale, 64,64)
    love.graphics.draw(Image.startscreenbear,350+64,180+44,0,2,2, 64,64)
    love.graphics.setColor(0.1,0,0.2)
    -- love.graphics.rectangle("fill", 0, 350-8, 800, 800)
    love.graphics.scale(2,2)
    love.graphics.setColor(1,1,1)
    for i=0, 32 do
        for j=11, 32 do
            love.graphics.draw(Image.bio, i*16, j*16)
        end
    end
    love.graphics.setColor(scale*20, scale*20, scale*20)
    love.graphics.print("- ANY KEY TO START -", 140, 190)
    love.graphics.setColor(1,1,1)
    love.graphics.print("SPELLTOP STUDIO 2021 LD48", 120, 280)

    love.graphics.setColor(0,0,0,overlay)
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(), love.graphics.getHeight())
end


Startscreen.keypressed = function(self, key)
    if done then return end
    Sfx.startgame:setVolume(0.2)
    Sfx.startgame:play()

    done = true
    Game:setup()
    local k = { vol = 0.2 }
    at = tween(0.5, k, {vol = 0})
    bt = timer.during(0.6, function(dt)
        music:setVolume(k.vol)
        overlay = math.min(1, overlay + dt * 10 )
    end, function()
        print("switiching")
        music:setVolume(0)
        music:pause()
        return Gamestate.switch(Game)
    end)
end

Startscreen.leav = function()
    timer.clear()
end

return Startscreen