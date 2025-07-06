local SteamEffect = {}
SteamEffect.__index = SteamEffect

function SteamEffect:new(x, y, options)
    local self = setmetatable({}, SteamEffect)
    
    options = options or {}
    
    self.x = x or 0
    self.y = y or 0
    self.particles = {}
    self.time = 0
    self.lifetime = 0
    self.maxLifetime = options.duration or 4.0
    self.active = true
    self.intensity = options.intensity or 1.0
    
    -- Create initial burst of steam particles
    self:createInitialBurst()
    
    return self
end

function SteamEffect:createInitialBurst()
    -- Initial violent burst from water hitting hot surface
    for i = 1, 30 do
        local angle = math.random() * math.pi * 2
        local speed = 100 + math.random() * 200
        local distance = math.random() * 10  -- Start closer to center
        
        table.insert(self.particles, {
            x = math.cos(angle) * distance,
            y = math.sin(angle) * distance * 0.3,
            vx = math.cos(angle) * speed * 0.7,
            vy = -math.abs(speed) * 0.8 - 100,  -- Strong upward burst
            life = 0,
            maxLife = 0.8 + math.random() * 0.4,
            size = 3 + math.random() * 5,
            type = "hot_steam",
            rotation = math.random() * math.pi * 2,
            rotSpeed = (math.random() - 0.5) * 5,
            opacity = 1.0,
            temperature = 1.0  -- Hot at start
        })
    end
    
    -- Dense steam cloud
    for i = 1, 60 do
        local angle = math.random() * math.pi * 2
        local speed = 30 + math.random() * 80
        local distance = math.random() * 25
        
        table.insert(self.particles, {
            x = math.cos(angle) * distance,
            y = math.sin(angle) * distance * 0.5 - 10,
            vx = math.cos(angle) * speed * 0.5,
            vy = -60 - math.random() * 80,
            life = 0,
            maxLife = 2.0 + math.random() * 1.5,
            size = 6 + math.random() * 10,
            type = "steam",
            rotation = math.random() * math.pi * 2,
            rotSpeed = (math.random() - 0.5) * 2,
            opacity = 0.9,
            temperature = 0.7 + math.random() * 0.3
        })
    end
    
    -- Water droplets that quickly evaporate
    for i = 1, 20 do
        local angle = math.random() * math.pi * 2
        local speed = 150 + math.random() * 100
        
        table.insert(self.particles, {
            x = 0,
            y = 0,
            vx = math.cos(angle) * speed,
            vy = -50 - math.random() * 100,
            life = 0,
            maxLife = 0.3 + math.random() * 0.2,
            size = 2 + math.random() * 3,
            type = "droplet",
            rotation = 0,
            rotSpeed = 0,
            opacity = 1.0,
            temperature = 0.5
        })
    end
    
    -- Condensation mist that forms later
    for i = 1, 40 do
        table.insert(self.particles, {
            x = (math.random() - 0.5) * 50,
            y = (math.random() - 0.5) * 30 - 20,
            vx = (math.random() - 0.5) * 20,
            vy = -20 - math.random() * 40,
            life = -0.5 - math.random() * 0.5,  -- Delayed start
            maxLife = 3.0 + math.random() * 1.0,
            size = 8 + math.random() * 15,
            type = "mist",
            rotation = math.random() * math.pi * 2,
            rotSpeed = (math.random() - 0.5) * 1,
            opacity = 0.4,
            temperature = 0.3
        })
    end
end

