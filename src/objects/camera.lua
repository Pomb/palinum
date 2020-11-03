Base = require 'libraries.knife.knife.base'

Camera = Base:extend()

function Camera:constructor()
    self.x = 0
    self.y = 0
    self.shake = {
        x = 0,
        y = 0,
        duration = 0,
        frequency = 0,
    }
end

function Camera:getCamPosX() return self.x + self.shake.x end
function Camera:getCamPosY() return self.y + self.shake.y end

function Camera:update(dt)
    if self.shake.duration > 0 then
        self.shake.x = math.random(-1, 1) * self.shake.frequency
        self.shake.y = math.random(-1, 1) * self.shake.frequency
        self.shake.duration = self.shake.duration - dt
        self.shake.frequency = self.shake.frequency * self.shake.duration
    else
        self.shake.x = 0
        self.shake.y = 0
    end
end

function Camera:setShake(duration, frequency)
    self.shake.duration = self.shake.duration + duration
    self.shake.frequency = self.shake.frequency + frequency
end

return Camera
