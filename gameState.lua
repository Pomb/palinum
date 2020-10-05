Board = require 'libraries.doodlehouse.board.board'
Path = require 'path'
Timer = require 'libraries.knife.knife.timer'
Block = require 'block'
require 'utilities.tables'

GameState = {}

meta = {
    __call = function()
        return GameState;
    end
}

setmetatable(GameState, meta)

function GameState:init()
    self.name = 'game'
    self.width = 6
    self.height = 6
    self.offsetX = 0
    self.offsetY = 0
    self.cellSize = 16
    self.board = Board(self.width, self.height, self.cellSize, self.offsetX, self.offsetY);
    self.path = Path(self.cellSize)
    self.palinLength = 3

    self.board:new()
    self.board.cursor:setPos(3, 3)

    self.blocks = {}
    self.plaindromeSets = {}

    self:fillBoard()
    self.adding = false

    self.animating = false
end

function GameState:fillBoard()
    for y = 1, self.height do
        for x = 1, self.width do
            self:addBlock(x,y)
        end
    end
end

function GameState:getDropCell(cell)
    local targetY = cell.y
    for i = cell.y, self.height do
        local y = i
        if self.board:inBounds(cell.x, y) then
            local pt = self.board:cellAtCoord(cell.x, y)
            if pt.occupant == nil then
                targetY = y
            end
        else
            targetY = cell.y
            break
        end
    end
    if targetY == nil then
        return cell
    end
    return self.board:cellAtCoord(cell.x, targetY)
end

function GameState:dropToEmptys(cellList)

    -- bottom to the top of the column
    --for i = 1, #complete do
    local minX = self.width
    local maxX = 1

    for _, cell in pairs(cellList) do
        if(cell.x < minX) then minX = cell.x end
        if(cell.x > maxX) then maxX = cell.x end
    end

    for y = self.height, 2, -1 do
        for x = minX, maxX do
            -- replace block with block above
            local fromCell = self.board:cellAtCoord(x, y - 1)
            local toCell = self:getDropCell(fromCell)
            if fromCell:hasOccupant() then
                if fromCell ~= toCell then
                    toCell:setOccupant(fromCell.occupant)
                    fromCell.occupant = nil
                end
            end
        end
    end
end

function GameState:checkForPalindrome(cellList)
    if #cellList < self.palinLength then return end
    self.animating = true

    local length = #cellList
    local revList = clone(cellList)
    revList = reverse(revList)

    local result = true
    for i = 1, length do
        if cellList[i]:id() ~= revList[i]:id() then
            result = false
            break
        end
    end

    -- make this an animation instead of instant
    if result then
        print("eh palindrome!")
        local palindromeSet = {}
        Timer.after(0.1, function ()
            for _, cell in pairs(cellList) do
                if cell:hasOccupant() then
                    cell.occupant.dead = true
                    table.insert(palindromeSet, cell.occupant.id)
                end
                cell:setOccupant(nil)
            end
            
            table.insert(self.plaindromeSets, palindromeSet)

            for i = #self.blocks, 1, -1 do
                if self.blocks[i].dead then
                    table.remove(self.blocks, i)
                end
            end
            self.path:clear()
        end)

        Timer.after(0.2, function ()
            self:dropToEmptys(cellList);
        end)

        Timer.after(0.3, function()
            --check the column again and add blocks for the empty cells that remain
            for y = 1, self.height do
                for x = 1, self.width do
                    if self.board:cellAtCoord(x,y):isEmpty() then
                        self:addBlock(x, y)
                    end
                end
            end
        end)

        Timer.after(0.5, function()
            self.animating = false
            self.path:add(self.board:cellAtCursor())
            self.adding = true
        end)

    else
        self.animating = false
    end
end

