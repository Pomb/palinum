Base = require 'libraries.knife.knife.base'

Box = Base:extend()

function Box:constructor(x, y, w, h, c, text, textc)
    self.position = {x = x, y = y}
    self.size = {width = w, height = h}
    self.color = c
    self.text = text or ''
    self.textc = textc or 0
end

function Box:draw()
    setColor(self.color)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.width, self.size.height)
    setColor(self.textc)
    love.graphics.print(self.text, 64, self.position.y + (self.size.height / 2) - 4)
    setColor(1)
    love.graphics.setLineWidth(1)
    love.graphics.line(self.position.x, self.position.y + self.size.height, self.position.x + self.size.width, self.position.y + self.size.height)
end

return Box