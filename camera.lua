local Camera = {}

Camera.x = 0
Camera.y = 0

function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end

function Camera:moveByScreen(dx, dy)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    self.x = self.x + dx * screenWidth
    self.y = self.y + dy * screenHeight
end


function Camera:attach()
    love.graphics.push()
    love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
    love.graphics.pop()
end

return Camera
