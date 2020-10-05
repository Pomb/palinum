Base = require 'libraries.knife.knife.base'
Path = require 'path'
Timer = require 'libraries.knife.knife.timer'
Board = require 'libraries.doodlehouse.board.board'

GameBoard = Base:extend()

function GameBoard:constructor(w, h, ox, oy, cellSize, onPalindrome)
    self.width = w or 5
    self.height = h or 5
    self.cellSize = cellSize or 16
    self.offsetX = ox or 0
    self.offsetY = oy or 0

    self.path = Path(self.cellSize)
    self.hintPath = Path(self.cellSize, 0.8)
    self.palinLength = 3

    self.blocks = {}
    self.plaindromeSets = {}

    self.adding = false
    self.animating = false
    
    self.board = Board(self.width, self.height, self.cellSize, self.offsetX, self.offsetY)
    self.board:new()

    self.onPalindrome = onPalindrome
end

function GameBoard:fillBoard()
    for y = 1, self.height do
        for x = 1, self.width do
            self:addBlock(x,y)
        end
    end
end

function GameBoard:setCursorPos(x, y)
    local cell = self.board:cellAtCoord(x,y)
    self.board.cursor:setPos(cell.x, cell.y)
end

function GameBoard:setHintPath(cellList)

end

function GameBoard:getDropCell(cell)
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

function GameBoard:checkForPalindrome(cellList)
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
        local palindromeSet = {}
        Timer.after(0.1, function ()
            for _, cell in pairs(cellList) do
                if cell:hasOccupant() then
                    cell.occupant.dead = true
                    table.insert(palindromeSet, cell.occupant.id)
                    cell:setOccupant(nil)
                end
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

            if self.onPalindrome ~= nil then
                self.onPalindrome()
            end
        end)

        Timer.after(0.3, function()
            --check the column again and add blocks for the empty cells that remain
            for y = 1, self.height do
                for x = 1, self.width do
                    if self.board:cellAtCoord(x, y):isEmpty() then
                        self:addBlock(x, y)
                    end
                end
            end
        end)

        Timer.after(0.5, function()
            self.animating = false
            self.adding = true
            self:add()
        end)

    else
        self.animating = false
    end
end

function GameBoard:setBlock(x, y, block)
    local targetCell = self.board.grid[y][x]
    block.position.x = targetCell.wx
    block.position.y = targetCell.wy - (x * 10) - (y * 10) + 10
    self.board.grid[y][x]:setOccupant(block)
    table.insert(self.blocks, block)
end

function GameBoard:addBlock(x, y)
    --local ids = {8, 12, 11, 13, 10, 5}
    local ids = {8, 12, 11}
    local block = Block(randomKey(ids), Timer)
    local targetCell = self.board.grid[y][x]
    block.position.x = targetCell.wx
    block.position.y = targetCell.wy - (x * 10) - (y * 10) + 10
    self.board.grid[y][x]:setOccupant(block)
    table.insert(self.blocks, block)
end

function GameBoard:draw()
    self.board:draw()
    
    --clip block drawing to the board
    love.graphics.setScissor(
        (self.offsetX + self.cellSize) * scale,
        (self.offsetY + self.cellSize) * scale,
        (self.width * self.cellSize) * scale,
        (self.height * self.cellSize) * scale
    )
    for _, block in pairs(self.blocks) do
        block:draw()
    end
    love.graphics.setScissor()

    
    if self.animating then
        setColor(7)
    else 
        setColor(1)
    end
    -- border
    love.graphics.rectangle(
        'line',
        self.offsetX + self.cellSize,
        self.offsetY + self.cellSize,
        self.width * self.cellSize,
        self.height * self.cellSize
    )
    --self.board:drawOccupantInfo()
     -- cursor
     if not self.animating then
        self.board.cursor:draw()
    end

    self:drawPath()
end

function GameBoard:drawCapturedSets(offsetX, offsetY)
    local cSize = 1
    local startX = offsetX or (self.width * 16) + self.offsetX + self.cellSize + 4
    local startY = offsetY or self.cellSize - 1
    for i, plaindrome in pairs(self.plaindromeSets) do
        local x = startX
        local y = startY + (i * cSize)
        for j, id in pairs(plaindrome) do
            setColor(id)
            love.graphics.rectangle("fill", x + j, y, cSize, cSize)
        end
    end

end

function GameBoard:drawPath()
    self.path:draw()
    self.hintPath:draw()
end

function GameBoard:drawCurrentSet(ox, oy)
    local previewSize = 8
    local startX = ox or 16
    local startY = oy or ((self.height + 1) * self.cellSize) + 2
    local padding = 1
    local wraplen = 15
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

function GameBoard:dropToEmptys(cellList)

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

function GameBoard:clear()
    self.path:clear()
end

function GameBoard:clearBoard()
    self.board:clear()
    self.path:clear()
    self.blocks = {}
    self.palindromeSets = {}
end

function GameBoard:add()
    self.adding = true
    self.path:add(self.board:cellAtCursor());
    self:checkForPalindrome(self.path.cells)
end

function GameBoard:addBlock(x, y)
    --local ids = {8, 12, 11, 13, 10, 5}
    local ids = {8, 12, 11}
    local block = Block(randomKey(ids), Timer)
    local targetCell = self.board.grid[y][x]
    block.position.x = targetCell.wx
    block.position.y = targetCell.wy - (x * 20) - (y * 20) + 10
    self.board.grid[y][x]:setOccupant(block)
    table.insert(self.blocks, block)
end

function GameBoard:update(dt)
    Timer.update(dt)
end


return GameBoard