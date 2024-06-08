love.graphics.setDefaultFilter('nearest', 'nearest')

local Player = require("player")
local Coin = require("coin")
local Spike = require("spike")
local Stone = require("stone")
local GUI = require("gui")
local Camera = require("camera")
local Enemy = require("enemy")
local Map = require("map")

--love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()
    Enemy.loadAssets()
    Map:load()

    background = love.graphics.newImage("assets/background.png")

    GUI:load()
    Player:load()
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
    Map:update(dt)
end

function love.draw()
    love.graphics.draw(background)
    --Map:draw(0, 0, 2, 2)
    Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)

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