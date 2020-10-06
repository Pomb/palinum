Base = require 'libraries.knife.knife.base'
Curves = require 'libraries.easing.lib.easing'

Console = Base:extend()

function Console:constructor(width, height)
    self.enabled = false
    self.isOpen = false
    self.maxWidth = width or 800
    self.maxHeight = height or 600
    self.lines = {}
    self.commandInput = ''
    self.aniDuration = 0.2

    self.backing = {
        position = {x = 0, y = self.maxHeight},
        size = {width = self.maxWidth, height = 0}
    }
end

function Console:toggle()
    self.enabled = not self.enabled
    print("toggle console")
    if self.enabled then
        self:open()
    else
        self:close()
    end
end

function Console:open()
    self.isOpen = true
    Timer.tween(self.aniDuration, {
        [self.backing.position] = {y = 0},
        [self.backing.size] = {height = self.maxHeight}
    }):ease(Curves.outQuart)
    Timer.after(self.aniDuration, function() self.enabled = true end)
end

function Console:close()
    
    Timer.tween(self.aniDuration, {
        [self.backing.position] = {y = self.maxHeight},
        [self.backing.size] = {height = 0}
    }):ease(Curves.inQuart)
    Timer.after(self.aniDuration, function() 
        self.isOpen = false
        self.enabled = false
    end)
end

function Console:executeCommand()
    table.insert(self.lines, self.commandInput)
    self.commandInput = ''
end

function Console:update(dt)
    if not self.enabled then return end
end

function Console:draw()
    if not self.open then return end -- early out when the console isn't enabled
    setColor(1, 0.5)
    love.graphics.rectangle("fill", self.backing.position.x, self.backing.position.y, self.backing.size.width, self.backing.size.height)
    if not self.enabled then return end
    setFont(Fonts.console)
    setColor(12)
    for i = 1, #self.lines do
        love.graphics.print(self.lines[i], 20, 20 + ((i - 1) * 12))
    end
    setColor(11)
    love.graphics.print('palinum $', 20, self.maxHeight - 30)
    setColor(7)
    love.graphics.print(self.commandInput, 88, self.maxHeight - 30)
    setFont(Fonts.caption)
end

function Console:keypressed(key, code, isRepeat)
    if key == "tab" then self:toggle() end

    if not self.enabled then return end

    if key == 'return' then
        self:executeCommand()
    end
end

function Console:textinput(t)
    if not self.enabled then return end
    self.commandInput = self.commandInput..t
end

function Console:textedited(t)
    if not self.enabled then return end
    self.commandInput = t
end

return Console