Timer = require 'libraries.knife.knife.timer'
GameBoard = require 'src.game_board'
Block = require 'src.objects.block'
Box = require 'src.objects.box'
require 'src.utilities.tables'

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
    self.gameboard = nil
    self.level = 1

    self.blockInput = false
    self.boxes = {}

    self.levelIdSets = {
        {8, 12},
        {8, 12, 11},
        {8, 12, 11, 10},
        {8, 12, 11, 10},
        {8, 12, 11, 10, 13},
    }

    self:setUpLevel()
end

function GameState:setUpLevel()
    self.blockInput = true
    local wasAdding = false
    local xPos = math.ceil(self.width / 2)
    local yPos = math.ceil(self.height / 2)
    if self.gameboard ~= nil then
        wasAdding = self.gameboard.adding
        xPos = self.gameboard.board.cursor.x
        yPos = self.gameboard.board.cursor.y
        self.gameboard:clearBoard()
    end
    self.gameboard = GameBoard(self.width, self.height, self.offsetX, self.yOffset, self.cellSize, self:nextLevelCount(), nil,
            function()
                self:levelUp()
            end,
            self:setForLevel()
        )
    self.gameboard:setCursorPos(xPos, yPos, self.offsetX, self.offsetY)
    self.gameboard:fillBoard()
    self.gameboard:setAdding(wasAdding)

    Timer.after(1, function()
        self.blockInput = false
    end)
end

function GameState:setForLevel()
    local index = clamp(self.level, 1, #self.levelIdSets)
    return self.levelIdSets[index]
end

function GameState:nextLevelCount()
    return 10 + math.ceil((self.level * 100) * 0.1);
end

function GameState:levelUp()
    self.blockInput = true
    self.level = self.level + 1

    local box = Box(0, game_height, game_width, 30, 7, 'level '..self.level)
    table.insert(self.boxes, box)
    Timer.tween(1, {
        [box.position] = {y = 50},
        [box.size] = {height = 20}
    }):ease(Curves.outQuart)

    Timer.after(2, function()
        Timer.tween(1, {
            [box.position] = {y = -10},
            [box.size] = {height = 0}
        }):ease(Curves.inQuart)
    end)

    Timer.after(2, function() 
        self.gameboard:clearBoard()
    end)

    Timer.after(4, function() 
        table.remove(self.boxes, 1)
    end)

    Timer.after(3.5,
        function()
            self:setUpLevel()
        end
    )
end


function GameState:update(dt)
    Timer.update(dt)
    self.gameboard:update(dt)
end

-- function GameState:mousemoved(x, y, dx, dy)
--     self.hoveredCell = self:cellFromWorld(x, y)
--     --self:cellFromWorld(x,y);
-- end

function GameState:draw()
    self.gameboard:draw()
    self.gameboard:drawCurrentSet()
    self.gameboard:drawCapturedSets()

    dropPrint(self.level, 148, 1)
    dropPrint(self.gameboard.count..'/'..self.gameboard.levelCount, 55, 1)

    for _, box in pairs(self.boxes) do
        box:draw()
    end
end

function GameState:move(x, y)
    self.gameboard:moveCursor(x, y)
end

function GameState:confirm()
    self.gameboard.path:clear()
    self.gameboard:toggleAdding()
end

function GameState:keypressed(key, scancode, isrepeat)
    if key == 'z' then
        changeState('menu')
    end
    
    if self.blockInput or self.gameboard.animating then return end
    if key == 'left' then self:move(-1, 0) end
    if key == 'right' then self:move(1, 0) end
    if key == 'down' then self:move(0, 1) end
    if key == 'up' then self:move(0, -1) end
    if key == 'x' then self:confirm() end
end

return GameState