love.graphics.setDefaultFilter('nearest', 'nearest')
local sti = require("libraries/sti")
local Player = require("player")
local Coin = require("coin")
local Spike = require("spike")
local Stone = require("stone")
local GUI = require("gui")
local Camera = require("camera")
local Enemy = require("enemy")

--love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()
    Map = sti("map/2.lua", {"box2d"})
    World = love.physics.newWorld(0, 2000)
    World:setCallbacks(beginContact, endContact)

    Map:box2d_init(World)
    Map.layers.solid.visible = false
    Map.layers.entity.visible = false
    MapWidth = Map.layers.ground.width * 16

    background = love.graphics.newImage("assets/background.png")

    GUI:load()
    Enemy.loadAssets()
    Player:load()
    spawnEntities()
    --Coin.new(100, 100)
    --Coin.new(200, 100)
    --Coin.new(300, 100)
    --Spike.new(400, 325)
    --Stone.new(900, 150)

    --for i in pairs(Map.layers.solid) do
        --print(i)
    --end

    --for i in pairs(Map.layers.solid.objects) do
        --print(i)
    --end
    --local objectOne = Map.layers.solid.objects[2].x
    --print(objectOne)
end

function love.update(dt)
    World:update(dt)
    Player:update(dt)
    Coin.updateAll(dt)
    Spike.updateAll(dt)
    Stone.updateAll(dt)
    Enemy.updateAll(dt)
    GUI:update(dt)
    Camera:setPosition(Player.x, 0)
end

function love.draw()
    love.graphics.draw(background)
    --Map:draw(0, 0, 2, 2)
    Map:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)

    Camera:apply()

    Player:draw()
    Enemy.drawAll()
    Coin.drawAll()
    Spike.drawAll()
    Stone.drawAll()

    Camera:clear()

    GUI:draw()
end


function love.keypressed(key)
    Player:jump(key)
end

function beginContact(a, b, collision)
    if Coin.beginContact(a, b, collision) == true then
        return
    end

    if Spike.beginContact(a, b, collision) == true then
        return
    end
    
    Enemy.beginContact(a, b, collision)
    Player:beginContact(a, b, collision)
end


function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end


function spawnEntities()
    for i, v in ipairs(Map.layers.entity.objects) do
        --print(Map.layers.entity.objects[i].name)
        --print(v.class)
        --print(v.type)
        if v.type == "Spikes" then
            Spike.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "Stone" then
            Stone.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "Enemy" then
            Enemy.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "Coin" then
            Coin.new(v.x, v.y)
        end
    end
end