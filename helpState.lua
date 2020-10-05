HelpState = {}

meta = {
    __call = function()
        return HelpState;
    end
}

setmetatable(HelpState, meta)

function HelpState:init()
    self.name = 'help'
end

function HelpState:update(dt)
end

function HelpState:draw()
    setColor(7)
    love.graphics.printf('x', -16, 128, game_width/scale, 'center');
    love.graphics.printf('back', 0, 128, game_width/scale, 'center')
end

function HelpState:mousemoved(x, y, dx, dy)
end

function HelpState:keypressed(key, scancode, isrepeat)
    if key == 'x' then
        changeState('menu')
    end
end

return HelpState