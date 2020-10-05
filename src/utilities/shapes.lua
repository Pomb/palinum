
-- takes direction north south east west and returns triangle verts
function triangleVerts(cardinalDir, x, y, size, shift)
    -- north
    local verts = {
        north = {x - size, y + size - shift, x + size, y + size - shift, x, y - shift},
        south = {x - size, y - size + shift, x + size, y - size + shift, x, y + shift},
        east = {x - size + shift, y - size, x + shift, y, x - size + shift, y + size},
        west = {x + size - shift, y - size, x - shift, y, x + size - shift, y + size}
    }

    return verts[cardinalDir]
end