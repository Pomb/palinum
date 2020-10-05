Curves = require 'libraries.easing.lib.easing'
Base = require 'libraries.knife.knife.base'

Block = Base:extend()

function Block:constructor(id, timer)
    self.id = id
    self.timer = timer
    self.position = {x = 0, y = 0}
    self.moveSpeed = 1.0
    self.padding = 0.5
    self.dead = false
    self.cell = nil
end

function Block:move(x, y, onComplete)
    self.timer.tween(self.moveSpeed, {[self.position] = {x = x, y = y}}):ease(Curves.outBounce):finish(
        function()
            onComplete()
        end
    )
end

function Block:draw()
    setColor(self.id)
    love.graphics.rectangle("fill", self.position.x + self.padding, self.position.y + self.padding, 16 - (self.padding * 2), 16 - (self.padding * 2))
end

return Block