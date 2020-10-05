HelpState = {}

meta = {
    __call = function()
        return HelpState;
    end
}

setmetatable(HelpState, meta)

function HelpState:init()
    self.name = 'help'
    self.ids = {8, 12, 11, 12, 8}
end

function HelpState:update(dt)
end

function HelpState:draw()
    setColor(1)
    love.graphics.print("- move with the arrow keys", 10, 10)
    love.graphics.print("- x to reset start position", 10, 16)
    love.graphics.print("- create palindroms to score", 10, 22)
    love.graphics.print("- minimum length of 3", 10, 28)
    love.graphics.print('palindrom\n\n  "a sequence that is the\n\n     same forwards and backwards"', 10, 50)
    self:example()

    setColor(7)
    love.graphics.printf('x', -16, 128, game_width/scale, 'center');
    love.graphics.printf('back', 0, 128, game_width/scale, 'center')
end

function HelpState:example()
    local startX = 1 * 16
    local startY = 6 * 16
    local padding = 1

    for i = 1, #self.ids do
        local x = startX + (i * 16) + (i * padding)
        setColor(self.ids[i])
        love.graphics.rectangle("fill", x, startY, 16, 16)
    end

end

function HelpState:mousemoved(x, y, dx, dy)
end

function HelpState:keypressed(key, scancode, isrepeat)
    if key == 'x' then
        changeState('menu')
    end
end

return HelpState