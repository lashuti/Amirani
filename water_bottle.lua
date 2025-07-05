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
        waterAngle = 0
    }
    
    self.update = waterBottle.update
    self.draw = waterBottle.draw
    self.startDrag = waterBottle.startDrag
    self.stopDrag = waterBottle.stopDrag
    
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
end

return waterBottle