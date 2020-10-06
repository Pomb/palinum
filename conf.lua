scale = 4
game_width = 160 * scale
game_height = 144 * scale

function love.conf(t)
    t.window.title = "plainum"
    t.window.width = game_width
    t.window.height = game_height
    t.window.vsync = 1
    t.window.fullscreentype = "exclusive"
    t.window.fullscreen = false
end