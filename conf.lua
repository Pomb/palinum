game_width = 160 * 4
game_height = 144 * 4

function love.conf(t)
    t.window.title = "plainum"
    t.window.width = game_width
    t.window.height = game_height
    t.window.vsync = 0
    t.window.fullscreentype = "exclusive"
    t.window.fullscreen = false
end