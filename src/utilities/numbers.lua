function clamp(val, min, max)
    return math.max(min, math.min(val, max));
end

function wrap(val, min, max)
    if val > max then
        return min
    elseif val < min then
        return max
    else
        return val
    end
end

function lerp(a, b, t)
    return (1 - t) * a + (t * b)
end

function cardinalDirection(x1, y1, x2, y2)
    
    if x1 == x2 then --vertical
        if y1 < y2 then return 'south' else return 'north' end
    elseif y1 == y2 then --horizontal
        if x1 < x2 then return 'east' else return 'west' end
    else
        error('ERROR atleast one of the vectors axis need to match!')
    end
end