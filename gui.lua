GUI = {}

function GUI:load()
    self.coins = {}
    self.coins.image = love.graphics.newImage("assets/coin.png")
    self.coins.width = self.coins.image:getWidth()
    self.coins.height = self.coins.image:getHeight()
    self.coins.scale = 3
    self.coins.x = 50
    self.coins.y = 50
    self.font = love.graphics.newFont("assets/bit.ttf", 36)
end


function GUI:update(dt)
    
end


function GUI:draw()
    self:displayCoins()
    self:displayCoinsNumber()
end


function GUI:displayCoins()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.draw(self.coins.image, self.coins.x + 2, self.coins.y + 2, 0, self.coins.scale, self.coins.scale)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.coins.image, self.coins.x, self.coins.y, 0, self.coins.scale, self.coins.scale)

    --love.graphics.setFont(self.font)
    --local scoreX = self.coins.x + self.coins.width * self.coins.scale
    --local scoreY = self.coins.y + self.coins.height / 2 * self.coins.scale - self.font:getHeight() / 2
    --love.graphics.setColor(0, 0, 0, 0.5)
    --love.graphics.print(" : "..Player.coins, scoreX + 2, scoreY + 2)
    --love.graphics.setColor(1, 1, 1, 1)
    --love.graphics.print(" : "..Player.coins, scoreX, scoreY)
end


function GUI:displayCoinsNumber()
    love.graphics.setFont(self.font)
    local scoreX = self.coins.x + self.coins.width * self.coins.scale
    local scoreY = self.coins.y + self.coins.height / 2 * self.coins.scale - self.font:getHeight() / 2
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(" : "..Player.coins, scoreX + 2, scoreY + 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(" : "..Player.coins, scoreX, scoreY)
end