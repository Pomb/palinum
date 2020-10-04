Base = require('libraries.knife.knife.base')
require('libraries.doodlehouse.dscolor.doodlecolor')

StateMachine = Base:extend()

function StateMachine:constructor(name)
    self.name = name or 'Machine'
    self.currentState = nil
    self.states = {}
end

function StateMachine:update(dt)
    self.currentState:update(dt)
end

function StateMachine:draw()
    self.currentState:draw()
end

function StateMachine:add(state)
    table.insert(self.states, state)
end

function StateMachine:printStates()
    for key, value in pairs(self.states) do
        print(key, value)
    end
end

function StateMachine:switch(state, ...)
    if self.currentState then
        Event.dispatch('switch', {self.name, self.currentState.name, state.name})
        self.currentState:exit()
    else
        Event.dispatch('switch', {self.name, 'empty', state.name})
    end

    self.currentState = state
    self.currentState:enter(...)

end

function StateMachine:fire(signal, ...)
    local targetState = self.currentState:attempt(signal)
    if targetState ~= nil then
        self:switch(targetState, ...)
    else
        print(self.currentState.name.." has no target state set for signal: "..signal)
    end
end

return StateMachine