function SteamEffect:update(dt)
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
        
        if particle.life < 0 then
            -- Particle hasn't started yet (delayed particles)
            goto continue
        end
        
        if particle.life >= particle.maxLife then
            table.remove(self.particles, i)
        else
            local lifeRatio = particle.life / particle.maxLife
            
            -- Cool down over time
            if particle.temperature then
                particle.temperature = particle.temperature * (1 - dt * 0.5)
            end
            
            -- Physics based on particle type
            if particle.type == "hot_steam" then
                -- Initial violent burst
                particle.vx = particle.vx * (1 - dt * 2.5)  -- Quick horizontal damping
                particle.vy = particle.vy - 200 * dt * (1 - lifeRatio * 0.8)  -- Strong rise
                
                -- Rapid expansion
                particle.size = particle.size + dt * 40 * (1 - lifeRatio)
                
                -- Turbulence
                local turbulence = 200 * (1 - lifeRatio)
                particle.vx = particle.vx + (math.random() - 0.5) * turbulence * dt
                
            elseif particle.type == "steam" then
                -- Main steam body - realistic convection
                local buoyancy = 80 * (particle.temperature or 0.5)
                particle.vy = particle.vy - buoyancy * dt
                
                -- Air resistance
                particle.vx = particle.vx * (1 - dt * 0.6)
                particle.vy = particle.vy * (1 - dt * 0.3)
                
                -- Expansion due to pressure decrease
                local expansionRate = 15 + lifeRatio * 25
                particle.size = particle.size + dt * expansionRate
                
                -- Convection currents
                local convection = math.sin(self.time * 3 + particle.x * 0.05) * 30
                particle.x = particle.x + convection * dt * (1 - lifeRatio)
                
                -- Mushroom cloud effect - spread at top
                if particle.y < -50 then
                    particle.vx = particle.vx + (particle.x > 0 and 1 or -1) * 20 * dt
                end
                
            elseif particle.type == "droplet" then
                -- Water droplets that evaporate
                particle.vx = particle.vx * (1 - dt * 4)
                particle.vy = particle.vy + 200 * dt  -- Gravity initially
                
                -- Quick evaporation
                particle.size = particle.size * (1 - dt * 3)
                
            elseif particle.type == "mist" then
                -- Condensation mist
                particle.vx = particle.vx * (1 - dt * 0.4)
                particle.vy = particle.vy - 30 * dt * (1 - lifeRatio * 0.7)
                
                -- Slow expansion
                particle.size = particle.size + dt * 8 * lifeRatio
                
                -- Gentle swirling
                local swirl = math.sin(self.time * 2 + particle.y * 0.03) * 15
                particle.x = particle.x + swirl * dt
            end
            
            -- Update position
            particle.x = particle.x + particle.vx * dt
            particle.y = particle.y + particle.vy * dt
            
            -- Rotate based on turbulence
            if particle.rotSpeed then
                particle.rotation = particle.rotation + particle.rotSpeed * dt * (1 - lifeRatio * 0.3)
            end
            
            -- Realistic opacity fade
            if particle.type == "hot_steam" then
                particle.opacity = particle.opacity * (1 - lifeRatio * 1.2)
            elseif particle.type == "droplet" then
                particle.opacity = particle.opacity * (1 - lifeRatio * 2)
            else
                particle.opacity = particle.opacity * (1 - lifeRatio * lifeRatio * 0.8)
            end
        end
        
        ::continue::
    end
    
    -- Secondary steam generation in first 0.5 seconds
    if self.lifetime < 0.5 and math.random() < dt * 15 then
        table.insert(self.particles, {
            x = (math.random() - 0.5) * 20,
            y = 0,
            vx = (math.random() - 0.5) * 40,
            vy = -80 - math.random() * 60,
            life = 0,
            maxLife = 1.5 + math.random() * 0.5,
            size = 5 + math.random() * 8,
            type = "steam",
            rotation = math.random() * math.pi * 2,
            rotSpeed = (math.random() - 0.5) * 2,
            opacity = 0.7,
            temperature = 0.6 + math.random() * 0.2
        })
    end
end

