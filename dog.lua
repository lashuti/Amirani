
-- Dog module: merges movement/logic and animation
local Dog = {}
local dogImage

-- Animation
local frames = {}
local frameIndex = 1
local frameTimer = 0
local frameDuration = 0.1
local scale = 0.2

-- Movement/logic
Dog.x = 200
Dog.y = 200
Dog.width = 60
Dog.height = 30
Dog.imageScale = 0.2
Dog.angle = 0
Dog.speed = 120
Dog.rotationSpeed = math.rad(300)
Dog.targets = {
    { x = 400, y = 200 },
    { x = 400, y = 500 },
    { x = 300, y = 400 },
    { x = 200, y = 100 }
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
    -- Animation
    frameTimer = frameTimer + dt
    if frameTimer >= frameDuration then
        frameTimer = frameTimer - frameDuration
        frameIndex = frameIndex + 1
        if frameIndex > #frames then
            frameIndex = 1
        end
    end
    -- Movement
    local target = self:_getTarget()
    local dx = target.x - self.x
    local dy = target.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    -- Only move left/right or up/down, no rotation
    if math.abs(dx) > 1 then
        if dx > 0 then
            self.x = self.x + self.speed * dt
            self.angle = math.pi -- face right (flipped)
        else
            self.x = self.x - self.speed * dt
            self.angle = 0 -- face left (default)
        end
    elseif math.abs(dy) > 1 then
        if dy > 0 then
            self.y = self.y + self.speed * dt
        else
            self.y = self.y - self.speed * dt
        end
        -- keep angle unchanged when moving vertically
    end

    self:_getCurrentPriorityTarget(distance)
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
