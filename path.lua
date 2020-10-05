require('utilities.tables')
require('utilities.shapes')
require('utilities.numbers')

Path = Base:extend()

function Path:constructor(cellSize, alpha)
    self.cellSize = cellSize or 16
    self.offsetX = self.cellSize / 2
    self.offsetY = self.cellSize / 2
    self.alpha = alpha or 1

    self.color = 7
    self.dropColor = 0

    -- list of cells
    self.cells = {}
    self.line = {}
end

function Path:add(cell)
    if cell == nil then return end
    local index = -1
    -- detect if the same coord is in the waypoint
    for i, waypoint in pairs(self.cells) do
        if waypoint ~= nil then
            if waypoint.x == cell.x and waypoint.y == cell.y then
                index = i
                break
            end
        end
    end
    -- if it is delete the rest of the path to end at that point
    if index ~= -1 then
        for i = #self.cells, index, -1 do
            table.remove(self.cells, i)
        end
    end
    table.insert(self.cells, cell)
    self:updateLine()
end

function Path:length()
    return #self.cells
end

function Path:clear()
    self.cells = {}
    self.line = {}
end

function Path:pop()
    local waypoint = self.cells[1]
    table.remove(self.cells, 1)
    --self:updateLine()
    return waypoint
end

function Path:popLine()
    table.remove(self.line, 1)
    table.remove(self.line, 1)
end

function Path:reverse()
    local nw = {}
    for key, waypoint in pairs(self.cells) do
        table.insert(nw, waypoint)
    end
    self.cells = nw
end

function Path:getTargetCell()
    return self.cells[#self.cells]
end

function Path:updateLine()
    self.line = {}

    for _, wayPoint in pairs(self.cells) do
        local x = (wayPoint.wx) + self.offsetX
        local y = (wayPoint.wy) + self.offsetY
        table.insert(self.line, x)
        table.insert(self.line, y)
    end

    --PrintTable(self.line)
end

function Path:draw()
    love.graphics.setLineWidth(4)
    if #self.line > 2 then
        local prevwp = self.cells[#self.cells - 1]
        local lastwp = self.cells[#self.cells]
        local ax = lastwp.wx + self.offsetX
        local ay = lastwp.wy + self.offsetY
        local cardDir = cardinalDirection(prevwp.x, prevwp.y, lastwp.x, lastwp.y)
        local verts = triangleVerts(cardDir, ax, ay, 4, 3)
        if self.alpha == 1 then
            setColor(self.dropColor) -- drop shadow
            love.graphics.line(self.line)
            love.graphics.polygon("fill", verts)
        end
        
        setColor(self.color, self.alpha) -- normal
        love.graphics.push()
        love.graphics.translate(0, -1)
        love.graphics.line(self.line)
        love.graphics.polygon("fill", verts)
        love.graphics.pop()
    end
    love.graphics.setLineWidth(1)
end

return Path;