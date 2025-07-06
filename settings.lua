local settings = {
    DEBUG_MODE = false,
    WIDTH = 1280,
    HEIGHT = 720,
    TITLE = "Amirani's Cuga"
}

function settings:load()
    love.window.setMode(self.WIDTH, self.HEIGHT)
    love.window.setTitle(self.TITLE)
end

function settings:draw_position()
    if (settings.DEBUG_MODE) then
        local mx, my = love.mouse.getPosition()
        love.graphics.print("X:" .. mx .. " Y:" .. my, 10, 10)
    end
end

return settings


