love.graphics.setDefaultFilter('nearest', 'nearest')
local sti = require("libraries/sti")
local Player = require("player")
local Coin = require("coin")
local Spike = require("spike")
local GUI = require("gui")
local Camera = require("camera")

--love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()
    Map = sti("map/2.lua", {"box2d"})
    World = love.physics.newWorld(0, 0)
    World:setCallbacks(beginContact, endContact)

    Map:box2d_init(World)
    Map.layers.solid.visible = false
    MapWidth = Map.layers.ground.width * 16

    background = love.graphics.newImage("assets/background.png")

    GUI:load()
    Player:load()

    Coin.new(100, 100)
    Coin.new(200, 100)
    Coin.new(300, 100)
    Spike.new(400, 325)
end

function love.update(dt)
    World:update(dt)
    Player:update(dt)
    Coin.updateAll(dt)
    Spike.updateAll(dt)
    GUI:update(dt)
    Camera:setPosition(Player.x, 0)
end

function love.draw()
    love.graphics.draw(background)
    --Map:draw(0, 0, 2, 2)
    Map:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)

    Camera:apply()

    Player:draw()
    Coin.drawAll()
    Spike.drawAll()

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

    Player:beginContact(a, b, collision)
end


function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end