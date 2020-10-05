function printTable(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end

function clone(t)
    local clone = {}
    for k, v in pairs(t) do
        clone[k] = v
    end
    return clone
end

function reverse(t)
    local eh = {}
    for i = #t, 1, -1 do
        table.insert(eh, t[i])
    end
    return eh
end

function randomKey(t)
    return t[love.math.random(1, #t)]
end

function shuffle(t)
    local len = #t
    local r, tmp
    for i = 1, len do
      r = love.math.random(i, len)
      tmp = t[i]
      t[i] = t[r]
      t[r] = tmp
    end
end
