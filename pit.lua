local Pit = {}
Pit.__index = Pit

function Pit:new(x, y, radius)
    local self = setmetatable({}, Pit)
    
    self.x = x or 0
    self.y = y or 0
    self.radius = radius or 50
    
    -- State
    self.active = true
    self.dogTrapped = false
    self.filledWithSand = false
    
    return self
end

function Pit:update(dt, dog)
    if not self.active or self.dogTrapped or self.filledWithSand then return end
    
    -- Only check collision with dog if not filled with sand
    if dog and dog.x and dog.y then
        local dx = dog.x - self.x
        local dy = dog.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        -- Check if dog falls into pit
        if distance < self.radius then
            self:trapDog(dog)
        end
    end
end

function Pit:trapDog(dog)
    self.dogTrapped = true
    
    -- Trigger dog falling animation or state
    if dog.fallIntoPit then
        dog:fallIntoPit(self.x, self.y)
    else
        -- Simple disable if dog doesn't have fall method
        if dog.setActive then
            dog:setActive(false)
        elseif dog.active ~= nil then
            dog.active = false
        end
    end
    
    print("Dog fell into pit at (" .. self.x .. ", " .. self.y .. ")!")
end

function Pit:fillWithSand()
    self.filledWithSand = true
    print("Pit filled with sand at (" .. self.x .. ", " .. self.y .. ")! Dog can no longer fall in.")
end

function Pit:draw()
    if not self.active then return end
    
    if self.filledWithSand then
        -- Draw sandy/brown circle when filled
        love.graphics.setColor(0.76, 0.70, 0.50, 0.5)
        love.graphics.circle("fill", self.x, self.y, self.radius)
        
        love.graphics.setColor(0.65, 0.60, 0.40, 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", self.x, self.y, self.radius)
        
        -- Draw some sand texture
        love.graphics.setColor(0.80, 0.74, 0.54, 0.3)
        love.graphics.circle("fill", self.x, self.y, self.radius * 0.7)
    else
        -- Draw red circle to show pit area
        love.graphics.setColor(1, 0, 0, 0.3)
        love.graphics.circle("fill", self.x, self.y, self.radius)
        
        love.graphics.setColor(1, 0, 0, 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", self.x, self.y, self.radius)
    end
    
    -- Reset color and line width
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

function Pit:setPosition(x, y)
    self.x = x
    self.y = y
end

function Pit:setActive(active)
    self.active = active
end

return Pit