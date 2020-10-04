Base = require 'libraries.knife.knife.base'
Cell = require 'libraries.doodlehouse.board.cell'
Cursor = require 'libraries.doodlehouse.board.cursor'

Board = Base:extend()

local fromCell
local previousCell
local currentCell

function Board:constructor(width, height, cellsize, ox, oy, padding)
    self.width = width
    self.height = height
    self.grid = {}
    self.cellSize = cellsize or 16
    self.cellPadding = padding or 0
    self.cursor = Cursor(self.cellSize)
    self.xOffset = ox or 0
    self.yOffset = oy or 0
end

function Board:new()
    for y = 1, self.height do
        self.grid[y] = {}
        for x = 1, self.width do
            self.grid[y][x] = Cell(x,y, self.cellSize, self.cellPadding, self.xOffset, self.yOffset)
        end
    end
end

function Board:getActorAtCursor()
    if currentCell then
        return currentCell:getOccupant()
    else
        return nil
    end
end

function Board:setOccupant(actor, x, y)
    local cell = self.grid[y][x]
    assert(cell:getOccupant() == nil, "There is already an occupant here")
    cell:setOccupant(actor)
end

function Board:highlightRangeAt(x, y, range)
    local cell = self.grid[y][x]
end

function Board:draw()
    for y = 1, self.height do
        for x = 1, self.width do
            local cell = self.grid[y][x]
            cell:draw()
        end
    end
end

function Board:cellAtCursor()
    return self:cellAtCoord(self.cursor.x, self.cursor.y);
end

function Board:moveCursor(dx, dy, wrap, blockOccupied)
    if blockOccupied then
        local target = self:cellAtCoord(self.cursor.x + dx, self.cursor.y + dy)
        if not target:isEmpty() then
            return currentCell
        end
    end

    self.cursor:move(dx, dy, self.width, self.height, wrap)
    currentCell = self:cellAtCursor()

    if currentCell ~= nil then
        fromCell = previousCell

        currentCell.highlighted = true
        if currentCell ~= previousCell then
            if previousCell ~= nil then
                previousCell.highlighted = false
            end
            previousCell = currentCell;
        end
    end

    return currentCell
end

function Board:moveCursorBack()
    self.cursor.x = fromCell.x
    self.cursor.y = fromCell.y
    print('move back')
end

function Board:cellAtCoord(x,y)
    if self:inBounds(x,y) then
        return self.grid[y][x]
    else
        error('eh no in bounds!', x, y)
        return nil
    end
end

function Board:drawOccupantInfo()
    for y = 1, self.height do
        for x = 1, self.width do
            local cell = self.grid[y][x]
            cell:drawOccupantInfo()
        end
    end
end

function Board:inBounds(x, y)
    return x > 0 and x <= self.width and y > 0 and y <= self.height
end

function Board:worldToCellCoord(x,y)
    return math.abs(math.floor(x / self.cellSize)), math.abs(math.floor(math.abs(y) / self.cellSize))
end

return Board