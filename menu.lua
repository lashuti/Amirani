local Menu = {}

Menu.items = { "Start Game", "Options", "Quit" }

function Menu:update(dt)
    -- Nothing needed for now
end

function Menu:draw()
    love.graphics.setFont(love.graphics.newFont(36))
    -- Remove title drawing here, handled in main.lua
    local buttonWidth = 400
    local buttonHeight = 70
    local spacing = 30
    local startY = 220 -- Lower so buttons don't overlap the title
    local screenWidth = love.graphics.getWidth()
    for i, item in ipairs(self.items) do
        local x = (screenWidth - buttonWidth) / 2
        local y = startY + (i-1) * (buttonHeight + spacing)
        local mx, my = love.mouse.getPosition()
        local isHover = mx >= x and mx <= x + buttonWidth and my >= y and my <= y + buttonHeight
        if isHover then
            love.graphics.setColor(0.3, 0.7, 1)
        else
            love.graphics.setColor(0.2, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", x, y, buttonWidth, buttonHeight, 16, 16)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(item, x, y + buttonHeight/2 - 18, buttonWidth, "center")
    end
    love.graphics.setColor(1, 1, 1)
end
function Menu:mousemoved(x, y, dx, dy)
    local buttonWidth = 400
    local buttonHeight = 70
    local spacing = 30
    local startY = 200
    local screenWidth = love.graphics.getWidth()
    self.selected = nil
    for i, item in ipairs(self.items) do
        local bx = (screenWidth - buttonWidth) / 2
        local by = startY + (i-1) * (buttonHeight + spacing)
        if x >= bx and x <= bx + buttonWidth and y >= by and y <= by + buttonHeight then
            self.selected = i
        end
    end
end
function Menu:mousepressed(x, y, button)
    if button ~= 1 then return end
    local buttonWidth = 400
    local buttonHeight = 70
    local spacing = 30
    local startY = 200
    local screenWidth = love.graphics.getWidth()
    for i, item in ipairs(self.items) do
        local bx = (screenWidth - buttonWidth) / 2
        local by = startY + (i-1) * (buttonHeight + spacing)
        if x >= bx and x <= bx + buttonWidth and y >= by and y <= by + buttonHeight then
            if item == "Start Game" then
                _G.CurrentState = _G.GameState.GAME
            elseif item == "Quit" then
                love.event.quit()
            end
        end
    end
end

function Menu:keypressed(key)
    -- No keyboard navigation, only mouse
end

return Menu
