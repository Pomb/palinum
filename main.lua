require 'libraries.doodlehouse.dscolor.doodlecolor'
require 'src.fonts'
Timer = require 'libraries.knife.knife.timer'
Moonshine = require('libraries.moonshine')
MenuState = require 'src.gameStates.menuState'
GameState = require 'src.gameStates.gameState'
HelpState = require 'src.gameStates.helpState'
Console = require 'src.console'

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.keyboard.setKeyRepeat(true)

    setFont(Fonts.caption)

    console = Console(game_width, game_height, timer)

    -- console commands
    console:addCommand("fullscreen", function()
        toggleFullscreen()
        console:addDescriptionLine('fullscreen = '..tostring(love.window.getFullscreen()))
    end, "toggles fullscreen mode")
    console:addCommand("debug", function()
        debug = not debug
        console:addDescriptionLine('debug = '..tostring(debug))
    end, "toggles debug info overlay")
    console:addCommand("effects", function()
        effectsOn = not effectsOn
        console:addDescriptionLine('effects = '..tostring(effectsOn))
    end, "toggles the effects stack")
    -- TODO: make the console be able to wrap long text on the width of the screen.
    console:addCommand("history", function() 
        console:addDescriptionLine('A palindrome is a word, number, phrase, or other sequence of characters which')
        console:addDescriptionLine('reads the same backward as forward, such as madam, racecar.')
        console:addDescriptionLine('There are also numeric palindromes, including date/time stamps using short')
        console:addDescriptionLine('digits 11/11/11 11:11 and long digits 02/02/2020.')
        console:addDescriptionLine('Sentence-length palindromes ignore capitalization, punctuation, and word boundaries.')
    end, "tell me about a palindrome")
    console:addCommand("level", function(num)
        local levelNumber = tonumber(num) or 1
        if levelNumber then
            if state ~= stateLookup['game'] then changeState('game') end
            stateLookup['game']:setLevel(levelNumber)
        else
            console:addErrorLine(tostring(num)..' is not a valid level number, please try again with a whole number')
        end
    end, "load the level number")

    effectsOn = true
    debug = false

    g_offsetX = 0
    g_offsetY = 0
    
    cameraShake = {
        x = 0,
        y = 0,
        duration = 0,
        frequency = 0,
    }

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

function shake(duration, frequency)
    cameraShake.duration = cameraShake.duration + duration
    cameraShake.frequency = cameraShake.frequency + frequency
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
    love.graphics.translate(cameraShake.x, cameraShake.y)
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
        Effect(function () draw() end)
    else
        draw()
    end
end

function draw()
    love.graphics.draw(canvas, 0, 0, 0, scale, scale, g_offsetX, g_offsetY, 0, 0)
    if debug then drawDebug() end
    console:draw()
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

    if cameraShake.duration > 0 then
        cameraShake.x = math.random(-1, 1) * cameraShake.frequency
        cameraShake.y = math.random(-1, 1) * cameraShake.frequency
        cameraShake.duration = cameraShake.duration - dt
        cameraShake.frequency = cameraShake.frequency * cameraShake.duration
    else
        cameraShake.x = 0
        cameraShake.y = 0
    end

    state:update(dt)
    Timer.update(dt)
    console:update(dt)
end

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

function love.textinput(t)
    console:textinput(t)
end

function toggleFullscreen()
    love.window.setFullscreen(not love.window.getFullscreen())
end

function love.keypressed(key, scancode, isrepeat)
    if not console.isOpen then
        if key == '1' then
            g_offsetX = g_offsetX + 1
        elseif key == '2' then
            g_offsetX = g_offsetX - 1
        elseif key == '3' then
            g_offsetY = g_offsetY + 1
        elseif key == '4' then
            g_offsetY = g_offsetY - 1
        elseif key == '0' then
            shake(math.random(0.1, 1), math.random(0.1, 2))
        end
        state:keypressed(key, scancode, isrepeat)
    end
    
    console:keypressed(key, scancode, isrepeat)
end