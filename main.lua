require 'libraries.doodlehouse.dscolor.doodlecolor'
require 'src.fonts'
Timer = require 'libraries.knife.knife.timer'
MenuState = require 'src.gameStates.menuState'
GameState = require 'src.gameStates.gameState'
HelpState = require 'src.gameStates.helpState'

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.keyboard.setKeyRepeat(true)

    setFont(Fonts.caption)

    scale = 4
    g_offsetX = 0
    g_offsetY = 0
    menuCol = 1

    stateLookup = {
        ['menu'] = MenuState(),
        ['game'] = GameState(),
        ['help'] = HelpState(),
    }
    state = nil

    changeState('menu')
end

function doNothing()
end


function changeState(targetState)
    menuCol = 7
    Timer.after(0.5, function()
        menuCol = 1;
    end)

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
    setColor(1)
    love.graphics.rectangle('line', 2,2,(game_width/scale)-4,(game_height/scale)-4)
    dropPrint(state.name, 6, 0, menuCol)
    state:draw()
end

function dropPrint(text, x, y, c, dc)
    setColor(dc or 0)
    for yy = -1, 1 do
        for xx = -1, 1 do
            love.graphics.print(text, x+xx, y+yy)
        end
    end
    setColor(c or 1)
    love.graphics.print(text, x, y)
end

function love.update(dt)
    state:update(dt)
    Timer.update(dt)
end

-- function love.mousemoved(x, y, dx, dy)
--     state:mousemoved(x, y, dx, dy)
-- end

-- function love.mousepressed(x, y, button)
--     state:mousepressed(x, y, button)
-- end

function love.keypressed(key, scancode, isrepeat)
    if key == 'f' then
        love.window.setFullscreen(not love.window.getFullscreen())
    end

    state:keypressed(key, scancode, isrepeat)
end