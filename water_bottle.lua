local waterBottle = {}

function waterBottle.new(x, y)
    local self = {
        x = x,
        y = y,
        width = 50,
        height = 80,
        waterLevel = 60,
        maxWater = 100,
        rotation = 0,
        velocityX = 0,
        velocityY = 0,
        prevMouseX = nil,
        prevMouseY = nil,
        isDragging = false,
        waterMomentum = 0,
        waterAngle = 0,
        shakeHistory = {},
        maxShakeHistory = 10,
        spillThreshold = 400,
        droplets = {},
        lastSoundTime = 0,
        soundCooldown = 0.3  -- Minimum time between splash sounds
    }
    
    self.update = waterBottle.update
    self.draw = waterBottle.draw
    self.startDrag = waterBottle.startDrag
    self.stopDrag = waterBottle.stopDrag
    self.spill = waterBottle.spill
    self.getDroplets = waterBottle.getDroplets
    
    return self
end

function waterBottle:update(dt)
    if self.isDragging then
        local mouseX, mouseY = love.mouse.getPosition()
        
        if self.prevMouseX and self.prevMouseY then
            local newVelX = (mouseX - self.prevMouseX) / dt
            local newVelY = (mouseY - self.prevMouseY) / dt
            
            self.velocityX = self.velocityX * 0.7 + newVelX * 0.3
            self.velocityY = self.velocityY * 0.7 + newVelY * 0.3
            
            -- Track shake history
            local velocity = math.sqrt(self.velocityX^2 + self.velocityY^2)
            table.insert(self.shakeHistory, velocity)
            if #self.shakeHistory > self.maxShakeHistory then
                table.remove(self.shakeHistory, 1)
            end
            
            -- Calculate average shake
            local avgShake = 0
            for _, v in ipairs(self.shakeHistory) do
                avgShake = avgShake + v
            end
            avgShake = avgShake / #self.shakeHistory
            
            -- Spill water if shaking too much
            if avgShake > self.spillThreshold and self.waterLevel > 0 then
                self:spill()
                
                -- Play water splash sound when water comes out (with cooldown)
                local currentTime = love.timer.getTime()
                if SoundManager and SoundManager.play and 
                   (currentTime - self.lastSoundTime) >= self.soundCooldown then
                    SoundManager:play("water", "splash2", 0.6)  -- water splash_02.wav
                    self.lastSoundTime = currentTime
                end
            end
            
            local targetRotation = math.atan2(self.velocityX, -self.velocityY) * 0.2
            targetRotation = math.max(-math.pi/3, math.min(math.pi/3, targetRotation))
            self.rotation = self.rotation * 0.85 + targetRotation * 0.15
        end
        
        self.x = self.x * 0.2 + mouseX * 0.8
        self.y = self.y * 0.2 + mouseY * 0.8
        self.prevMouseX = mouseX
        self.prevMouseY = mouseY
    else
        self.rotation = self.rotation * 0.92
        self.velocityX = self.velocityX * 0.88
        self.velocityY = self.velocityY * 0.88
    end
    
    -- Update water physics inside bottle
    local targetAngle = -self.rotation
    local angleDiff = targetAngle - self.waterAngle
    self.waterMomentum = self.waterMomentum * 0.9 + angleDiff * 3
    self.waterAngle = self.waterAngle + self.waterMomentum * dt
    
    -- Update droplets
    for i = #self.droplets, 1, -1 do
        local d = self.droplets[i]
        d.vx = d.vx * (1 - dt * 0.5)
        d.x = d.x + d.vx * dt
        d.y = d.y + d.vy * dt
        d.vy = d.vy + 600 * dt
        d.life = d.life - dt * 0.8
        
        if d.life <= 0 or d.y > 1000 then
            table.remove(self.droplets, i)
        end
    end
end

function waterBottle:startDrag()
    self.isDragging = true
    self.prevMouseX = nil
    self.prevMouseY = nil
    self.shakeHistory = {}
end

function waterBottle:stopDrag()
    self.isDragging = false
end

function waterBottle:spill()
    local spillAmount = math.min(5, self.waterLevel)
    self.waterLevel = self.waterLevel - spillAmount
    
    for i = 1, math.floor(spillAmount * 2) do
        local angleVariation = (math.random() - 0.5) * 0.8
        local angle = self.rotation + angleVariation
        local speed = 80 + math.random() * 120
        local offsetX = math.sin(angle) * 15
        local offsetY = 25
        
        table.insert(self.droplets, {
            x = self.x + offsetX,
            y = self.y + offsetY,
            vx = math.sin(angle) * speed + self.velocityX * 0.4,
            vy = math.cos(angle) * speed * 0.5 + 50,
            life = 1.5 + math.random() * 0.5,
            size = 3 + math.random() * 3,
            id = math.random() -- Unique ID for collision tracking
        })
    end
