-- Map module for loading and managing background images
local map = {}

-- Track if we should show the top right part of the map
map.showTopRight = false

-- Track if we should show the upper part of the map
map.showUpperPart = false

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
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local bgWidth = background:getWidth()
    local bgHeight = background:getHeight()
    local scaleX, scaleY, drawY

    if self.imagePath and (self.imagePath:find("darkLevelBg")) then
        -- For dark level, fit 100% of the image to the screen
        scaleX = screenWidth / bgWidth
        scaleY = screenHeight / bgHeight
        drawY = 0
        love.graphics.draw(background, 0, drawY, 0, scaleX, scaleY)
    elseif map.showTopRight then
        -- Show the true top right corner of the map (right edge flush with screen)
        local scaleMultiplier = 0.55
        scaleX = screenWidth / (bgWidth * scaleMultiplier)
        scaleY = screenHeight / (bgHeight * scaleMultiplier)
        -- Align the right edge of the map with the right edge of the screen
        local drawX = screenWidth - bgWidth * scaleX
        if drawX > 0 then drawX = 0 end
        -- Optionally shift down if you want more bottom ttt
        local yShift = bgHeight * scaleY * 0.17
        local drawY = -yShift
        love.graphics.draw(background, drawX, drawY, 0, scaleX, scaleY)
    else
        local scaleMultiplier = 0.55
        scaleX = screenWidth / (bgWidth * scaleMultiplier)
        scaleY = screenHeight / (bgHeight * scaleMultiplier)
        if map.showUpperPart then
            -- Show the upper part, but keep about 30% of the current map at the bottom
            local visibleHeight = bgHeight * scaleY
            local overlap = visibleHeight * 0.3
            drawY = -(visibleHeight - screenHeight) + overlap
            if drawY > 0 then drawY = 0 end
        else
            drawY = screenHeight - bgHeight * scaleY
        end
        love.graphics.draw(background, 0, drawY, 0, scaleX, scaleY)
    end
end

-- Function to set a new image path
function map:setImagePath(newPath)
    self.imagePath = newPath
    -- Reset scale logic if needed
    self.showUpperPart = false
    self.showTopRight = false
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


