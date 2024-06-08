local Map = {}
local sti = require("libraries/sti")
local Coin = require("coin")
local Spike = require("spike")
local Stone = require("stone")
local Enemy = require("enemy")
local Player = require("player")

function Map:load()
    self.currentLevel = 1
    World = love.physics.newWorld(0, 2000)
    World:setCallbacks(beginContact, endContact)

    self:initialization()
end


function Map:initialization()
    self.level = sti("map/"..self.currentLevel..".lua", {"box2d"})
    self.level:box2d_init(World)

    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entityLayer = self.level.layers.entity


    self.solidLayer.visible = false
    self.entityLayer.visible = false
    MapWidth = self.groundLayer.width * 16

    self:spawnEntities()
end


function Map:nextLevel()
    self:clearLevel()
    self.currentLevel = self.currentLevel + 1
    self:initialization()
    Player:resetPosition()
end


function Map:clearLevel()
    self.level:box2d_removeLayer("solid")
    Coin.removeOld()
    Spike.removeOld()
    Enemy.removeOld()
    Stone.removeOld()
end


function Map:update(dt)
    if Player.x > MapWidth - 16  then
        self:nextLevel()
    end
end


function Map:spawnEntities()
    for i, v in ipairs(self.level.layers.entity.objects) do
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

return Map