--
--  Game
--
local Gamestate = requireLibrary("hump.gamestate")
local timer = requireLibrary("hump.timer")
local Vector = requireLibrary("hump.vector")
local tween = timer.tween
local Map = require "src.entities.Map"
local Camera = requireLibrary("hump.camera")

Game = Gamestate.new()

local stuff = {}

local p, map, cam
local mw, mh
local moving 

function Game:enter()
    moving = false
    love.audio.play(Music.theme)
    Music.theme:setVolume(0.1)
    Music.theme:setLooping(true)
    mw = 10
    mh = 100

    p = {
        x = 6,
        y = 0,
        dir = 1,
        frame = 1,
        animspeed = 10
    }

    cam = Camera(p.x*16, p.y*16)
    cam.scale = 2

    local cols = {
        {1,1,1},
        {1,1,1},
        {1,1,1}
    }

    local imgs = {
        Image.dirt,
        Image.gravel,
        Image.bio,
    }

    map = Map()

    for i=1, mw do
        for j=1,mh do
            local t = map:set(i,j, {
                type = math.random(1, 3)
            })
            t.col = cols[t.type]
            if math.random() < 0.1 then
                t.questionmark = true
            end
            t.img = imgs[t.type]
            if math.random() < 0.05 and j > 1 then
                local t = map:set(i,j, {
                    type = 4,
                    col = {1,1,1},
                    img = Image.spikes
                })
            elseif math.random() < 0.1 then
                local t = map:set(i,j, {
                    type = 5,
                    col = {1,1,1},
                    img = Image.block
                })
            elseif math.random() < 0.1 and j > 1 then
                local t = map:set(i,j, {
                    type = 6,
                    col = {1,1,1},
                    img = Image.gem
                })
                local t = map:set(i,j-1, {
                    type = 5,
                    col = {1,1,1},
                    img = Image.block
                })
            end
        end
    end
end

function Game:update(dt)
    cam.y = cam.y - (cam.y - p.y*16) * dt
    timer.update(dt)
    if moving and p.x ~= math.floor(p.x) then
        p.frame = p.frame + dt * p.animspeed
        if p.frame >= 3 then p.frame = 1 end
    else
        p.frame = 2
    end
    for k in all(stuff) do
        k:update(dt)
    end
end

function Game:draw()
    love.graphics.print(love.timer.getFPS(), 0, 0)
    cam:attach()
    love.graphics.setColor(1,1,1)
    -- love.graphics.rectangle("fill", p.x*16, p.y*16, 16, 16)
    love.graphics.draw(Image["drillbear"..math.floor(p.frame)], p.x*16+8, p.y*16+8, 0, p.dir, 1, 8, 8)

    for i=1, mw do
        for j=1, mh do
            local t = map:get(i,j)
            if t then
                if j > p.y+6 then
                    love.graphics.setColor(0.05,0.05,0.05)
                elseif j > p.y+3 then
                    love.graphics.setColor(t.col[1]*0.2, t.col[2]*0.2, t.col[3]*0.2)
                else
                    love.graphics.setColor(t.col)
                end
                
                -- love.graphics.rectangle("fill", i*16, j*16, 16, 16)
                if t.questionmark then
                    love.graphics.draw(Image.questionmark, i*16,j*16)
                else
                    love.graphics.draw(t.img, i*16,j*16)
                end
            end
        end
    end
    love.graphics.setColor(1,1,1)
    for j=1, mh do
        love.graphics.draw(Image.border, 0, j*16)
        love.graphics.draw(Image.border, (mw+1)*16, j*16)
    end
    for k in all(stuff) do
        k:draw()
    end
    cam:detach()
end
local chain = function(a,b) a(); b() end

local start = function() moving = true end
local done = function() moving = false end

local isBreakable = function(t)
    return t and t.type <= 4
end

local isCollectable = function(t)
    return t.type == 6
end

local addSmoke = function(x,y)
    local k = 1
    local s = {
        update = function() end,
        draw = function() 
            love.graphics.draw(Image["smoke"..k], x*16, y*16)
        end
    }
    timer.after(0.1, function()
        k = 2
        timer.after(0.1, function()
            k = 3
            timer.after(0.1, function()
                del(stuff, s)
            end)
        end)
    end)
    add(stuff, s)
end

local gravity 
gravity = function()
    local t = map:get(p.x, p.y+1)
    if not t or isCollectable(t) or t.type == 4 then --t.type == 4 spike
        print("down", p.x, p.y)
        local count = 1
        for k=2,100 do
            local t = map:get(p.x, p.y+k)
            if not t or t.type == 6 or t.type == 4 then
                count = count + 1
            else
                break
            end
        end
        tween(0.15*count, p, {y = p.y + count}, "expo", function()
            local t = map:get(p.x, p.y)
            if t and t.type == 4 then
                Gamestate.switch(Death)
            elseif t and t.type == 6 then
                map:set(p.x,p.y,nil)
                done()
            else
                done()
            end
        end)
    else
        done()
    end
end

-- let block fall down
local falldown 
falldown = function(x, y)
    if not map:get(x, y-1) then return end
    if map:get(x, y) then return end
    local t = map:get(x,y-1)
    if t.type == 5 then return end
    map:set(x,y-1,nil)
    map:set(x,y, t)
    falldown(x,y-1)
    falldown(x,y+1)
end

-- remove all adjacent of same color
local clear 
clear = function(x,y,typ)
    if not map:get(x,y) then return end
    if map:get(x,y).type == typ then
        map:set(x, y, nil)
        addSmoke(x,y)
        timer.after(0.25, function() falldown(x,y) end)
    else
        return
    end
    clear(x+1, y, typ)
    clear(x-1, y, typ)
    clear(x, y+1, typ)
    clear(x, y-1, typ)
end

local horimove = function(dx, dy)
    start()
    local t = map:get(p.x+dx, p.y)
    if t and isBreakable(t) then 
        clear(p.x+dx, p.y, t.type)
        timer.after(0.35, gravity)
    elseif not t and not map:get(p.x+dx, p.y) then
        tween(0.2, p, {x = p.x + dx}, "linear", gravity)
    elseif t and isCollectable(t) then
        map:set(p.x+dx, p.y, nil)
        -- falldown(p.x+dx, p.y)
        tween(0.2, p, {x = p.x + dx}, "linear", function()
            gravity()
        end)
    else
        done()
    end
end

function Game:keypressed(key)
    if moving then return end
    if key == "left" then
        p.dir = -1
        horimove(-1, 0)
    end
    if key == "right" then
        p.dir = 1
        horimove(1, 0)
    end
    if key == "down" then
        start()
        local t = map:get(p.x, p.y+1)
        if t then 
            clear(p.x, p.y+1, t.type) 
            timer.after(0.2, gravity)
            -- gravity()
        end
        
    end
end
