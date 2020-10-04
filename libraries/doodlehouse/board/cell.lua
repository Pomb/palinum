Cell = Base:extend()

function Cell:constructor(x, y, size, padding, xoffset, yoffset)
    -- coordinates not world positions
    self.x = x
    self.y = y
    self.size = size
    self.padding = padding
    self.occupant = nil
    self.highlighted = false
    -- world position
    self.wx = (x * size) + xoffset
    self.wy = (y * size) + yoffset
end

function Cell:draw()

    setColor(1)
    love.graphics.rectangle('line', self.wx, self.wy, self.size - self.padding, self.size - self.padding)

    if self.highlighted then
        setColor(7)
        --love.graphics.rectangle('line', dx + 2, dy + 2, self.size - self.padding - 4, self.size - self.padding - 4)
    end

    setFont(Fonts.caption)
    love.graphics.print(''..self.x..':'..self.y, self.wx + 4, self.wy + 4)
end

function Cell:drawOccupantInfo()
    setColor(7)
    love.graphics.print(tostring(self:hasOccupant()), self.wx + 4, self.wy + 4)
end

function Cell:id()
    if self:isEmpty() then return -1 end
    return self.occupant.id
end

function Cell:setOccupant(oc)
    self.occupant = oc
    if self.occupant ~= nil then
        self.occupant.cell = self
        self.occupant:move(self.wx, self.wy, function()
            self.occupant.position.x = self.wx
            self.occupant.position.y = self.wy
        end)
    end
end

function Cell:isEmpty()
    return self.occupant == nil
end

function Cell:hasOccupant()
    return self.occupant ~= nil
end

function Cell:getOccupant()
    return self.occupant
end

return Cell