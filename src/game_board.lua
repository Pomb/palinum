Path = require 'src.objects.path'
Particle = require 'src.objects.particle'
Base = require 'libraries.knife.knife.base'
Timer = require 'libraries.knife.knife.timer'
Board = require 'libraries.doodlehouse.board.board'

GameBoard = Base:extend()

function GameBoard:constructor(w, h, ox, oy, cellSize, levelCount, onPalindrome, onComplete, ids)
    self.maxWidth = w or 5
    self.maxHeight = h or 5
    self.cellSize = cellSize or 16
    self.halfCell = self.cellSize / 2
    self.offsetX = ox or 0
    self.offsetY = oy or 0
    self.levelCount = levelCount or 10
    self.count = 0
    self.ids = ids or {8, 12, 11, 10}
    --local ids = ids or {8, 12, 11, 13, 10, 5}

    self.path = Path(self.cellSize)
    self.hintPath = Path(self.cellSize, 0.5)
    self.minPalindromeLength = 3

    self.blocks = {}
    self.plaindromeSets = {}

    self.adding = false
    self.animating = false
    
    self.board = Board(self.maxWidth, self.maxHeight, self.cellSize, self.offsetX, self.offsetY)
    self.board:new()

    -- TODO: change these to use knife events
    self.onPalindrome = onPalindrome or doNothing
    self.onComplete = onComplete or doNothing
end

function doNothing()
end

function GameBoard:fillBoard()
    self.animating = true
    for y = 1, self.maxHeight do
        for x = 1, self.maxWidth do
            self:addBlock(x,y)
        end
    end
    Timer.after(0.5, function()
        self.animating = false
    end)
end

function GameBoard:toggleAdding()
    self.adding = not self.adding
    self.board.cursor.full = self.adding
    if self.adding then
        self:add()
    end
end

function GameBoard:setAdding(value)
    self.adding = value
    self.board.cursor.full = self.adding
    if self.adding then
        self:add()
    end
end

function GameBoard:setCursorPos(x, y)
    local cell = self.board:cellAtCoord(x,y)
    self.board.cursor:setPos(cell.x, cell.y)
end

function GameBoard:moveCursor(dx, dy)
    self.board:moveCursor(dx, dy)
    if self.adding then
        self:add()
    end
end

function GameBoard:getDropCell(cell)
    local targetY = cell.y
    for i = cell.y, self.maxHeight do
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
    if #cellList < self.minPalindromeLength then return end
    self.animating = true

    local length = #cellList
    local revList = clone(cellList)
    revList = reverse(revList)

    local hasPalindrome = true
    for i = 1, length do
        if cellList[i]:id() ~= revList[i]:id() then
            hasPalindrome = false
            break
        end
    end

    if hasPalindrome then
        local palindromeSet = {}
        Timer.after(0.1, function ()
            for _, cell in pairs(cellList) do
                if cell:hasOccupant() then
                    cell.occupant.dead = true
                    table.insert(palindromeSet, cell.occupant.id)
                    cell:setOccupant(nil)
                end
            end
            
            self.count = self.count + #palindromeSet
            
            table.insert(self.plaindromeSets, palindromeSet)
            
            for i = #self.blocks, 1, -1 do
                if self.blocks[i].dead then
                    makeParticles(self.blocks[i].position.x + self.halfCell, self.blocks[i].position.y + self.halfCell, self.blocks[i].id)
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
            for y = 1, self.maxHeight do
                for x = 1, self.maxWidth do
                    if self.board:cellAtCoord(x, y):isEmpty() then
                        self:addBlock(x, y)
                    end
                end
            end
        end)

        Timer.after(0.5, function()
            -- normalize value for the maximum length to shake
            local durationT = (math.min(#palindromeSet - self.minPalindromeLength, 8) / 8)
            local frequencyT = (math.min(#palindromeSet - self.minPalindromeLength, 10) / 10)
            -- map the t value to a duration, between 0.3, and 1.5
            -- where a palindrome of 3 shakes for 0 and 8 shakes for 1.5
            local duration = lerp(0, 1.5, durationT)
            local frequency = lerp(0.3, 2, frequencyT)
            shake(duration, frequency)
            self.adding = true
            self:add()
        end)

    else
        self.animating = false
    end
    Timer.after(1.5, function()
        self.animating = false
        if hasPalindrome and self.count >= self.levelCount then
            self.onComplete()
        end
    end)
end

function GameBoard:setBlock(x, y, block)
    local targetCell = self.board.grid[y][x]
    block.position.x = targetCell.wx
    block.position.y = targetCell.wy - (x * 10) - ((y + 16) * self.maxHeight)
    self.board.grid[y][x]:setOccupant(block)
    table.insert(self.blocks, block)
end

function GameBoard:addBlock(x, y)
    local block = Block(randomKey(self.ids), Timer)
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
        (self.offsetX + self.cellSize),
        (self.offsetY + self.cellSize),
        (self.maxWidth * self.cellSize),
        (self.maxHeight * self.cellSize)
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
        self.maxWidth * self.cellSize,
        self.maxHeight * self.cellSize
    )
    --self.board:drawOccupantInfo()
    -- cursor
    if not self.animating then
        self.board.cursor:draw()
    end

    self:drawPath()
end

function GameBoard:drawCapturedSets(offsetX, offsetY)
    local cSize = 2
    local startX = offsetX or (self.maxWidth * self.cellSize) + self.offsetX + self.cellSize + 4
    local startY = offsetY or self.cellSize + self.offsetY
    for i, plaindrome in pairs(self.plaindromeSets) do
        local x = startX
        local y = startY + (i * cSize)
        for j, id in pairs(plaindrome) do
            setColor(id)
            love.graphics.rectangle("fill", x + (j * cSize), y, cSize, cSize)
        end
    end

end

function GameBoard:drawPath()
    self.path:draw()
    self.hintPath:draw()
end

function GameBoard:drawCurrentSet(ox, oy)
    local previewSize = 8
    local startX = ox or self.offsetX + self.cellSize
    local startY = oy or self.offsetY + ((self.maxHeight + 1) * self.cellSize) + 2
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
    local minX = self.maxWidth
    local maxX = 1

    for _, cell in pairs(cellList) do
        if(cell.x < minX) then minX = cell.x end
        if(cell.x > maxX) then maxX = cell.x end
    end

    for y = self.maxHeight, 2, -1 do
        for x = minX, maxX do
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

function GameBoard:update(dt)
    Timer.update(dt)
end


return GameBoard