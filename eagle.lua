-- Eagle module
local Eagle = {}
Eagle.active = false
Eagle.x = 0
Eagle.y = 0
Eagle.speed = 600 -- twice as fast
Eagle.image = nil
Eagle.width = 0
Eagle.height = 0
Eagle.scale = 0.20

function Eagle:load()
    -- Load eagle image and create a blurry version
    local img = love.graphics.newImage("assets/eagle.png")
    -- Create a canvas to draw a blurred eagle
    local w, h = img:getWidth(), img:getHeight()
    local blurCanvas = love.graphics.newCanvas(w, h)
    love.graphics.setCanvas(blurCanvas)
    love.graphics.clear(0,0,0,0)
    -- Draw the image multiple times with small offsets and low alpha for blur
    for dx = -4, 4 do
        for dy = -4, 4 do
            local dist = math.sqrt(dx*dx + dy*dy)
            local alpha = 0.08 * (1 - dist/6)
            if alpha > 0 then
                love.graphics.setColor(1,1,1,alpha)
                love.graphics.draw(img, dx, dy)
            end
        end
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.setCanvas()
    self.image = love.graphics.newImage(blurCanvas:newImageData())
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.active = false
end

function Eagle:activate(dogX, dogY)
    -- Start offscreen (left or right randomly)
    if math.random() < 0.5 then
        self.x = -self.width
    else
        self.x = love.graphics.getWidth() + self.width
    end
    self.y = math.random(50, love.graphics.getHeight() - 50)
    self.targetX = dogX
    self.targetY = dogY
    self.facingLeft = (self.x > dogX)
    self.active = true
    if SoundManager and SoundManager.playEagle then
        SoundManager:playEagle(1.0)
    end
end

function Eagle:update(dt, dogX, dogY)
    if not self.active then return end
    -- Always update target to dog's current position
    self.targetX = dogX
    self.targetY = dogY
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist < 10 then
        self.active = false
        return
    end
    local vx = dx / dist * self.speed
    local vy = dy / dist * self.speed
    self.x = self.x + vx * dt
    self.y = self.y + vy * dt
    -- Flip sprite based on direction (for horizontal flip only)
    self.facingLeft = vx < 0
end

function Eagle:draw()
    if not self.active then return end
    -- Draw motion blur effect by drawing the eagle multiple times with decreasing alpha
    local blurSteps = 12
    local blurAlpha = 0.22
    local sx = self.scale
    local sy = self.scale
    local ox = self.width / 2
    local oy = self.height / 2
    if not self.facingLeft then
        sx = -self.scale
    end
    -- Calculate velocity direction for blur offset
    local vx = self.facingLeft and -1 or 1
    for i = blurSteps, 1, -1 do
        local alpha = blurAlpha * (i / blurSteps)
        love.graphics.setColor(1, 1, 1, alpha)
        local offset = (i - 1) * 8 * vx -- smaller offset for more overlap
        love.graphics.draw(self.image, self.x + ox - offset, self.y + oy + math.random(-2,2), 0, sx, sy, ox, oy)
    end
    -- Draw main eagle
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.image, self.x + ox, self.y + oy, 0, sx, sy, ox, oy)
end

return Eagle
