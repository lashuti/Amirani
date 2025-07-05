local Dog = {}
local dogImage

Dog.x = 200
Dog.y = 200
Dog.width = 60
Dog.height = 30
Dog.imageScale = 0.2
Dog.angle = 0
Dog.speed = 120                   -- pixels per second
Dog.rotationSpeed = math.rad(300) -- radians per second
Dog.targets = {
    { x = 400, y = 200 },
    { x = 400, y = 500 },
    { x = 300, y = 400 },
    { x = 200, y = 100 }
}
Dog.currentTarget = 1

function Dog:load()
    dogImage = love.graphics.newImage("assets/dogPlaceholder.png")
    self.width = dogImage:getWidth() * self.imageScale
    self.height = dogImage:getHeight() * self.imageScale
end

function Dog:update(dt)
    local target = self:_getTarget()
    local dx = target.x - self.x
    local dy = target.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    self:_rotateTowards(dy, dx, dt)
    self:_moveForward(dt)
    self:_getCurrentPriorityTarget(distance)
end

function Dog:_getTarget()
    if CurrentState == GameState.LIGHT_LEVEL then
        return { x = love.mouse.getX(), y = love.mouse.getY() }
    elseif CurrentState == GameState.GAME then
        return self.targets[self.currentTarget]
    end
end

function Dog:_rotateTowards(dy, dx, dt)
    local targetAngle = math.atan2(dy, dx)
    local angleDiff = (targetAngle - self.angle + math.pi) % (2 * math.pi) - math.pi
    if math.abs(angleDiff) > 0.001 then
        local rotateAmount = self.rotationSpeed * dt
        if math.abs(angleDiff) < rotateAmount then
            self.angle = targetAngle
        else
            if angleDiff > 0 then
                self.angle = self.angle + rotateAmount
            else
                self.angle = self.angle - rotateAmount
            end
        end
    end
end

function Dog:_moveForward(dt)
    self.x = self.x + math.cos(self.angle) * self.speed * dt
    self.y = self.y + math.sin(self.angle) * self.speed * dt
end

function Dog:_getCurrentPriorityTarget(distance)
    if distance < 10 and CurrentState == GameState.GAME then
        self.currentTarget = self.currentTarget % #self.targets + 1
    end
end

function Dog:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(dogImage, -self.width / 2, -self.height / 2, 0, self.imageScale, self.imageScale)
    love.graphics.pop()
end

return Dog
