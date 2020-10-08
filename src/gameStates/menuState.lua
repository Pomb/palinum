Timer = require 'libraries.knife.knife.timer'

MenuState = {}

meta = {
    __call = function()
        return MenuState;
    end
}

setmetatable(MenuState, meta)

function MenuState:init()
    self.name = 'menu'
    self.selected = 0
    self.letterColors = {1, 8, 12, 11, 10, 13}
    self.logoLetters = {"P","A","L","I","N","D","R","O","M","E"}
    self.col = 1
    self.offsets = {}
    for i = 1, #self.logoLetters do
        table.insert(self.offsets, i)
    end
    self.speed = 30
    self.amplitude = 1
    self.btns = {
        {--1
            'play',--1
            function()--2
                changeState('game')
            end,
        },
        {--2
            'help', --1
            function()--2
                changeState('help')
            end
        },
        {--2
            'quit', --1
            function()--2
                love.event.quit()
            end
        }
    }

    Timer.every(0.5, function()
        self.col = randomKey(self.letterColors)
    end)
end

function MenuState:update(dt)
    Timer.update(dt)

    for i = 1, #self.logoLetters do
        self.offsets[i] = math.sin((i * -20) + love.timer.getTime() * self.speed) * self.amplitude
    end
end

function MenuState:draw()
    for i, value in pairs(self.btns) do
        if i == self.selected + 1 then
            setColor(7)
            love.graphics.printf('X', -12, 50 + (i * 8), game_width/4, 'center');
        else
            setColor(1)
        end
        love.graphics.printf(string.upper(value[1]), 0, 50 + (i * 8), game_width/4, 'center')
    end

    for i = 1, #self.logoLetters do
        local letter = self.logoLetters[i]
        local offset = self.offsets[i]
        if(offset > 0.9) then
            setColor(7)
        else
            setColor(self.col)
        end
        setFont(Fonts.body)
        love.graphics.print(letter, 10 + (i * Fonts.body:getWidth(letter)), 30)
    end
end

function MenuState:moveSelect(dir)
    self.selected = (self.selected + dir) % (#self.btns)
end

function MenuState:mousemoved(x, y, dx, dy)
end

function MenuState:keypressed(key, scancode, isrepeat)
    if key == 'x' then self.btns[self.selected + 1][2]() end
    if key == 'up' then self:moveSelect(-1) end
    if key == 'down' then self:moveSelect(1) end
end

return MenuState