Player = {}

function Player:load()
    self.x = 100
    self.y = 0
    self.width = 20
    self.height = 60
    self.xVelocity = 0
    self.yVelocity = 0
    self.maxSpeed = 400
    self.acceleration = 4000
    self.friction = 3500
    self.gravity = 1500
    self.jumpAmount = -500

    self.doubleJump = true
    self.grounded = false

    self.direction = "right"
    self.state = "idle"

    self.graceTime = 0
    self.graceDuration = 0.1

    self:loadAssets()

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)

    --self.hero_atlas = love.graphics.newImage("assets/player/Idle.png")
    --self.hero_sprite = love.graphics.newQuad(20, 16, 36, 48, self.hero_atlas:getDimensions())
end


function Player:loadAssets()
    self.animation = {timer = 0, rate = 0.1}

    self.animation.run = {total = 6, current = 1, image = {}}
    for i=1, self.animation.run.total do
        self.animation.run.image[i] = love.graphics.newImage("assets/player/run/"..i..".png")
    end

    self.animation.idle = {total = 4, current = 1, image = {}}
    for i=1, self.animation.idle.total do
        self.animation.idle.image[i] = love.graphics.newImage("assets/player/idle/"..i..".png")
    end

    self.animation.jump = {total = 4, current = 1, image = {}}
    for i=1, self.animation.jump.total do
        self.animation.jump.image[i] = love.graphics.newImage("assets/player/jump/"..i..".png")
    end

    self.animation.air = {total = 4, current = 1, image = {}}
    for i=1, self.animation.air.total do
        self.animation.air.image[i] = love.graphics.newImage("assets/player/air/"..i..".png")
    end

    self.animation.draw = self.animation.idle.image[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function Player:update(dt)
    self:setState()
    self:setDirection()
    self:animate(dt)
    self:decraseGraceTime(dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)
end


function Player:setState()
    if self.grounded == false then
        self.state = "air"
    elseif self.xVelocity == 0 then
        self.state = "idle"
    else
        self.state = "run"
    end
    --print(self.state)
end

function Player:setDirection()
    if self.xVelocity < 0 then
        self.direction = "left"
    elseif self.xVelocity > 0 then
        self.direction = "right"
    end
end

function Player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end


function Player:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.image[anim.current]
end

function Player:decraseGraceTime(dt)
    if self.grounded == false then
        self.graceTime = self.graceTime - dt
    end
end

function Player:applyGravity(dt)
    if self.grounded == false then
        self.yVelocity = self.yVelocity + self.gravity * dt
    end
end


function Player:move(dt)
    if love.keyboard.isDown("d", "right") then
        self.xVelocity = math.min(self.xVelocity + self.acceleration * dt, self.maxSpeed)
        --if self.xVelocity < self.maxSpeed then
            --if self.xVelocity + self.acceleration * dt < self.maxSpeed then
                --self.xVelocity = self.xVelocity + self.acceleration * dt
            --else 
                --self.xVelocity = self.maxSpeed
            --end
        --end
    elseif love.keyboard.isDown("a", "left") then
        self.xVelocity = math.max(self.xVelocity - self.acceleration * dt, -self.maxSpeed)
        --if self.xVelocity > -self.maxSpeed then
            --if self.xVelocity - self.acceleration * dt > -self.maxSpeed then
                --self.xVelocity = self.xVelocity - self.acceleration * dt
            --else 
                --self.xVelocity = -self.maxSpeed
            --end
        --end
    else 
        self:applyFriction(dt)
    end
end


function Player:applyFriction(dt)
    if self.xVelocity > 0 then
        self.xVelocity = math.max(self.xVelocity - self.friction * dt, 0)
        --if self.xVelocity - self.friction * dt > 0 then
            --self.xVelocity = self.xVelocity - self.friction * dt
        --else
            --self.xVelocity = 0
        --end
    elseif self.xVelocity < 0 then
        self.xVelocity = math.min(self.xVelocity + self.friction * dt, 0)
        --if self.xVelocity + self.friction * dt < 0 then
            --self.xVelocity = self.xVelocity + self.friction * dt
        --else
            --self.xVelocity = 0
        --end
    end
end


function Player:syncPhysics()
    --self.x = self.physics.body:getX()
    --self.y = self.physics.body:getY()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVelocity, self.yVelocity)
end


function Player:beginContact(a, b, collision)
    if self.grounded == true then return end
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny > 0 then
            --meaning b(object) is below the a (player)
            self:land(collision)
        elseif ny < 0 then
            self.yVelocity = 0
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            --meaning b (player) is below the a (object)
            self:land(collision)
        elseif ny > 0 then
            self.yVelocity = 0
        end
    end
end


function Player:land(collision)
    self.currentGroundCollision = collision
    self.yVelocity = 0
    self.doubleJump = true
    self.grounded = true
    self.graceTime = self.graceDuration
end


function Player:jump(key)
    if (key == "w" or key == "up") then
        if self.grounded == true or self.graceTime > 0 then
            self.yVelocity = self.jumpAmount
            self.grounded = false
            self.graceTime = 0
        elseif self.grounded == false and self.doubleJump == true then
            self.yVelocity = self.jumpAmount
            self.doubleJump = false
        end
    end
    --elseif (key == "w" or key == "up") and self.grounded == false and self.doubleJump == true then
        --self.yVelocity = self.jumpAmount
        --self.doubleJump = false
    --end
end

function Player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end
end

function Player:draw()
    local scaleX = 1
    if self.direction == "left" then
        scaleX = -1
    end
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1, self.animation.width / 2, self.animation.height / 2)
    --love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    --love.graphics.draw(self.hero_atlas, 25, 25, 0, 1, 1)
    --love.graphics.draw(self.hero_atlas, self.hero_sprite, self.x - self.width / 2, self.y - self.height / 2, 0, 1, 1)
end