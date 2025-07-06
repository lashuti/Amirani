
-- Dog module: merges movement/logic and animation
local Dog = {}
local Map = require "map"
local dogImage

-- Animation
local frames = {}
local frameIndex = 1
local frameTimer = 0
local frameDuration = 0.1
local scale = 0.1

-- Movement/logic
Dog.x = 0
Dog.y = 300
Dog.width = 60
Dog.height = 30
Dog.imageScale = 0.2
Dog.angle = 0
Dog.speed = 350--120
Dog.rotationSpeed = math.rad(300)
Dog.targets = {
    { x = 10, y = 320 },
    { x = 330, y = 305 },
    { x = 440, y = 540 },
    { x = 900, y = 520 },
    { x = 1000, y = 340 },
    { x = 680, y = 0 },
    { x = 480, y = 420 },
    { x = 670, y = 120 },
}
Dog.currentTarget = 1

function Dog:load()
    -- Load animation frames
    frames = {}
    for i = 1, 6 do -- Change 6 to however many frames you have
        frames[i] = love.graphics.newImage("assets/animations/dog/" .. i .. ".png")
    end
    frameIndex = 1
    frameTimer = 0
    -- For fallback/static image
    dogImage = love.graphics.newImage("assets/dogPlaceholder.png")

    -- Set width and height based on animation frames if available, otherwise fallback image
    if #frames > 0 then
        self.width = frames[1]:getWidth() * scale
        self.height = frames[1]:getHeight() * scale
    else
        self.width = dogImage:getWidth() * self.imageScale
        self.height = dogImage:getHeight() * self.imageScale
    end
end

function Dog:update(dt)
    -- Switch to LIGHT_LEVEL and dark background when dog reaches (670, 120)
    if CurrentState == GameState.GAME then
        if math.abs(self.x - 670) < 15 and math.abs(self.y - 120) < 15 then
            if Map and Map.setImagePath then
                Map:setImagePath("assets/darkLevelBg.png")
                if Map.reload then Map:reload() end
            end

        end
    end
    -- Animation
    frameTimer = frameTimer + dt
    if frameTimer >= frameDuration then
        frameTimer = frameTimer - frameDuration
        frameIndex = frameIndex + 1
        if frameIndex > #frames then
            frameIndex = 1
        end
    end
    -- Movement (diagonal allowed)
    local target = self:_getTarget()
    local dx = target.x - self.x
    local dy = target.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 1 then
        -- Normalize direction
        local dirX = dx / distance
        local dirY = dy / distance
        self.x = self.x + dirX * self.speed * dt
        self.y = self.y + dirY * self.speed * dt
        -- Set angle for left/right facing
        if dirX > 0 then
            self.angle = math.pi -- face right (flipped)
        else
            self.angle = 0 -- face left (default)
        end
    end

    self:_getCurrentPriorityTarget(distance)

    -- Switch map when dog reaches (680, 0) regardless of target order
    if CurrentState == GameState.GAME then
        if math.abs(self.x - 680) < 15 and math.abs(self.y - 0) < 15 then
            if not Map.showUpperPart and Map and Map.showUpperPart ~= nil then
                Map.showUpperPart = true
                self.x = 920
                self.y = 600
                -- Jump to next target after map switch
                self.currentTarget = self.currentTarget % #self.targets + 1
            end
        end
    end
end

function Dog:_getTarget()
    if CurrentState == GameState.LIGHT_LEVEL then
        return { x = love.mouse.getX(), y = love.mouse.getY() }
    elseif CurrentState == GameState.GAME then
        return self.targets[self.currentTarget]
    end
end

-- _rotateTowards is no longer needed

function Dog:_moveForward(dt)
    self.x = self.x + math.cos(self.angle) * self.speed * dt
    self.y = self.y + math.sin(self.angle) * self.speed * dt
end

function Dog:_getCurrentPriorityTarget(distance)
    if distance < 10 and CurrentState == GameState.GAME then
        self.currentTarget = self.currentTarget % #self.targets + 1
    end
end

function Dog:draw(s)
    -- Draw a shadow by drawing the dog image/animation in black, slightly offset and squashed
    local shadowOffsetY = self.height * 0.40
    local shadowScaleY = 0.45 * (s or scale or 1)
    local shadowAlpha = 0.45
    if #frames > 0 then
        love.graphics.push()
        love.graphics.translate(self.x, self.y + shadowOffsetY)
        local flip = 1
        local drawAngle = 0
        local ox = -(self.width/2)
        if self.angle == math.pi then
            flip = -1
            ox = self.width/2
        end
        love.graphics.setColor(0, 0, 0, shadowAlpha)
        love.graphics.draw(frames[frameIndex], ox, -(self.height/2), drawAngle, (s or scale) * flip, shadowScaleY)
        love.graphics.pop()
    else
        love.graphics.push()
        love.graphics.translate(self.x, self.y + shadowOffsetY)
        love.graphics.rotate(self.angle)
        love.graphics.setColor(0, 0, 0, shadowAlpha)
        love.graphics.draw(dogImage, -self.width / 2, -self.height / 2, 0, self.imageScale, shadowScaleY)
        love.graphics.pop()
    end

    -- Draw animated dog if frames exist, else fallback to static image
    if #frames > 0 then
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        -- Only flip horizontally for left/right, never upside down
        local flip = 1
        local drawAngle = 0
        local ox = -(self.width/2)
        if self.angle == math.pi then
            flip = -1
            ox = self.width/2 -- shift origin for horizontal flip
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(frames[frameIndex], ox, -(self.height/2), drawAngle, (s or scale) * flip, s or scale)
        love.graphics.pop()
    else
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.angle)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(dogImage, -self.width / 2, -self.height / 2, 0, self.imageScale, self.imageScale)
        love.graphics.pop()
    end
end

function Dog.setScale(s)
    scale = s or scale
end

return Dog
