local Enemy = {}
Enemy.__index = Enemy
local Player = require("player")

local ActiveEnemys = {}


function Enemy.new(x, y)
    local instance = setmetatable({}, Enemy)
    instance.x = x
    instance.y = y
    instance.offsetY = -8
    instance.r = 0

    instance.speed = 100
    instance.speedMod = 1
    instance.xVelocity = instance.speed

    instance.rageCounter = 0
    instance.rageTrigger = 3

    instance.damage = 1

    instance.state = "walk"

    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.run = {total = 4, current = 1, image = Enemy.runAnimation}
    instance.animation.walk = {total = 4, current = 1, image = Enemy.walkAnimation}
    instance.animation.draw = instance.animation.walk.image[1]

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.body:setFixedRotation(true)
    instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.4, instance.height * 0.75)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setMass(25)

    table.insert(ActiveEnemys, instance)
end


function Enemy.loadAssets()
    Enemy.runAnimation = {}
    for i = 1,4 do
        Enemy.runAnimation[i] = love.graphics.newImage("assets/enemy/run/"..i..".png")
    end

    Enemy.walkAnimation = {}
    for i = 1,4 do
        Enemy.walkAnimation[i] = love.graphics.newImage("assets/enemy/walk/"..i..".png")
    end

    Enemy.width = Enemy.runAnimation[1]:getWidth()
    Enemy.height = Enemy.runAnimation[1]:getHeight()
end


function Enemy:update(dt)
    self:syncPhysics()
    self:animate(dt)
end


function Enemy.removeOld()
    for i, v in ipairs(ActiveEnemys) do
        v.physics.body:destroy()
    end

    ActiveEnemys = {}
end


function Enemy:incrementRage()

    self.rageCounter = self.rageCounter + 1

    if self.rageCounter > self.rageTrigger then
        self.state = "run"
        self.speedMod = 3
        self.rageCounter = 0
    else
        self.state = "walk"
        self.speedMod = 1
    end

end


function Enemy:flipDirection()
    self.xVelocity = -self.xVelocity
end


function Enemy:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end


function Enemy:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.image[anim.current]
end


function Enemy:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVelocity * self.speedMod, 100)
end


function Enemy:draw()
    local scaleX = 1
    if self.xVelocity < 0 then
        scaleX = -1
    end

    love.graphics.draw(self.animation.draw, self.x , self.y + self.offsetY, self.r, scaleX, 1, self.width / 2, self.height / 2)
end


function Enemy.updateAll(dt)
    for i, instance in ipairs(ActiveEnemys) do
        instance:update(dt)
    end
end


function Enemy:drawAll()
    for i, instance in ipairs(ActiveEnemys) do
        instance:draw()
    end
end


function Enemy.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveEnemys) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Player:takeDamage(instance.damage)
                sounds.hitHurt:play()
            end
            instance:incrementRage()
            instance:flipDirection()
        end
    end
end

return Enemy