Base = require 'libraries.knife.knife.base'

Box = Base:extend()

function Box:constructor(x, y, w, h, c)
    self.position = {x = x, y = y}
    self.size = {width = w, height = h}
    self.color = c
end

function Box:draw()
    setColor(self.color)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.width, self.size.height)
end

return Box