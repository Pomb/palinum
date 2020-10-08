Path = require 'src.objects.path'
Particle = require 'src.objects.particle'
ObstacleParticle = require 'src.objects.obstacleParticle'
Base = require 'libraries.knife.knife.base'
Timer = require 'libraries.knife.knife.timer'
Board = require 'libraries.doodlehouse.board.board'
Chain = require 'libraries.knife.knife.chain'

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
    self.badBlockindex = 25
    self.blocksSpawned = 0
    self.borderCol = 1
    self.borderColors = {1, 8, 7, 0, 10, 12, 13, 11}

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

    self.borderRoutine = nil
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
    local c = self.board:cellAtCursor();
    local tc = self.board:cellAtCoord(c.x + dx, c.y + dy)
    if tc ~= nil then
        if tc:hasOccupant() then
            self.board:moveCursor(dx, dy)
            if self.adding then
                self:add()
            end
        end
    else
        print('target cell is out of bounds')
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
        local unmatchableCount = 0

        Chain(
            function(go)
                Timer.after(0.3, go)
                for _, cell in pairs(cellList) do
                    if cell:hasOccupant() then
                        table.insert(palindromeSet, cell.occupant.id)
                        cell.occupant.dead = true
                    end
                end
                local colors = mergeTable(palindromeSet, {7, 0})
                self.borderRoutine = Timer.every(0.2, function()
                    self.borderCol = randomKey(colors)
                end)
            end,
            function(go)
                -- the path
                for _, cell in pairs(cellList) do
                    if cell:hasOccupant() then
                        makeParticles(cell.wx + self.halfCell, cell.wy + self.halfCell, cell.occupant.id)
                        cell:setOccupant(nil)
                    end
                end

                self.count = self.count + #palindromeSet
                table.insert(self.plaindromeSets, palindromeSet)
                self:removeDeadBlocks()
                self.path:clear()
                Timer.after(0.3, go)
            end,
            function(go)
                -- the initial palindrome drop
                self:dropToEmptys();
                if self.onPalindrome ~= nil then
                    self.onPalindrome()
                end
                Timer.after(0.8, go)
            end,
            function(go)
                self.borderCol = 1
                self.borderRoutine:remove()
                Timer.after(0.2, go)
            end,
            function(go)
                -- TODO: repeat the unmatch cascade until no more blocks can fall
                -- the unmatchable cascade
                for x = 1, self.maxWidth do
                    local cell = self.board:cellAtCoord(x, self.maxHeight)
                    if cell:hasOccupant() and cell.occupant.matchable == false then
                        ObstacleParticle(cell.wx, cell.wy)
                        cell.occupant.dead = true
                        cell:setOccupant(nil)
                        unmatchableCount = unmatchableCount + 1
                    end
                end
                Timer.after(0.1, function()
                    if(unmatchableCount > 0) then
                        self:removeDeadBlocks()
                        self:dropToEmptys();
                        Timer.after(1, go)
                    else
                        Timer.after(0.1, go)
                    end
                end)
            end,
            function(go)
                -- refresh empties
                for y = 1, self.maxHeight do
                    for x = 1, self.maxWidth do
                        if self.board:cellAtCoord(x, y):isEmpty() then
                            self:addBlock(x, y)
                        end
                    end
                end
                Timer.after(0.5, go)
            end,
            function(go)
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
                Timer.after(0.3, go)
            end,
            function (go)
                -- clean up
                self.animating = false
                if hasPalindrome and self.count >= self.levelCount then
                    self.onComplete()
                end
            end
        )()
    else
        self.animating = false
    end
end

function GameBoard:removeDeadBlocks()
    for i = #self.blocks, 1, -1 do
        if self.blocks[i].dead then
            table.remove(self.blocks, i)
        end
    end
end

function GameBoard:setBlock(x, y, block)
    local targetCell = self.board.grid[y][x]
    block.position.x = targetCell.wx
    block.position.y = targetCell.wy - (x * 10) - ((y + 16) * self.maxHeight)
    self.board.grid[y][x]:setOccupant(block)
    table.insert(self.blocks, block)
end

function GameBoard:addBlock(x, y)
    local block = Block(randomKey(self.ids), Timer, true)
    if ((self.blocksSpawned + 1) % self.badBlockindex) == 0 then
        block = Block(10, Timer, false)
    end
    local targetCell = self.board.grid[y][x]
    block.position.x = targetCell.wx
    block.position.y = targetCell.wy - (x * 10) - (y * 10) + 10
    self.board.grid[y][x]:setOccupant(block)
    table.insert(self.blocks, block)
    self.blocksSpawned = self.blocksSpawned + 1
end

function GameBoard:draw()
    self.board:draw()

    --clip blocks drawing to inside the board
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


    
    -- border
    setColor(self.borderCol)
    love.graphics.rectangle(
        'line',
        self.offsetX + self.cellSize,
        self.offsetY + self.cellSize,
        self.maxWidth * self.cellSize,
        self.maxHeight * self.cellSize
    )

    -- cursor
    if not self.animating then
        self.board.cursor:draw()
    end

    self:drawPath()
end

function GameBoard:drawCapturedSets(offsetX, offsetY)
    local cSize = 1
    local startX = offsetX or (self.maxWidth * self.cellSize) + self.offsetX + self.cellSize + 4
    local startY = offsetY or self.cellSize + self.offsetY
    for i, plaindrome in pairs(self.plaindromeSets) do
        local x = startX
        local y = startY + (i * cSize) + 0.5
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

function GameBoard:dropToEmptys()
    local minX = 1
    local maxX = self.maxWidth

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
    local cell = self.board:cellAtCursor()
    if(cell:hasOccupant() and cell.occupant.matchable) then
        self.path:add(cell);
        self:checkForPalindrome(self.path.cells)
        self.adding = true
    else
        self.adding = false
        self.board.cursor.full = false
        self:clear();
    end
end

function GameBoard:update(dt)
    Timer.update(dt)
end


return GameBoard