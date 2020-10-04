require('libraries.doodlehouse.dscolor.colorized')
Colors = require('libraries.doodlehouse.dscolor.colors')

-- takes the number
function setColor(index)
    -- offsets the numbers to get to pico indicies
    local index = index + 1
    local color = Colors[index]
    love.graphics.setColor(color)
end