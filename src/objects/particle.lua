Base = require 'libraries.knife.knife.base'

Particle = Base:extend()

function Particle:constructor(x, y, color)
    self.position = {x = x, y = y, dx = love.math.random(-2,2), dy = love.math.random(-8,0)}
    self.size = 10
    self.color = color or 7
    self.t = 0
    self.lifetime = love.math.random(0.5, 1.2)
    self.speed = love.math.random(1, 2)
    self.damp = 0.98
    
    self.sizeOverLifetime = {5,9,10,11,11,10,10,5}
    self.sizeMod = 0.2
    self.gravity = 4
    self.colorOverLifetime = {7, self.color, 7, self.color, self.color, self.color}
    self.mode = "fill"

    table.insert(particles, self)
end

function Particle:isDead()
    return self.t > self.lifetime;
end

function Particle:draw()
    setColor(self.color)
    love.graphics.circle(self.mode, self.position.x, self.position.y, self.size)
    love.graphics.setColor(1,1,1,1)
end

function Particle:update(dt)
    self.t = self.t + dt
    self.position.x = self.position.x + (self.position.dx * self.speed)
    self.position.y = self.position.y + (self.position.dy * self.speed)
    self.speed = self.speed * self.damp
    self.position.y = self.position.y + self.gravity

    local normalt = clamp(self.t / self.lifetime, 0, 1)
    if normalt > 0.5 then self.mode = "line" end
    self.size = self.sizeOverLifetime[math.ceil(normalt * #self.sizeOverLifetime)] * self.sizeMod
    self.color = self.colorOverLifetime[math.ceil(normalt * #self.colorOverLifetime)]
end

return Particle