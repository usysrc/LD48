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
    Sfx.explo:setVolume(0.2)
    Sfx.pickup:setVolume(0.2)
    Sfx.hit:setVolume(0.2)
    Sfx.slide:setVolume(0.025)
    Sfx.fall:setVolume(0.02)
    Sfx.land:setVolume(0.2)
    Sfx.drink:setVolume(0.1)

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
        animspeed = 10,
        hp = 30,
        energy = 100,
        money = 0,
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
            elseif math.random() < 0.01 and j > 1 then
                local t = map:set(i,j, {
                    type = 8,
                    col = {1,1,1},
                    img = Image.energy
                })
            elseif math.random() < 0.05 then
                local t = map:set(i,j, {
                    type = 7,
                    col = {1,1,1},
                    img = Image.blob,
                    hp = 5
                })
            elseif math.random() < 0.1 then
                local t = map:set(i,j, {
                    type = 5,
                    col = {1,1,1},
                    img = Image.block
                })
            elseif math.random() < 0.5 and j > 1 then
                local t = map:set(i,j, {
                    type = 6,
                    col = {1,1,1},
                    img = Image.gem
                })
                -- local t = map:set(i,j-1, {
                --     type = 5,
                --     col = {1,1,1},
                --     img = Image.block
                -- })
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
                    love.graphics.draw(t.img, i*16+8,j*16+8, t.r or 0, (t.scale or 1) * (t.dir or 1), t.scale or 1, 8, 8)
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
    love.graphics.push()
    love.graphics.scale(2,2)
    love.graphics.print(love.timer.getFPS(), 0, 0)
    love.graphics.print("hp: "..p.hp, 0, 16)
    love.graphics.print("nrg: "..p.energy, 0, 32)
    love.graphics.print("$: "..p.money, 0, 48)
    love.graphics.pop()
end
local chain = function(a,b) a(); b() end

local start = function() moving = true end
local done = function() moving = false end

local isBreakable = function(t)
    return t and t.type <= 4
end

local isCollectable = function(t)
    return t.type == 6 or t.type == 8
end

function addEffect(x,y, img,r,scale)
    local r = r or 0
    local scale = scale or 1
    local s = {
        update = function() end,
        draw = function() 
            love.graphics.draw(img, x*16+8, y*16+8,r,scale,scale,8,8)
        end
    }
    add(stuff, s)
    return s
end

function addHit(x, y)
    local s = addEffect(x,y,Image.swipe, math.random()*math.pi*2)
    timer.after(0.05, function()
        del(stuff, s)
        local s = addEffect(x,y,Image.hit)
        timer.after(0.05, function() del(stuff, s) end)
    end)
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

local pickups = function(t)
    if t.type == 6 then
        p.money = p.money + 5
        Sfx.pickup:play()
    elseif t.type == 8 then
        p.energy = p.energy + 10
        Sfx.drink:play()
    end
end

local gravity 
gravity = function()
    local t = map:get(p.x, p.y+1)
    if not t or isCollectable(t) or t.type == 4 then --t.type == 4 spike
        local count = 0
        for k=1,100 do
            local t = map:get(p.x, p.y+k)
            if not t then
                count = count + 1
                
            else
                if t and isCollectable(t) or t.type == 4 then 
                    count = count + 1
                end
                break
            end
        end
        tween(0.15*count, p, {y = p.y + count}, "linear", function()
            local t = map:get(p.x, p.y)
            if t and t.type == 4 then
                Gamestate.switch(Death)
            elseif t and isCollectable(t) then
                pickups(t)
                map:set(p.x,p.y,nil)
                gravity()
            else
                Sfx.land:play()
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
    if p.x == x and p.y == y then return end
    map:set(x,y-1,nil)
    map:set(x,y, t)
    falldown(x,y-1)
    falldown(x,y+1)
    local s = Sfx.slide:play()
    s:setPitch(0.5+math.random()*0.5)
end

-- remove all adjacent of same color
local clear 
clear = function(x,y,typ)
    if not map:get(x,y) then return end
    if map:get(x,y).type == typ then
        map:set(x, y, nil)
        addSmoke(x,y)
        timer.after(math.random()*0.1, function()
            local s = Sfx.explo:play()
            s:setVolume(0.05)
            s:setPitch(0.1+math.random()*0.5)
        end)
        
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
    if p.x + dx <= 0 or p.x + dx > mw then return end

    start()
    local t = map:get(p.x+dx, p.y)
    if t and t.type == 7 then
        -- enemy
        p.hp = p.hp - 1
        t.hp = t.hp - 1
        if p.hp <= 0 then
            Gamestate.switch(Death)
        elseif t.hp <= 0 then
            map:set(p.x+dx, p.y, nil)
            falldown(p.x+dx, p.y)
            Sfx.explo:play()
            addSmoke(p.x+dx, p.y)
            done()
        else
            t.dir = dx < 0 and -1 or 1
            Sfx.hit:setPitch(0.8+math.random()*0.4)
            Sfx.hit:play()
            addHit(p.x+dx, p.y)
            timer.after(0.1, function()
                Sfx.hit:setPitch(0.8+math.random()*0.4)
                Sfx.hit:play()
                addHit(p.x, p.y)
                done()
            end)
        end
    elseif t and isBreakable(t) then 
        love.audio.play(Sfx.explo)
        clear(p.x+dx, p.y, t.type)
        timer.after(0.35, gravity)
    elseif not t and not map:get(p.x+dx, p.y) then
        tween(0.2, p, {x = p.x + dx}, "linear", function()
            falldown(p.x - dx, p.y)
            gravity()
        end)
    elseif t and isCollectable(t) then
        pickups(t)
        map:set(p.x+dx, p.y, nil)
        tween(0.2, p, {x = p.x + dx}, "linear", function()
            falldown(p.x + dx, p.y)
            falldown(p.x - dx, p.y)
            gravity()
        end)
    else
        done()
    end
end

function depleteEnergy()
    
    if p.energy <= 0 then 
        p.hp = p.hp - 1
        if p.hp <= 0 then
            Gamestate.switch(Death)
        end
    else
        p.energy = p.energy - 1
    end
end

function Game:keypressed(key)
    if moving then return end
    depleteEnergy()
    
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
            love.audio.play(Sfx.explo)
            clear(p.x, p.y+1, t.type) 
            timer.after(0.2, gravity)
            -- gravity()
        end
        
    end
end
