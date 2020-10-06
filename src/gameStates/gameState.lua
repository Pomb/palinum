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
    self.level = 0

    self.blockInput = false

    self.boxes = {}

    self:setUpLevel(1)
end

function GameState:setUpLevel()
    if self.gameboard ~= nil then
        self.gameboard:clear()
    end
    self.gameboard = GameBoard(self.width, self.height, self.offsetX, self.yOffset, self.cellSize, 2 + (self.level * 10), nil,
        function()
            self:levelUp()
        end)
    self.gameboard:setCursorPos(math.ceil(self.width / 2), math.ceil(self.height / 2), self.offsetX, self.offsetY)
    self.gameboard:fillBoard()

    Timer.after(1, function()
        self.blockInput = false
    end)
end

function GameState:levelUp()
    self.blockInput = true
    self.level = self.level + 1

    local box = Box(0, game_height, game_width, 2, 1)
    table.insert(self.boxes, box)
    Timer.tween(2, {
        [box.position] = {y = -200},
        [box.size] = {height = 200}
    }):ease(Curves.inOutQuad)

    Timer.after(1, function()
        self.gameboard:clearBoard()
    end)

    Timer.after(2,
        function()
            table.remove(self.boxes, 1)
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
    
    for _, effect in pairs(self.boxes) do
        effect:draw()
    end

    dropPrint(self.level, 148, 1)
end

function GameState:move(x, y)
    self.gameboard.board:moveCursor(x, y, false)
    if self.gameboard.adding then
        self.gameboard:add()
    end
    self.gameboard.board.cursor.full = self.adding
end

function GameState:confirm()
    self.gameboard.path:clear()
    if self.gameboard.adding then
        self.gameboard.adding = false
    else
        self.gameboard.adding = true
        self.gameboard:add()
    end
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