end

function waterBottle:getDroplets()
    return self.droplets
end


function waterBottle:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.rotation)
    
    -- Bottle shadow
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.ellipse("fill", 0, self.height/2 + 5, self.width * 0.8, 10)
    
    -- Bottle body
    love.graphics.setColor(0.95, 0.95, 0.98, 0.3)
    love.graphics.rectangle("fill", -self.width/2, -self.height/2, self.width, self.height, 8)
    
    -- Water inside bottle
    if self.waterLevel > 0 then
        love.graphics.setScissor(self.x - self.width, self.y - self.height, self.width * 2, self.height * 2)
        
        local waterHeight = (self.height - 15) * (self.waterLevel / self.maxWater)
        local baseY = self.height/2 - waterHeight - 5
        
        -- Calculate water tilt based on momentum
        local tiltAmount = self.waterAngle * 15
        local leftHeight = waterHeight + tiltAmount
        local rightHeight = waterHeight - tiltAmount
        
        -- Draw water as a tilted quadrilateral
        love.graphics.setColor(0.15, 0.45, 0.85, 0.7)
        local waterPoly = {
            -self.width/2 + 5, self.height/2 - 5,                    -- bottom left
            self.width/2 - 5, self.height/2 - 5,                     -- bottom right
            self.width/2 - 5, self.height/2 - rightHeight - 5,       -- top right
            -self.width/2 + 5, self.height/2 - leftHeight - 5        -- top left
        }
        love.graphics.polygon("fill", waterPoly)
        
        -- Water surface line
        love.graphics.setColor(0.3, 0.65, 1, 0.5)
        love.graphics.setLineWidth(3)
        love.graphics.line(-self.width/2 + 5, self.height/2 - leftHeight - 5,
                          self.width/2 - 5, self.height/2 - rightHeight - 5)
        love.graphics.setLineWidth(1)
        
        -- Small surface animation
        local time = love.timer.getTime()
        for i = 0, 3 do
            local x = -self.width/2 + 10 + i * 10
            local surfaceY = self.height/2 - waterHeight - 5 - tiltAmount * ((x + self.width/2 - 5) / (self.width - 10) * 2 - 1)
            local bobble = math.sin(time * 3 + i) * 1.5
            love.graphics.setColor(0.5, 0.75, 1, 0.3)
            love.graphics.circle("fill", x, surfaceY + bobble, 2)
        end
        
        love.graphics.setScissor()
    end
    
    -- Bottle outline
    love.graphics.setColor(0.65, 0.65, 0.75, 0.9)
    love.graphics.setLineWidth(2.5)
    love.graphics.rectangle("line", -self.width/2, -self.height/2, self.width, self.height, 8)
    
    -- Bottle highlights
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(-self.width/2 + 8, -self.height/2 + 10, 
                      -self.width/2 + 8, self.height/2 - 20)
    love.graphics.setLineWidth(1)
    
    love.graphics.setColor(0.6, 0.6, 0.7)
    love.graphics.rectangle("fill", -self.width/2 + 5, -self.height/2 - 5, self.width - 10, 10, 3)
    love.graphics.setColor(0.4, 0.4, 0.5)
    love.graphics.rectangle("line", -self.width/2 + 5, -self.height/2 - 5, self.width - 10, 10, 3)
    
    love.graphics.pop()
    
    -- Draw water droplets
    for _, d in ipairs(self.droplets) do
        local alpha = (d.life / 2) ^ 0.8
        love.graphics.push()
        love.graphics.translate(d.x, d.y)
        
        -- Droplet glow
        love.graphics.setColor(0.4, 0.7, 1, alpha * 0.3)
        love.graphics.circle("fill", 0, 0, d.size * 1.5)
        
        -- Main droplet
        love.graphics.setColor(0.3, 0.6, 1, alpha)
        love.graphics.circle("fill", 0, 0, d.size)
        
        -- Highlight
        love.graphics.setColor(0.6, 0.8, 1, alpha * 0.7)
        love.graphics.circle("fill", -d.size * 0.3, -d.size * 0.3, d.size * 0.4)
        
        love.graphics.pop()
    end
    
    -- Show spill indicator when shaking
    if self.isDragging and #self.shakeHistory > 0 then
        local avgShake = 0
        for _, v in ipairs(self.shakeHistory) do
            avgShake = avgShake + v
        end
        avgShake = avgShake / #self.shakeHistory
        
        if avgShake > self.spillThreshold * 0.7 then
            local warningAlpha = (avgShake - self.spillThreshold * 0.7) / (self.spillThreshold * 0.3)
            love.graphics.setColor(1, 0.3, 0.3, warningAlpha * 0.5)
            love.graphics.print("Careful!", self.x - 25, self.y - self.height/2 - 25)
        end
    end
end

return waterBottle