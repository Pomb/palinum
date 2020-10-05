require('libraries.doodlehouse.dscolor.colorized')
Colors = require('libraries.doodlehouse.dscolor.colors')

-- takes the number
function setColor(index, alpha)
    -- offsets the numbers to get to pico indicies
    local c = Colors[index + 1]
    c[4] = alpha or 1
    love.graphics.setColor(unpack(c))
end

function setBackgroundColor(index)
    love.graphics.setBackgroundColor(Colors[index + 1])
end