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
end

function HelpState:mousemoved(x, y, dx, dy)
end

function HelpState:keypressed(key, scancode, isrepeat)
    if key == 'x' then
        changeState('menu')
    end
end

return HelpState