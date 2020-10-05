require 'libraries.doodlehouse.dscolor.doodlecolor'
require 'fonts.fonts'
MenuState = require 'menuState'
GameState = require 'gameState'
HelpState = require 'helpState'

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.keyboard.setKeyRepeat(true)

    setFont(Fonts.caption)

    scale = 4
    g_offsetX = 0
    g_offsetY = 0

    stateLookup = {
        ['menu'] = MenuState(),
        ['game'] = GameState(),
        ['help'] = HelpState(),
    }
    state = nil

    changeState('menu')
end


function changeState(targetState)
    if stateLookup[targetState] then
        state = stateLookup[targetState];
        state:init()
    else
        error("no state named "..targetState)
    end
end

function love.draw()
    love.graphics.scale(scale,scale)
    love.graphics.translate(g_offsetX, g_offsetY)
    love.graphics.setLineWidth(1)
    state:draw()
    setColor(1)
    love.graphics.rectangle('line', 2,2,(game_width/scale)-4,(game_height/scale)-4)
    dropPrint(state.name, 6, 0, 1)
end

function dropPrint(text, x, y, c, dc)
    setColor(dc or 0)
    for yy = -1, 1 do
        for xx = -1, 1 do
            love.graphics.print(text, x+xx, y+yy)
        end
    end
    setColor(c)
    love.graphics.print(text, x, y)
end

function love.update(dt)
    state:update(dt)
end

-- function love.mousemoved(x, y, dx, dy)
--     state:mousemoved(x, y, dx, dy)
-- end

-- function love.mousepressed(x, y, button)
--     state:mousepressed(x, y, button)
-- end

function love.keypressed(key, scancode, isrepeat)
    if key == 'f' then
        love.window.setFullscreen(not love.window.getFullscreen(), "desktop")

        if love.window.getFullscreen() then
            w, h = love.graphics.getDimensions()
            g_offsetX = (w / 12)
            g_offsetY = (h / 16)
        else
            g_offsetX = 0
            g_offsetY = 0
        end
    end

    state:keypressed(key, scancode, isrepeat)
end