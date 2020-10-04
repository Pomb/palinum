Base = require('libraries.knife.knife.base')

State = Base:extend()

function State:constructor(SM)
    self.name = "State"
    self.machine = SM
    self.transitions = {}
end

function State:addTransition(signal, target)
    self.transitions[signal] = target
end

function State:attempt(signal)
    -- add guards
    return self.transitions[signal]
end

function State:enter()
    --print("enter "..self.name)
end

function State:input(x, y)
end

function State:select()
end

function State:update(dt)
end

function State:draw()
end

function State:exit()
    --print("exit "..self.name)
end

return State