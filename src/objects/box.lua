Base = require 'libraries.knife.knife.base'

Box = Base:extend()

function Box:constructor(text, x, y, w, h, textColor, c, dropColor)
    self.position = {x = x, y = y}
    self.size = {width = w, height = h}
    self.color = c
    self.text = text or ''
    self.textColor = textColor or 0
    self.dropColor = dropColor or 1
end

function Box:draw()
    setColor(self.color)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.width, self.size.height)
    setColor(self.textColor)
    setFont(Fonts.subtitle)
    love.graphics.print(self.text, 50, self.position.y + (self.size.height / 2) - 6)
    setFont(Fonts.caption)
    setColor(self.dropColor)
    love.graphics.setLineWidth(1)
    love.graphics.line(self.position.x, self.position.y + self.size.height, self.position.x + self.size.width, self.position.y + self.size.height)
end

return Box