love.graphics.setDefaultFilter("nearest", "nearest")

FontSizes = {
    tiny = 4,
    small = 8,
    medium = 10,
    mediumAlt = 12,
    large = 16,
    massive = 20,
}

Fonts = {
    caption = love.graphics.newFont('fonts/PICO-8mono.ttf', FontSizes.tiny),
    subtitle = love.graphics.newFont('fonts/PICO-8mono.ttf', FontSizes.small),
    actions = love.graphics.newFont('fonts/PICO-8mono.ttf', FontSizes.medium),
    body = love.graphics.newFont('fonts/PICO-8mono.ttf', FontSizes.mediumAlt),
    title = love.graphics.newFont('fonts/PICO-8mono.ttf', FontSizes.large),
    heroTitle = love.graphics.newFont('fonts/PICO-8mono.ttf', FontSizes.massive),
}

function setFont(font)
    love.graphics.setFont(font)
end