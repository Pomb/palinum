Base = require 'libraries.knife.knife.base'
Curves = require 'libraries.easing.lib.easing'
require 'src.utilities.strings'

Console = Base:extend()

function Console:constructor(width, height, backingColor, alpha)
    self.enabled = false
    self.isOpen = false
    self.maxWidth = width or 800
    self.maxHeight = height or 600
    self.lines = {}
    self.commandInput = ''
    self.aniDuration = 0.2
    self.textColor = 12
    self.indent = 20
    self.detailTextColor = 6
    self.maxLines = 30
    self.dirColor = 11
    self.errorColor = 8
    self.commands = {}
    self.rootDirectory = '/palinum'
    
    self.backing = {
        color = backingColor or 1,
        alpha = alpha or 0.85,
        position = {x = 0, y = self.maxHeight},
        size = {width = self.maxWidth, height = 0}
    }

    self:addCommand("hello", function()
        self:addLine("Welcome to the console", self.dirColor, 20)
        self:addLine("There are a couple commands avaiable, to see them type: help", self.dirColor, 20)
    end, "welcome")
    self:addCommand("help", function()
        for _, value in pairs(self.commands) do
            table.insert(self.lines, {text = string.lpad(value.command, 20)..'- '..value.help, color = self.detailTextColor, indent = 10})
        end
    end, "show the available commands in the console")
    self:addCommand("quit", function()
        love.event.quit()
    end, "quit the game, also with cmd+Q (mac) or alt+F4 (pc)")
end

--[[ the commands the console accepts, anything else throws an error
    @command the command to match
    @callback the function to call on match
    @help the text shown in the help
]]
--TODO: Add arguments for for the command. eg. animation --speed 0.5
--TODO: Add help calls on a command. eg. animation --help -> gives you the normal help with expected args list
function Console:addCommand(command, callback, help)
    self.commands[command] = {command = command, callback = callback, help = help}
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

function Console:addLine(text, color, indent)
    assert(text, "Can't add lines without text")
    table.insert(self.lines, {text = text, color = color or self.textColor, indent = indent or 0})
end

function Console:addDescriptionLine(text)
    self:addLine(text, self.detailTextColor, 10)
end

function Console:executeCommand()
    self:addLine(self.commandInput, self.textColor)
    local c = self.commandInput
    self.commandInput = ''

    if c ~= nil then
        if self.commands[c] ~= nil then
            self.commands[c].callback()
        else
            self:addLine('plalinum: command not found: '..c, self.errorColor)
        end
    end
end

function Console:update(dt)
    if not self.enabled then return end
end

function Console:draw()
    if not self.open then return end -- early out when the console isn't enabled
    setColor(self.backing.color, self.backing.alpha)
    love.graphics.rectangle("fill", self.backing.position.x, self.backing.position.y, self.backing.size.width, self.backing.size.height)
    if not self.enabled then return end
    setFont(Fonts.console)

    local h = self.maxHeight - 50
    local diff = #self.lines - self.maxLines
    local starti = math.max(1, diff)
    local endi = math.max(#self.lines, #self.lines - starti)
    -- FIXME add the differnce of what's visible removed on the Y offset in the print
    for i = starti, endi do
        setColor(self.lines[i].color)
        love.graphics.print(self.lines[i].text, self.indent + (self.lines[i].indent or 0), 20 + ((i - 1) * 14))
    end

    setColor(0)
    love.graphics.line(self.backing.position.x, h - 10, self.backing.position.x + self.maxWidth, h - 10)
    setColor(self.dirColor)
    love.graphics.print(self.rootDirectory..' $', self.indent, h)
    setColor(self.textColor)
    love.graphics.print(self.commandInput, self.indent + (#self.rootDirectory * 10), h)
    setFont(Fonts.caption)
end

function Console:keypressed(key, code, isRepeat)
    if key == "tab" then self:toggle() end

    if not self.enabled then return end

    if key == 'return' then
        self:executeCommand()
    end

    if key == 'backspace' then
        self.commandInput = string.sub(self.commandInput, 0, #self.commandInput - 1)
    end
end

function Console:textinput(t)
    if not self.enabled then return end
    self.commandInput = self.commandInput..t
end

return Console