function GameState:addBlock(x, y)
    --local ids = {8, 12, 11, 13, 10, 5}
    local ids = {8, 12, 11}
    local block = Block(randomKey(ids), Timer)
    local targetCell = self.board.grid[y][x]
    block.position.x = targetCell.wx
    block.position.y = targetCell.wy - (x * 10) - (y * 10) + 10
    self.board.grid[y][x]:setOccupant(block)
    table.insert(self.blocks, block)
end

function GameState:update(dt)
    Timer.update(dt)
end

-- function GameState:mousemoved(x, y, dx, dy)
--     self.hoveredCell = self:cellFromWorld(x, y)
--     --self:cellFromWorld(x,y);
-- end

function GameState:draw()
    self.board:draw()
    
    if not self.animating then
        self.board.cursor:draw()
    end
    
    love.graphics.setScissor(
        (self.offsetX + self.cellSize - 1) * scale,
        (self.offsetY + self.cellSize - 1) * scale,
        (self.width * self.cellSize + 2) * scale,
        (self.height * self.cellSize + 2) * scale
    )

    for _, block in pairs(self.blocks) do
        block:draw()
    end



    setColor(7)
    -- border
    love.graphics.rectangle(
        'line',
        self.offsetX + self.cellSize - 2,
        self.offsetY + self.cellSize - 2,
        self.width * self.cellSize + 4,
        self.height * self.cellSize + 4
    )
    
    --self.board:drawOccupantInfo()
    
    self:drawCurrentSet()
    self:drawCapturedSets()
    self.path:draw()
end

function GameState:drawCapturedSets()
    local cSize = 1
    local startX = (self.width * 16) + self.offsetX + self.cellSize + 4
    local startY = self.cellSize - 1
    for i, plaindrome in pairs(self.plaindromeSets) do
        local x = startX
        local y = startY + (i * cSize)
        for j, id in pairs(plaindrome) do
            setColor(id)
            love.graphics.rectangle("fill", x + j, y, cSize, cSize)
        end
    end

end

function GameState:drawCurrentSet()
    local previewSize = 8
    local startX = 8
    local startY = ((self.height + 1) * self.cellSize) + 4
    local padding = 1
    local wraplen = 16
    for i, cell in pairs(self.path.cells) do
        local wy =  (math.floor((i - 1) / wraplen))
        local wx = (math.floor((i - 1) % wraplen));
        local pad = math.floor(((i - 1) * padding) % (wraplen * padding))
        local y = startY + (wy * (previewSize + padding))
        local x = startX + (wx * previewSize) + pad;
        local o = cell:getOccupant()
        setColor(1)
        if o ~= nil then
            setColor(o.id)
        end
        love.graphics.rectangle("fill", x, y, previewSize, previewSize)
    end
end

function GameState:cellFromWorld(x, y)
    x = x - self.offsetX
    y = y - self.offsetY
    self.snappedX = math.floor((x / 16) / scale)
    self.snappedY = math.floor((y / 16) / scale)
    self.snappedX = clamp(self.snappedX, 1, self.width);
    self.snappedY = clamp(self.snappedY, 1, self.height);
    print(self.snappedX, self.snappedY);

    return self.board[self.snappedY][self.snappedX] or nil
end

function GameState:inbounds(x, y)
    return x > 0 and x <= self.width and y > 0 and y <= self.height
end

function GameState:move(x, y)
    if self.animating then return end
    self.board:moveCursor(x, y, false)
    if self.adding then
        self.path:add(self.board:cellAtCursor());
        self:checkForPalindrome(self.path.cells)
    end
end

function GameState:confirm()
    self.path:clear()
    if self.adding then
        self.adding = false
    else
        self.adding = true
        self.path:add(self.board:cellAtCursor())
    end

    self.board.cursor.full = self.adding
end

function GameState:keypressed(key, scancode, isrepeat)
    if key == 'q' then
        changeState('menu')
    end

    if key == 'left' then self:move(-1, 0) end
    if key == 'right' then self:move(1, 0) end
    if key == 'down' then self:move(0, 1) end
    if key == 'up' then self:move(0, -1) end
    if key == 'x' then self:confirm() end
end

return GameState