-- Map module for loading and managing background images
local map = {}

-- Default configuration
map.imagePath = "assets/map.png"
map.background = nil

-- Function to load background image
function map:loadBackground(imagePath)
    -- Use provided path or default
    imagePath = imagePath or self.imagePath

    -- Check if the image path is provided
    if not imagePath then
        error("Image path is required")
    end

    -- Load the background image
    local background = love.graphics.newImage(imagePath)

    -- Store background properties
    self.background = {
        image = background,
        width = background:getWidth(),
        height = background:getHeight(),
        path = imagePath
    }

    print("Background loaded: " .. imagePath)
    return self.background
end

-- Function to draw the background
function map:drawBackground(x, y, scaleX, scaleY)
    if self.background and self.background.image then
        x = x or 0
        y = y or 0
        scaleX = scaleX or 1
        scaleY = scaleY or 1

        love.graphics.draw(self.background.image, x, y, 0, scaleX, scaleY)
    end
end

-- Function to get background dimensions
function map:getBackgroundDimensions()
    if self.background then
        return self.background.width, self.background.height
    end
    return 0, 0
end

-- Function to scale background to fit screen
function map:scaleBackgroundToScreen(screenWidth, screenHeight)
    if self.background then
        local scaleX = screenWidth / self.background.width
        local scaleY = screenHeight / self.background.height
        return scaleX, scaleY
    end
    return 1, 1
end

-- Main load function following the pattern from other modules
function map:load()
    background = love.graphics.newImage(self.imagePath)
    --self:loadBackground(self.imagePath)
end

function map:draw()
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white (important if you use tinting elsewhere)
    local scaleMultiplier = 0.55
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local bgWidth = background:getWidth()
    local bgHeight = background:getHeight()
    local scaleX = screenWidth / (bgWidth * scaleMultiplier)
    local scaleY = screenHeight / (bgHeight * scaleMultiplier)
    -- Draw so that the bottom left of the image is at (0, screenHeight)
    love.graphics.draw(background, 0, screenHeight - bgHeight * scaleY, 0, scaleX, scaleY)
end

-- Function to set a new image path
function map:setImagePath(newPath)
    self.imagePath = newPath
end

-- Function to reload with current or new path
function map:reload(newPath)
    if newPath then
        self.imagePath = newPath
    end
    self:load()
end

-- Clean up resources
function map:cleanup()
    if self.background then
        self.background = nil
    end
end

return map


