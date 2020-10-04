require('utilities.numbers')
Cursor = Base:extend()

function Cursor:constructor(size)
    self.x = 1
    self.y = 1
    self.size = size or 16
    self.cornerSize = 4
    self.color = 7
    self.weight = 1.5
end

function Cursor:draw(color)
    if color then
        setColor(color)
    else
        setColor(self.color)
    end
    love.graphics.setLineWidth(self.weight)
    love.graphics.setLineJoin('miter')

    local s = self.size
    local cs = self.cornerSize
    local x = self.x * s
    local y = self.y * s
    local xs = x + s
    local ys = y + s
    local xc = x + cs
    local yc = y + cs
    -- top left
    love.graphics.line({x, yc, x, y, xc, y})
    -- top right
    love.graphics.line({xs - cs, y, xs, y, xs, yc})
    -- bottom right 
    love.graphics.line({xs - cs, ys, xs, ys, xs, ys - cs})
    -- bottom left
    love.graphics.line({x, ys - cs, x, ys, xc, ys})
    love.graphics.setLineWidth(1)
end

function Cursor:setPos(x, y)
    self.x = x
    self.y = y
end

function Cursor:move(dx, dy, width, height, allowWrap)
    if allowWrap then
        self.x = wrap(self.x + dx, 1, width)
        self.y = wrap(self.y + dy, 1, height)
    else
        self.x = clamp(self.x + dx, 1, width)
        self.y = clamp(self.y + dy, 1, height)
    end
end

return Cursor
