Particle = require 'src.objects.particle'

ObstacleParticle = Particle:extend()

function ObstacleParticle:constructor(x, y)
    self.position = {x = x, y = y, dx = 0, dy = 1}
    self.t = 0
    self.lifetime = 3
    self.speed = love.math.random(1, 2)
    self.damp = 1.1
    self.padding = 0.5
    self.gravity = 1
    table.insert(particles, self)
end

function ObstacleParticle:isDead()
    return self.t > self.lifetime;
end

function ObstacleParticle:draw()
    --setColor(0)
    --love.graphics.rectangle("fill", self.position.x + self.padding, self.position.y + self.padding, 16 - (self.padding * 2), 16 - (self.padding * 2))
    setColor(5)
    love.graphics.circle("fill", self.position.x + self.padding + 8, self.position.y + self.padding + 8, 8)
    setColor(0)
    love.graphics.rectangle("fill", self.position.x + self.padding + 5, self.position.y + self.padding + 4, 16 - (self.padding * 2) - 8, 16 - (self.padding * 2) - 8)
    love.graphics.setColor(1,1,1,1)
end

function ObstacleParticle:update(dt)
    self.t = self.t + dt
    self.position.x = self.position.x + (self.position.dx * self.speed)
    self.position.y = self.position.y + (self.position.dy * self.speed)
    self.speed = self.speed * self.damp
    self.position.y = self.position.y + self.gravity
end

return ObstacleParticle