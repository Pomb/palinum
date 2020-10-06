require 'libraries.doodlehouse.dscolor.doodlecolor'
require 'src.fonts'
Timer = require 'libraries.knife.knife.timer'
Moonshine = require('libraries.moonshine')
MenuState = require 'src.gameStates.menuState'
GameState = require 'src.gameStates.gameState'
HelpState = require 'src.gameStates.helpState'

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.keyboard.setKeyRepeat(true)

    setFont(Fonts.caption)

    effectsOn = true
    debug = false

    g_offsetX = 0
    g_offsetY = 0
    menuCol = 1

    debugText = {
        ['fps'] = '',
        ['state'] = '',
        ['level'] = '',
    }

    stateLookup = {
        ['menu'] = MenuState(),
        ['game'] = GameState(),
        ['help'] = HelpState(),
    }
    state = nil
    changeState('menu')
    
    canvas = love.graphics.newCanvas(game_width, game_height)
    

    Effect = Moonshine(Moonshine.effects.crt)
        .chain(Moonshine.effects.chromasep)
        .chain(Moonshine.effects.scanlines)
        .chain(Moonshine.effects.godsray)
        .chain(Moonshine.effects.glow)

    Effect.parameters = {
        chromasep = {radius = 1, angle = 0.5},
        scanlines = {width = 2, phase = 1, thickness = 0.1},
        crt = {x = 1.05, y = 1.025},
        godsray = {density = 1, weight = 0.02, decay = 0.97},
        glow = {strength = 0.1}
    }
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
        debugText['state'] = state.name
    else
        error("no state named "..targetState)
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.setLineWidth(1)
    setColor(1, 1)
    love.graphics.rectangle('line', 4,3,(game_width/scale)-8,(game_height/scale)-6)
    setColor(0)
    love.graphics.rectangle('fill', 8, 0, ((#state.name)*scale) + 3, 4)
    dropPrint(state.name, 10, 0, menuCol)

    state:draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.setCanvas()
    love.graphics.pop()

    if effectsOn then
    Effect(
        function ()
            love.graphics.draw(canvas, 0, 0, 0, scale, scale, g_offsetX, g_offsetY, 0, 0)
        end)
    else
        love.graphics.draw(canvas, 0, 0, 0, scale, scale, g_offsetX, g_offsetY, 0, 0)
    end

    if debug then drawDebug() end
end

function drawDebug()
    setFont(Fonts.console)
    setColor(8)
    local i = 1
    for key, value in pairs(debugText) do
        love.graphics.print(key, 26, 18 + 12 * i)
        love.graphics.print(value, 80, 18 + 12 * i)
        i = i + 1
    end
    love.graphics.setColor(1,1,1,1)
    setFont(Fonts.caption)
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
    if effectsOn then Effect.scanlines.phase = math.sin(dt * 100) * 100 end
    debugText['fps'] = love.timer.getFPS()

    state:update(dt)
    Timer.update(dt)
end

-- function love.mousemoved(x, y, dx, dy)
--     state:mousemoved(x, y, dx, dy)
-- end

-- function love.mousepressed(x, y, button)
--     state:mousepressed(x, y, button)
-- end

function love.resize(w, h)
    print('resized', w, h)
    if love.window.getFullscreen() then
        --g_offsetX = (w/2) / scale
        --g_offsetY = (h/2) / scale
    else
        g_offsetX = 0
        g_offsetY = 0
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'f' then
        love.window.setFullscreen(not love.window.getFullscreen())
    end

    if key == '1' then
        g_offsetX = g_offsetX + 1
    elseif key == '2' then
        g_offsetX = g_offsetX - 1
    elseif key == '3' then
        g_offsetY = g_offsetY + 1
    elseif key == '4' then
        g_offsetY = g_offsetY - 1
    end

    if key == 'e' then
        effectsOn = not effectsOn
    elseif key == 'd' then
        debug = not debug
    end

    state:keypressed(key, scancode, isrepeat)
end