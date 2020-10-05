GameBoard = require 'game_board'
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
    self.gameboard = GameBoard(self.width, self.height, self.offsetX, self.yOffset, self.cellSize)
    self.gameboard:setCursorPos(math.ceil(self.width / 2), math.ceil(self.height / 2), self.offsetX, self.offsetY)
    self.gameboard:fillBoard()
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
end

function GameState:move(x, y)
    if self.animating then return end
    self.gameboard.board:moveCursor(x, y, false)
    if self.adding then
        self.gameboard:add()
    end
    self.gameboard.board.cursor.full = self.adding
end

function GameState:confirm()
    self.gameboard.path:clear()
    if self.adding then
        self.adding = false
    else
        self.adding = true
        self.gameboard:add()
    end
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