function SteamEffect:draw()
    if not self.active and #self.particles == 0 then return end
    
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    -- Sort particles by y for proper layering
    table.sort(self.particles, function(a, b) return a.y > b.y end)
    
    for _, particle in ipairs(self.particles) do
        if particle.life < 0 then goto continue end  -- Skip delayed particles
        
        local lifeRatio = particle.life / particle.maxLife
        
        love.graphics.push()
        love.graphics.translate(particle.x, particle.y)
        if particle.rotation then
            love.graphics.rotate(particle.rotation)
        end
        
        if particle.type == "hot_steam" then
            -- Very hot steam - almost white with slight yellow tint
            local temp = particle.temperature or 1.0
            local alpha = particle.opacity
            
            -- Outer heat haze
            love.graphics.setColor(1, 0.98, 0.9, alpha * 0.05)
            love.graphics.circle("fill", 0, 0, particle.size * 2.5)
            
            -- Hot glow
            love.graphics.setColor(1, 0.95 + temp * 0.05, 0.85 + temp * 0.1, alpha * 0.15)
            love.graphics.circle("fill", 0, 0, particle.size * 1.8)
            
            -- Core
            love.graphics.setColor(1, 1, 0.95 + temp * 0.05, alpha * 0.4)
            love.graphics.circle("fill", 0, 0, particle.size)
            
            -- Bright center
            love.graphics.setColor(1, 1, 1, alpha * 0.7)
            love.graphics.circle("fill", 0, 0, particle.size * 0.4)
            
        elseif particle.type == "steam" then
            -- Regular steam with temperature gradient
            local temp = particle.temperature or 0.5
            local alpha = particle.opacity
            
            -- Calculate color based on temperature
            local r = 0.85 + temp * 0.15
            local g = 0.9 + temp * 0.1
            local b = 0.95 + temp * 0.05
            
            -- Soft outer edge
            love.graphics.setColor(r, g, b, alpha * 0.08)
            love.graphics.circle("fill", 0, 0, particle.size * 2)
            
            -- Multiple overlapping circles for realistic volume
            love.graphics.setColor(r * 0.95, g * 0.98, b, alpha * 0.15)
            love.graphics.circle("fill", particle.size * 0.3, -particle.size * 0.2, particle.size * 1.5)
            love.graphics.circle("fill", -particle.size * 0.3, particle.size * 0.2, particle.size * 1.4)
            
            -- Main body
            love.graphics.setColor(r, g, b, alpha * 0.25)
            love.graphics.circle("fill", 0, 0, particle.size * 1.1)
            
            -- Dense center
            love.graphics.setColor(r * 1.05, g * 1.02, b * 1.01, alpha * 0.35)
            love.graphics.circle("fill", -particle.size * 0.1, -particle.size * 0.1, particle.size * 0.7)
            
            -- Highlight
            if temp > 0.5 then
                love.graphics.setColor(1, 1, 1, alpha * 0.2 * temp)
                love.graphics.circle("fill", -particle.size * 0.2, -particle.size * 0.2, particle.size * 0.3)
            end
            
        elseif particle.type == "droplet" then
            -- Water droplets
            local alpha = particle.opacity
            
            -- Droplet with refraction effect
            love.graphics.setColor(0.6, 0.8, 1, alpha * 0.6)
            love.graphics.circle("fill", 0, 0, particle.size)
            
            -- Highlight
            love.graphics.setColor(0.8, 0.9, 1, alpha)
            love.graphics.circle("fill", -particle.size * 0.3, -particle.size * 0.3, particle.size * 0.4)
            
        elseif particle.type == "mist" then
            -- Cool condensation mist
            local alpha = particle.opacity
            
            -- Very soft and diffuse
            love.graphics.setColor(0.8, 0.85, 0.9, alpha * 0.05)
            love.graphics.circle("fill", 0, 0, particle.size * 2.2)
            
            love.graphics.setColor(0.85, 0.88, 0.92, alpha * 0.1)
            love.graphics.circle("fill", particle.size * 0.2, particle.size * 0.1, particle.size * 1.6)
            
            love.graphics.setColor(0.9, 0.92, 0.95, alpha * 0.15)
            love.graphics.circle("fill", 0, 0, particle.size)
        end
        
        love.graphics.pop()
        ::continue::
    end
    
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function SteamEffect:isDone()
    return not self.active and #self.particles == 0
end

return SteamEffect