GameBoard = require 'game_board'
Block = require 'block'
Timer = require 'libraries.knife.knife.timer'

HelpState = {}

meta = {
    __call = function()
        return HelpState;
    end
}

setmetatable(HelpState, meta)

function HelpState:init()
    self.name = 'help'
    self.ox = 40
    self.oy = 4*16
    self.gameboard = GameBoard(3, 2, self.ox, self.oy)
    self:refresh()
end

function HelpState:refresh()
    self.gameboard:clearBoard()
    self.gameboard:setCursorPos(1, 1)

    -- initial board guarntee match
    self.ids = {8, 12, 11, 8, 12, 11}
    local index = 1;
    for yy = 1, 2 do
        for xx = 1, 3 do
            local b = Block(self.ids[index], Timer)
            self.gameboard:setBlock(xx, yy, b)
            index = index + 1
        end
    end
    -- set the hint path to the coordinates that match the initial layout
    local coords = {{1,1}, {2,1}, {3,1}, {3,2}, {2,2}, {1,2}}
    local index = 1
    Timer.every(0.2, function()
        self.gameboard.hintPath:add(self.gameboard.board:cellAtCoord(coords[index][1], coords[index][2]))
        index = index + 1
    end):limit(#coords):finish(
        function()
            Timer.after(1, function() 
                self.gameboard.hintPath:clear()
            end)
        end)

    self.gameboard:add()
end

function HelpState:update(dt)
    self.gameboard:update(dt)
end

function HelpState:draw()
    setColor(1)
    love.graphics.print("- move with the arrow keys", 10, 10)
    love.graphics.print("- x to reset path", 10, 16)
    love.graphics.print("-   and toggle add to path", 10, 22)
    love.graphics.print("- create palindroms to score", 10, 28)
    love.graphics.print("- minimum length of 3", 10, 34)
    love.graphics.print('palindrom\n\n  "a sequence that is the\n\n     same forwards and backwards"', 10, 48)

    setColor(7)
    love.graphics.printf('q', -16, 128, game_width/scale, 'center')
    love.graphics.printf('back', 0, 128, game_width/scale, 'center')

    self.gameboard:draw()
    self.gameboard:drawCurrentSet(55, (7*16) + 4)
end

function HelpState:move(x, y)
    self.gameboard.hintPath:clear()

    if self.animating then return end
    self.gameboard.board:moveCursor(x, y, false)
    if self.adding then
        self.gameboard:add()
    end
    self.gameboard.board.cursor.full = self.adding
end

function HelpState:confirm()
    self.gameboard.path:clear()
    if self.adding then
        self.adding = false
    else
        self.adding = true
        self.gameboard:add()
    end
end

function HelpState:mousemoved(x, y, dx, dy)
end

function HelpState:keypressed(key, scancode, isrepeat)
    if key == 'q' then
        changeState('menu')
    end

    if key == 'x' then self:confirm() end
    if key == 'left' then self:move(-1, 0) end
    if key == 'right' then self:move(1, 0) end
    if key == 'down' then self:move(0, 1) end
    if key == 'up' then self:move(0, -1) end
end

return HelpState