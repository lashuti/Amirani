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

function Fire:respawnParticle(particle)
    particle.life = 0
    
    if particle.type == "flame" then
        particle.x = (math.random() - 0.5) * self.width * 0.3
        particle.y = math.random() * 10
        particle.vx = (math.random() - 0.5) * 10
        particle.vy = -20 - math.random() * 30
        particle.size = 4 + math.random() * 6
        particle.heat = 0.8 + math.random() * 0.2
    elseif particle.type == "outer_flame" then
        particle.x = (math.random() - 0.5) * self.width * 0.8
        particle.y = math.random() * 5
        particle.vx = (math.random() - 0.5) * 20
        particle.vy = -10 - math.random() * 20
        particle.size = 3 + math.random() * 5
        particle.heat = 0.5 + math.random() * 0.3
    elseif particle.type == "ember" then
        particle.x = (math.random() - 0.5) * self.width * 0.2
        particle.y = 0
        particle.vx = (math.random() - 0.5) * 60
        particle.vy = -80 - math.random() * 120
        particle.size = 1 + math.random() * 2
        particle.heat = 1.0
    elseif particle.type == "smoke" then
        particle.x = (math.random() - 0.5) * self.width * 0.3
        particle.y = -10 - math.random() * 20
        particle.vx = (math.random() - 0.5) * 15
        particle.vy = -5 - math.random() * 10
        particle.size = 1 + math.random() * 2
        particle.rotation = math.random() * math.pi * 2
        particle.rotSpeed = (math.random() - 0.5) * 2
    end
end

function Fire:initializeParticles()
    -- Core flames
    for i = 1, 120 do
        table.insert(self.particles, {
            x = (math.random() - 0.5) * self.width * 0.3,
            y = math.random() * 10,
            vx = 0,
            vy = 0,
            life = math.random(),
            maxLife = 0.6 + math.random() * 0.8,
            size = 4 + math.random() * 6,
            type = "flame",
            heat = 0.8 + math.random() * 0.2
        })
    end
    
    -- Outer flames
    for i = 1, 60 do
        table.insert(self.particles, {
            x = (math.random() - 0.5) * self.width * 0.8,
            y = math.random() * 5,
            vx = 0,
            vy = 0,
            life = math.random(),
            maxLife = 0.4 + math.random() * 0.6,
            size = 3 + math.random() * 5,
            type = "outer_flame",
            heat = 0.5 + math.random() * 0.3
        })
    end
    
    -- Embers and sparks
    for i = 1, 30 do
        table.insert(self.particles, {
            x = (math.random() - 0.5) * self.width * 0.2,
            y = 0,
            vx = (math.random() - 0.5) * 40,
            vy = -50 - math.random() * 100,
            life = math.random(),
            maxLife = 1.0 + math.random() * 1.5,
            size = 1 + math.random() * 2,
            type = "ember",
            heat = 1.0
        })
    end
    
    -- Smoke particles
    for i = 1, 60 do
        table.insert(self.particles, {
            x = (math.random() - 0.5) * self.width * 0.3,
            y = -10 - math.random() * 20,
            vx = 0,
            vy = 0,
            life = math.random() * 0.5,
            maxLife = 3.0 + math.random() * 2.0,
            size = 1 + math.random() * 2,
            type = "smoke",
            heat = 0,
            rotation = math.random() * math.pi * 2,
            rotSpeed = (math.random() - 0.5) * 2
        })
    end
end

