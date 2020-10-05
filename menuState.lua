require("utf8")

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
end

function MenuState:update(dt)
end

function MenuState:draw()
    for i, value in pairs(self.btns) do
        if i == self.selected + 1 then
            setColor(7)
            love.graphics.printf('x', -16, 50 + (i * 8), game_width/4, 'center');
        else
            setColor(1)
        end
        love.graphics.printf(value[1], 0, 50 + (i * 8), game_width/4, 'center')
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