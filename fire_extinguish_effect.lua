local FireExtinguishEffect = {}
FireExtinguishEffect.__index = FireExtinguishEffect

function FireExtinguishEffect:new(x, y, options)
    local self = setmetatable({}, FireExtinguishEffect)
    
    options = options or {}
    
    self.x = x or 0
    self.y = y or 0
    self.particles = {}
    self.time = 0
    self.lifetime = 0
    self.maxLifetime = options.duration or 1.5
    self.active = true
    
    -- Create initial burst of smoke and steam
    self:createExtinguishBurst()
    
    return self
end

function FireExtinguishEffect:createExtinguishBurst()
    -- Create white/gray smoke particles that rise up
    for i = 1, 60 do
        local angle = math.random() * math.pi * 2
        local speed = 50 + math.random() * 100
        local distance = math.random() * 30
        
        table.insert(self.particles, {
            x = math.cos(angle) * distance,
            y = math.sin(angle) * distance * 0.5 - 10,
            vx = math.cos(angle) * speed * 0.5,
            vy = -100 - math.random() * 150,  -- Strong upward movement
            life = 0,
            maxLife = 1.2 + math.random() * 0.8,
            size = 8 + math.random() * 15,
            type = "smoke",
            rotation = math.random() * math.pi * 2,
            rotSpeed = (math.random() - 0.5) * 3,
            opacity = 0.8 + math.random() * 0.2
        })
    end
    
    -- Add some quick white steam puffs
    for i = 1, 30 do
        local angle = math.random() * math.pi * 2
        local speed = 100 + math.random() * 150
        
        table.insert(self.particles, {
            x = 0,
            y = 0,
            vx = math.cos(angle) * speed,
            vy = -150 - math.random() * 100,
            life = 0,
            maxLife = 0.6 + math.random() * 0.4,
            size = 10 + math.random() * 10,
            type = "steam",
            rotation = 0,
            rotSpeed = (math.random() - 0.5) * 4,
            opacity = 1.0
        })
    end
    
    -- Some embers that quickly fade
    for i = 1, 20 do
        local angle = math.random() * math.pi * 2
        local speed = 80 + math.random() * 120
        
        table.insert(self.particles, {
            x = (math.random() - 0.5) * 20,
            y = (math.random() - 0.5) * 10,
            vx = math.cos(angle) * speed,
            vy = -50 - math.random() * 100,
            life = 0,
            maxLife = 0.4 + math.random() * 0.3,
            size = 2 + math.random() * 3,
            type = "ember",
            opacity = 1.0
        })
    end
end

function FireExtinguishEffect:update(dt)
    if not self.active then return end
    
    self.time = self.time + dt
    self.lifetime = self.lifetime + dt
    
    if self.lifetime > self.maxLifetime then
        self.active = false
        return
    end
    
    -- Update particles
    for i = #self.particles, 1, -1 do
        local particle = self.particles[i]
        particle.life = particle.life + dt
        
        if particle.life >= particle.maxLife then
            table.remove(self.particles, i)
        else
            local lifeRatio = particle.life / particle.maxLife
            
            if particle.type == "smoke" then
                -- Smoke rises and expands
                particle.vx = particle.vx * (1 - dt * 1.2)
                particle.vy = particle.vy - 80 * dt * (1 - lifeRatio)
                particle.size = particle.size + dt * 25 * lifeRatio
                
            elseif particle.type == "steam" then
                -- Steam rises quickly
                particle.vx = particle.vx * (1 - dt * 2.5)
                particle.vy = particle.vy - 120 * dt
                particle.size = particle.size + dt * 20
                
            elseif particle.type == "ember" then
                -- Embers fall after initial rise
                particle.vx = particle.vx * (1 - dt * 2)
                particle.vy = particle.vy + 100 * dt
                particle.size = particle.size * (1 - dt * 2)
            end
            
            -- Update position
            particle.x = particle.x + particle.vx * dt
            particle.y = particle.y + particle.vy * dt
            
            -- Rotate
            if particle.rotSpeed then
                particle.rotation = particle.rotation + particle.rotSpeed * dt * (1 - lifeRatio * 0.5)
            end
            
            -- Fade out
            particle.opacity = particle.opacity * (1 - lifeRatio * lifeRatio * 0.8)
        end
    end
end

function FireExtinguishEffect:draw()
    if not self.active and #self.particles == 0 then return end
    
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    -- Sort particles by type (embers first, then smoke, then steam)
    table.sort(self.particles, function(a, b)
        if a.type == b.type then
            return a.y > b.y
        end
        return a.type == "ember"
    end)
    
    for _, particle in ipairs(self.particles) do
        local lifeRatio = particle.life / particle.maxLife
        
        love.graphics.push()
        love.graphics.translate(particle.x, particle.y)
        if particle.rotation then
            love.graphics.rotate(particle.rotation)
        end
        
        local alpha = particle.opacity
        
        if particle.type == "smoke" then
            -- Gray/white smoke
            local gray = 0.7 + lifeRatio * 0.3
            
            love.graphics.setColor(gray, gray, gray, alpha * 0.1)
            love.graphics.circle("fill", 0, 0, particle.size * 1.8)
            
            love.graphics.setColor(gray * 0.95, gray * 0.95, gray, alpha * 0.2)
            love.graphics.circle("fill", particle.size * 0.2, -particle.size * 0.1, particle.size * 1.4)
            
            love.graphics.setColor(gray * 0.9, gray * 0.9, gray * 0.95, alpha * 0.3)
            love.graphics.circle("fill", 0, 0, particle.size)
            
        elseif particle.type == "steam" then
            -- White steam
            love.graphics.setColor(0.9, 0.95, 1, alpha * 0.15)
            love.graphics.circle("fill", 0, 0, particle.size * 1.5)
            
            love.graphics.setColor(0.95, 0.98, 1, alpha * 0.3)
            love.graphics.circle("fill", 0, 0, particle.size)
            
            love.graphics.setColor(1, 1, 1, alpha * 0.5)
            love.graphics.circle("fill", -particle.size * 0.2, -particle.size * 0.2, particle.size * 0.5)
            
        elseif particle.type == "ember" then
            -- Orange/red embers that fade to black
            local heat = 1 - lifeRatio
            love.graphics.setColor(heat, heat * 0.4, 0, alpha)
            love.graphics.circle("fill", 0, 0, particle.size)
        end
        
        love.graphics.pop()
    end
    
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function FireExtinguishEffect:isDone()
    return not self.active and #self.particles == 0
end

return FireExtinguishEffect