function Fire:update(dt, targets)
    if not self.active then return end
    
    self.time = self.time + dt
    
    for _, particle in ipairs(self.particles) do
        particle.life = particle.life + dt
        
        if particle.life >= particle.maxLife then
            self:respawnParticle(particle)
        end
        
        local lifeRatio = particle.life / particle.maxLife
        
        if particle.type == "flame" or particle.type == "outer_flame" then
            -- Turbulent upward movement
            local turbulence = 150 * (1 - lifeRatio)
            particle.vx = particle.vx + (math.random() - 0.5) * turbulence * dt
            particle.vx = particle.vx * 0.92
            
            -- Rising acceleration with flickering
            local rise = 120 + math.sin(self.time * 10 + particle.x) * 20
            particle.vy = particle.vy - rise * dt * self.intensity
            
            -- Natural fire spread at top
            if lifeRatio > 0.5 then
                particle.vx = particle.vx + (particle.x > 0 and 1 or -1) * 30 * dt
            end
            
        elseif particle.type == "ember" then
            -- Sparks fly upward and outward
            particle.vx = particle.vx * 0.98
            particle.vy = particle.vy - 20 * dt
            
            if lifeRatio > 0.7 then
                particle.vy = particle.vy - 100 * dt
            end
            
        elseif particle.type == "smoke" then
            -- Smoke physics
            particle.vx = particle.vx + (math.random() - 0.5) * 30 * dt
            particle.vx = particle.vx * 0.98
            
            -- Smoke rises slowly at first, then faster
            local riseSpeed = 15 + lifeRatio * 40
            particle.vy = particle.vy - riseSpeed * dt
            
            -- Expand and rotate
            particle.size = particle.size + dt * 3 * (1 + lifeRatio * 0.5)
            particle.rotation = particle.rotation + particle.rotSpeed * dt
            
            -- Smoke disperses horizontally as it rises
            if lifeRatio > 0.5 then
                particle.vx = particle.vx + (particle.x > 0 and 1 or -1) * 20 * dt
            end
        end
        
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        
        -- Organic wind effect
        local wind = math.sin(self.time * 1.5 + particle.y * 0.02) * 10 * (1 + lifeRatio)
        particle.x = particle.x + wind * dt
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
    
    -- Sort particles by y position for proper layering
    table.sort(self.particles, function(a, b) return a.y > b.y end)
    
    for _, particle in ipairs(self.particles) do
        local lifeRatio = particle.life / particle.maxLife
        local size = particle.size * self.scale
        
        if particle.type == "smoke" then
            -- Smoke gets larger and more transparent
            size = size * (1 + lifeRatio * 1.5)
            
            -- Multi-layered smoke for depth
            local alpha = 0.3 * (1 - lifeRatio)
            
            -- Smoke color changes from dark gray to light gray as it rises
            local grayLevel = 0.15 + lifeRatio * 0.25
            
            -- Add orange tint to smoke near fire
            local orangeTint = math.max(0, 1 - particle.y / -50) * 0.3
            
            -- Draw multiple circles for softer smoke
            love.graphics.push()
            love.graphics.translate(particle.x, particle.y)
            love.graphics.rotate(particle.rotation or 0)
            
            -- Outer soft layer
            love.graphics.setColor(grayLevel + orangeTint, grayLevel, grayLevel * 1.1, alpha * 0.2)
            love.graphics.circle("fill", 0, 0, size * 1.5)
            
            -- Middle layer with irregular shape
            love.graphics.setColor(grayLevel * 0.9 + orangeTint * 0.8, grayLevel * 0.9, grayLevel, alpha * 0.3)
            love.graphics.circle("fill", size * 0.2, -size * 0.1, size * 1.2)
            love.graphics.circle("fill", -size * 0.2, size * 0.1, size * 1.1)
            love.graphics.circle("fill", size * 0.1, size * 0.2, size)
            
            -- Core
            love.graphics.setColor(grayLevel * 0.8 + orangeTint * 0.6, grayLevel * 0.8, grayLevel * 0.85, alpha * 0.4)
            love.graphics.circle("fill", 0, 0, size * 0.8)
            
            -- Extra detail for volume
            love.graphics.setColor(grayLevel * 0.7 + orangeTint * 0.4, grayLevel * 0.7, grayLevel * 0.75, alpha * 0.2)
            love.graphics.circle("fill", -size * 0.3, -size * 0.2, size * 0.6)
            love.graphics.circle("fill", size * 0.3, size * 0.2, size * 0.5)
            
            love.graphics.pop()
            
        elseif particle.type == "ember" then
            -- Bright sparks that fade
            size = size * (1 - lifeRatio * 0.7)
            local brightness = 1 - lifeRatio * 0.5
            love.graphics.setColor(1, 0.9 * brightness, 0.3 * brightness, brightness)
            love.graphics.circle("fill", particle.x, particle.y, size)
            
        else
            -- Flames with realistic color temperature
            local heat = particle.heat or 1.0
            size = size * (1 - lifeRatio * 0.4)
            
            local r, g, b, a
            
            if lifeRatio < 0.15 then
                -- White hot core
                local t = lifeRatio / 0.15
                r, g, b = 1, 1, 0.95 - t * 0.2
                a = t
            elseif lifeRatio < 0.3 then
                -- Yellow hot
                local t = (lifeRatio - 0.15) / 0.15
                r = 1
                g = 1 - t * 0.2
                b = 0.75 - t * 0.5
                a = 1
            elseif lifeRatio < 0.6 then
                -- Orange
                local t = (lifeRatio - 0.3) / 0.3
                r = 1
                g = 0.8 - t * 0.4
                b = 0.25 - t * 0.25
                a = 1 - t * 0.2
            else
                -- Red to transparent
                local t = (lifeRatio - 0.6) / 0.4
                r = 1 - t * 0.3
                g = 0.4 - t * 0.4
                b = 0
                a = 0.8 - t * 0.8
            end
            
            -- Apply heat intensity
            a = a * heat
            
            -- Inner glow
            if particle.type == "flame" and lifeRatio < 0.4 then
                love.graphics.setColor(r, g, b, a * 0.3)
                love.graphics.circle("fill", particle.x, particle.y, size * 2)
            end
            
            -- Main particle
            love.graphics.setColor(r, g, b, a)
            love.graphics.circle("fill", particle.x, particle.y, size)
        end
    end
    
    -- Base glow
    love.graphics.setColor(1, 0.4, 0, 0.15)
    love.graphics.ellipse("fill", 0, 10, self.width * 1.2, self.width * 0.4)
    
    -- Hot spot at base
    love.graphics.setColor(1, 0.8, 0.2, 0.3)
    love.graphics.ellipse("fill", 0, 5, self.width * 0.6, self.width * 0.2)
    
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