local DustEffect = {}
DustEffect.__index = DustEffect

function DustEffect:new(x, y, options)
    local self = setmetatable({}, DustEffect)
    
    options = options or {}
    
    self.x = x or 0
    self.y = y or 0
    self.particles = {}
    self.time = 0
    self.lifetime = 0
    self.maxLifetime = options.duration or 2.0
    self.active = true
    self.intensity = options.intensity or 1.0
    
    -- Create initial dust burst
    self:createDustBurst()
    
    return self
end

function DustEffect:createDustBurst()
    -- Create dust particles that spread outward and settle
    for i = 1, 80 do
        local angle = math.random() * math.pi * 2
        local speed = 50 + math.random() * 150
        local distance = math.random() * 20
        
        table.insert(self.particles, {
            x = math.cos(angle) * distance,
            y = math.sin(angle) * distance * 0.5,
            vx = math.cos(angle) * speed,
            vy = -math.random() * 100 - 50,  -- Upward burst
            life = 0,
            maxLife = 1.0 + math.random() * 1.0,
            size = 10 + math.random() * 20,
            type = "dust",
            rotation = math.random() * math.pi * 2,
            rotSpeed = (math.random() - 0.5) * 2,
            opacity = 0.6 + math.random() * 0.3,
            color = 0.5 + math.random() * 0.2  -- Brown variation
        })
    end
    
    -- Add some smaller, faster particles
    for i = 1, 40 do
        local angle = math.random() * math.pi * 2
        local speed = 100 + math.random() * 100
        
        table.insert(self.particles, {
            x = 0,
            y = 0,
            vx = math.cos(angle) * speed,
            vy = -math.random() * 150 - 100,
            life = 0,
            maxLife = 0.5 + math.random() * 0.5,
            size = 5 + math.random() * 10,
            type = "dust_fast",
            rotation = 0,
            rotSpeed = (math.random() - 0.5) * 4,
            opacity = 0.8,
            color = 0.6 + math.random() * 0.1
        })
    end
    
    -- Ground dust that spreads horizontally
    for i = 1, 60 do
        local angle = math.random() * math.pi * 2
        local speed = 80 + math.random() * 80
        
        table.insert(self.particles, {
            x = (math.random() - 0.5) * 40,
            y = math.random() * 10,
            vx = math.cos(angle) * speed,
            vy = -math.random() * 30,
            life = 0,
            maxLife = 1.5 + math.random() * 0.5,
            size = 15 + math.random() * 15,
            type = "dust_ground",
            rotation = 0,
            rotSpeed = (math.random() - 0.5) * 1,
            opacity = 0.4,
            color = 0.45 + math.random() * 0.15
        })
    end
end

function DustEffect:update(dt)
    if not self.active then return end
    
    self.time = self.time + dt
    self.lifetime = self.lifetime + dt
    
    -- Remove effect after max lifetime
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
            
            -- Physics based on particle type
            if particle.type == "dust" then
                -- Regular dust settles down
                particle.vx = particle.vx * (1 - dt * 1.5)
                particle.vy = particle.vy + 150 * dt  -- Gravity
                
                -- Expand as it settles
                particle.size = particle.size + dt * 10 * lifeRatio
                
            elseif particle.type == "dust_fast" then
                -- Fast particles slow down quickly
                particle.vx = particle.vx * (1 - dt * 3)
                particle.vy = particle.vy + 200 * dt
                
                -- Shrink faster
                particle.size = particle.size * (1 - dt * 0.5)
                
            elseif particle.type == "dust_ground" then
                -- Ground dust spreads out
                particle.vx = particle.vx * (1 - dt * 2)
                particle.vy = math.min(50, particle.vy + 100 * dt)
                
                -- Expand significantly
                particle.size = particle.size + dt * 30 * lifeRatio
            end
            
            -- Update position
            particle.x = particle.x + particle.vx * dt
            particle.y = particle.y + particle.vy * dt
            
            -- Rotate
            if particle.rotSpeed then
                particle.rotation = particle.rotation + particle.rotSpeed * dt * (1 - lifeRatio * 0.5)
            end
            
            -- Fade out
            particle.opacity = particle.opacity * (1 - lifeRatio * lifeRatio * 0.9)
        end
    end
end

function DustEffect:draw()
    if not self.active and #self.particles == 0 then return end
    
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    -- Sort particles by y for proper layering
    table.sort(self.particles, function(a, b) return a.y < b.y end)
    
    for _, particle in ipairs(self.particles) do
        local lifeRatio = particle.life / particle.maxLife
        
        love.graphics.push()
        love.graphics.translate(particle.x, particle.y)
        if particle.rotation then
            love.graphics.rotate(particle.rotation)
        end
        
        -- Dust color (sandy/brown)
        local color = particle.color or 0.5
        local alpha = particle.opacity
        
        if particle.type == "dust_ground" then
            -- Ground dust is more transparent and spread out
            love.graphics.setColor(color * 0.9, color * 0.8, color * 0.6, alpha * 0.3)
            love.graphics.ellipse("fill", 0, 0, particle.size * 1.5, particle.size * 0.7)
        else
            -- Regular dust clouds
            -- Multiple layers for volume
            love.graphics.setColor(color * 0.8, color * 0.7, color * 0.5, alpha * 0.1)
            love.graphics.circle("fill", 0, 0, particle.size * 1.8)
            
            love.graphics.setColor(color * 0.85, color * 0.75, color * 0.55, alpha * 0.2)
            love.graphics.circle("fill", particle.size * 0.2, -particle.size * 0.1, particle.size * 1.4)
            
            love.graphics.setColor(color * 0.9, color * 0.8, color * 0.6, alpha * 0.3)
            love.graphics.circle("fill", 0, 0, particle.size)
            
            -- Center highlight
            love.graphics.setColor(color * 0.95, color * 0.85, color * 0.65, alpha * 0.4)
            love.graphics.circle("fill", -particle.size * 0.1, -particle.size * 0.1, particle.size * 0.6)
        end
        
        love.graphics.pop()
    end
    
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function DustEffect:isDone()
    return not self.active and #self.particles == 0
end

return DustEffect