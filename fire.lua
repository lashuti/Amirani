local Fire = {}
Fire.__index = Fire

function Fire:new(x, y, options)
    local self = setmetatable({}, Fire)
    
    options = options or {}
    
    self.x = x or 0
    self.y = y or 0
    self.width = options.width or 60
    self.height = options.height or 100
    self.scale = options.scale or 1
    
    self.damagePerTick = options.damagePerTick or 10
    self.damageInterval = options.damageInterval or 0.5
    self.lastDamageTime = 0
    self.currentDamageTargets = {}
    
    self.collisionRadius = options.collisionRadius or (self.width * 0.4 * self.scale)
    self.collisionOffsetY = options.collisionOffsetY or -20
    
    self.particles = {}
    self.time = 0
    
    self:initializeParticles()
    
    self.active = true
    self.intensity = options.intensity or 1.0
    
    return self
end

function Fire:initializeParticles()
    for i = 1, 80 do
        table.insert(self.particles, {
            x = (math.random() - 0.5) * self.width,
            y = 0,
            vx = 0,
            vy = 0,
            life = math.random(),
            maxLife = 0.8 + math.random() * 0.7,
            size = 3 + math.random() * 4,
            type = "flame"
        })
    end
    
    for i = 1, 40 do
        table.insert(self.particles, {
            x = (math.random() - 0.5) * self.width * 0.5,
            y = 0,
            vx = 0,
            vy = 0,
            life = math.random(),
            maxLife = 0.5 + math.random() * 0.5,
            size = 2 + math.random() * 3,
            type = "ember"
        })
    end
end

function Fire:update(dt, targets)
    if not self.active then return end
    
    self.time = self.time + dt
    
    for _, particle in ipairs(self.particles) do
        particle.life = particle.life + dt
        
        if particle.life >= particle.maxLife then
            particle.life = 0
            particle.x = (math.random() - 0.5) * self.width * 0.8
            particle.y = 0
            particle.vx = (math.random() - 0.5) * 20
            particle.vy = -30 - math.random() * 50
            particle.size = 3 + math.random() * 4
        end
        
        local lifeRatio = particle.life / particle.maxLife
        
        particle.vx = particle.vx + (math.random() - 0.5) * 100 * dt
        particle.vx = particle.vx * 0.95
        
        particle.vy = particle.vy - (80 + math.random() * 40) * dt * self.intensity
        
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        
        local wind = math.sin(self.time * 2 + particle.life * 3) * 15
        particle.x = particle.x + wind * dt
        
        if particle.type == "ember" and lifeRatio > 0.7 then
            particle.vy = particle.vy - 50 * dt
        end
    end
    
    if targets then
        for _, target in ipairs(targets) do
            self:checkCollision(target)
        end
    end
    
    self:processDamage(dt)
end

function Fire:draw()
    if not self.active then return end
    
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    for _, particle in ipairs(self.particles) do
        local lifeRatio = particle.life / particle.maxLife
        local size = particle.size * (1 - lifeRatio * 0.5) * self.scale
        
        local r, g, b, a
        
        if lifeRatio < 0.2 then
            r, g, b = 1, 0.1, 0
            a = (lifeRatio / 0.2)
        elseif lifeRatio < 0.5 then
            local t = (lifeRatio - 0.2) / 0.3
            r = 1
            g = 0.1 + 0.4 * t
            b = 0
            a = 1
        elseif lifeRatio < 0.8 then
            local t = (lifeRatio - 0.5) / 0.3
            r = 1
            g = 0.5 + 0.3 * t
            b = 0 + 0.2 * t
            a = 1 - t * 0.3
        else
            local t = (lifeRatio - 0.8) / 0.2
            r = 1
            g = 0.8 + 0.2 * t
            b = 0.2 + 0.5 * t
            a = 0.7 - t * 0.7
        end
        
        if particle.type == "ember" then
            a = a * 1.2
            size = size * 0.6
        end
        
        love.graphics.setColor(r, g, b, a * 0.8)
        love.graphics.circle("fill", particle.x, particle.y, size)
        
        if particle.type == "flame" and lifeRatio < 0.5 then
            love.graphics.setColor(r, g * 0.8, b, a * 0.4)
            love.graphics.circle("fill", particle.x, particle.y, size * 1.5)
        end
    end
    
    love.graphics.setColor(1, 0.3, 0, 0.2)
    love.graphics.ellipse("fill", 0, 5, self.width * 0.8, self.width * 0.3)
    
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function Fire:drawDebug()
    love.graphics.setColor(1, 0, 0, 0.3)
    love.graphics.circle("line", self.x, self.y + self.collisionOffsetY, self.collisionRadius)
    love.graphics.setColor(1, 1, 1, 1)
end

function Fire:checkCollision(target)
    if not self.active or not target then return false end
    
    local tx, ty = target.x or 0, target.y or 0
    
    local dx = tx - self.x
    local dy = ty - (self.y + self.collisionOffsetY)
    local distance = math.sqrt(dx * dx + dy * dy)
    
    local targetRadius = target.radius or 20
    local isColliding = distance < (self.collisionRadius + targetRadius)
    
    if isColliding then
        if not self.currentDamageTargets[target] then
            self.currentDamageTargets[target] = {
                startTime = love.timer.getTime(),
                lastDamageTime = 0
            }
            if target.onFireEnter then
                target:onFireEnter(self)
            end
        end
    else
        if self.currentDamageTargets[target] then
            self.currentDamageTargets[target] = nil
            if target.onFireExit then
                target:onFireExit(self)
            end
        end
    end
    
    return isColliding
end

function Fire:processDamage(dt)
    local currentTime = love.timer.getTime()
    
    for target, damageInfo in pairs(self.currentDamageTargets) do
        if currentTime - damageInfo.lastDamageTime >= self.damageInterval then
            self:applyDamage(target)
            damageInfo.lastDamageTime = currentTime
        end
    end
end

function Fire:applyDamage(target)
    if target.takeDamage then
        target:takeDamage(self.damagePerTick, "fire", self)
    elseif target.hp then
        target.hp = math.max(0, target.hp - self.damagePerTick)
    end
end

function Fire:setIntensity(intensity)
    self.intensity = math.max(0, math.min(2, intensity))
    self.damagePerTick = 10 * self.intensity
end

function Fire:setActive(active)
    self.active = active
    if not active then
        self.currentDamageTargets = {}
    end
end

function Fire:setPosition(x, y)
    self.x = x
    self.y = y
end

function Fire:destroy()
    self.active = false
    self.currentDamageTargets = {}
    self.particles = {}
end

return Fire