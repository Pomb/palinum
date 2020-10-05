GameBoard = require 'src.game_board'
Block = require 'src.block'
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
    self.dohint = false
    self.step = 1
    self.hintRoutine = nil
    self.gameboard = GameBoard(3, 2, self.ox, self.oy, 16, 10, function()
            self.step = self.step + 1
            self.dohint = false
            self.gameboard.hintPath:clear()
            self.hintRoutine:remove()
        end)

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
end

function HelpState:startHint()
    self.dohint = true
    self.gameboard.hintPath:clear()
    -- set the hint path to the coordinates that match the initial layout
    local coords = {{1,1}, {2,1}, {3,1}, {3,2}, {2,2}, {1,2}}
    local index = 1
    self.hintRoutine = Timer.every(0.2,
        function()
            if index <= #coords then
                self.gameboard.hintPath:add(self.gameboard.board:cellAtCoord(coords[index][1], coords[index][2]))
            end
            index = index + 1
        end):limit(#coords + 1):finish(
            function()
                Timer.after(2,
                function()
                    self.gameboard.hintPath:clear()
                end)
            end):finish(
                function()
                    if self.dohint then
                        self:startHint()
                    end
                end)
end

function HelpState:update(dt)
    self.gameboard:update(dt)
end

function HelpState:draw()
    setColor(1)
    if(self.step == 1) then setColor(7)
    else setColor(1) end
    love.graphics.print("- x to reset path", 10, 10)
    love.graphics.print("-   and toggle add to path", 10, 16)
    if(self.step == 2) then setColor(7)
    else setColor(1) end
    love.graphics.print("- move with the arrow keys", 10, 22)
    setColor(1)
    if(self.step == 3) then setColor(7)
    else setColor(1) end
    love.graphics.print("- create palindroms to score", 10, 28)
    if(self.step == 4) then setColor(7)
    else setColor(1) end
    love.graphics.print("- minimum length of 3", 10, 34)
    if(self.step == 5) then setColor(7)
    else setColor(1) end
    love.graphics.print('palindrom\n\n  "a sequence that is the\n\n     same forwards and backwards"', 10, 48)

    setColor(7)
    love.graphics.printf('z', -16, 128, game_width/scale, 'center')
    love.graphics.printf('back', 0, 128, game_width/scale, 'center')

    self.gameboard:draw()
    self.gameboard:drawCurrentSet(55, (7*16) + 4)
    self.gameboard:drawCapturedSets(7*16, 5*16)
end

function HelpState:move(x, y)
    if self.step == 1 then return end

    if self.step > 1 and self.step < 5 then
        self.step = self.step + 1
    end

    if self.animating then return end
    self.gameboard.board:moveCursor(x, y, false)

    if self.gameboard.adding then
        self.gameboard:add()
    end
    self.gameboard.board.cursor.full = self.gameboard.adding
end

function HelpState:confirm()
    if self.step == 1 and self.dohint == false then
        self:startHint()
        self.step = 2
        self.gameboard:add()
    else
        self.gameboard.path:clear()
        if self.gameboard.adding then
            self.gameboard.adding = false
        else
            self.gameboard.adding = true
            self.gameboard:add()
        end
    end

    self.gameboard.board.cursor.full = self.gameboard.adding
end

function HelpState:mousemoved(x, y, dx, dy)
end

function HelpState:keypressed(key, scancode, isrepeat)
    if key == 'z' then
        changeState('menu')
    end

    if key == 'x' then self:confirm() end
    if key == 'left' then self:move(-1, 0) end
    if key == 'right' then self:move(1, 0) end
    if key == 'down' then self:move(0, 1) end
    if key == 'up' then self:move(0, -1) end
end

return HelpState