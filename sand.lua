local Sand = {}
Sand.__index = Sand

function Sand.new(x, y)
    local self = setmetatable({}, Sand)
    
    self.x = x or 0
    self.y = y or 0
    self.width = 60
    self.height = 60
    self.isDragging = false
    self.active = true
    
    -- Visual properties
    self.particles = {}
    self:generateParticles()
    
    return self
end

function Sand:generateParticles()
    -- Create random sand particles for visual effect
    for i = 1, 100 do
        table.insert(self.particles, {
            x = math.random(-self.width/2, self.width/2),
            y = math.random(-self.height/2, self.height/2),
            size = math.random(1, 3),
            color = math.random(70, 90) / 100  -- Slight color variation
        })
    end
end

function Sand:update(dt)
    if not self.active then return end
    
    -- Sand particles could have subtle movement here if desired
end

function Sand:draw()
    if not self.active then return end
    
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    -- Draw sand base
    love.graphics.setColor(0.76, 0.70, 0.50, 0.8)
    love.graphics.rectangle("fill", -self.width/2, -self.height/2, self.width, self.height, 5)
    
    -- Draw sand particles for texture
    for _, particle in ipairs(self.particles) do
        love.graphics.setColor(particle.color, particle.color * 0.9, particle.color * 0.7, 0.9)
        love.graphics.circle("fill", particle.x, particle.y, particle.size)
    end
    
    -- Draw sand pile effect (mounded in center)
    love.graphics.setColor(0.80, 0.74, 0.54, 0.6)
    love.graphics.ellipse("fill", 0, 0, self.width * 0.4, self.height * 0.3)
    
    -- Highlight on top
    love.graphics.setColor(0.85, 0.79, 0.59, 0.4)
    love.graphics.ellipse("fill", 0, -5, self.width * 0.3, self.height * 0.2)
    
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function Sand:drawPreview(x, y, alpha)
    alpha = alpha or 0.6
    
    love.graphics.push()
    love.graphics.translate(x, y)
    
    -- Semi-transparent preview
    love.graphics.setColor(0.76, 0.70, 0.50, alpha * 0.5)
    love.graphics.rectangle("fill", -self.width/2, -self.height/2, self.width, self.height, 5)
    
    love.graphics.setColor(0.80, 0.74, 0.54, alpha * 0.3)
    love.graphics.ellipse("fill", 0, 0, self.width * 0.4, self.height * 0.3)
    
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function Sand:setPosition(x, y)
    self.x = x
    self.y = y
end

function Sand:getPosition()
    return self.x, self.y
end

function Sand:getBounds()
    return self.x - self.width/2, self.y - self.height/2, self.width, self.height
end

function Sand:checkCollision(other)
    if not other or not self.active then return false end
    
    -- Simple circle-based collision for now
    local dx = self.x - other.x
    local dy = self.y - other.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    local myRadius = math.min(self.width, self.height) / 2
    local otherRadius = other.radius or math.min(other.width or 50, other.height or 50) / 2
    
    return distance < (myRadius + otherRadius)
end

return Sand