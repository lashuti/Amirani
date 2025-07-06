local Wall = {}
Wall.__index = Wall

function Wall.new(x, y, rotation)
    local self = setmetatable({}, Wall)
    
    self.x = x or 0
    self.y = y or 0
    self.width = 180
    self.height = 30
    self.rotation = rotation or 0
    
    -- Visual properties
    self.baseColor = {0.5, 0.4, 0.35}
    self.shadowColor = {0.3, 0.25, 0.2}
    self.highlightColor = {0.65, 0.55, 0.45}
    self.mortarColor = {0.4, 0.35, 0.3}
    
    -- Stone pattern
    self.stones = {}
    self:generateStones()
    
    -- Physics properties
    self.isStatic = true
    
    return self
end

function Wall:generateStones()
    -- Create random stone pattern
    local stoneCount = math.floor(self.width / 20)
    local currentX = 0
    
    for i = 1, stoneCount do
        local stoneWidth = 15 + math.random() * 15
        local stoneHeight = self.height - 4
        
        if currentX + stoneWidth > self.width then
            stoneWidth = self.width - currentX
        end
        
        table.insert(self.stones, {
            x = currentX,
            y = 2,
            width = stoneWidth - 2,
            height = stoneHeight,
            shade = 0.9 + math.random() * 0.2,
            crack = math.random() < 0.3
        })
        
        currentX = currentX + stoneWidth
        
        if currentX >= self.width then break end
    end
end

function Wall:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-self.width/2, -self.height/2)
    
    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 2, 2, self.width, self.height, 2)
    
    -- Draw mortar/base
    love.graphics.setColor(self.mortarColor)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height, 2)
    
    -- Draw individual stones
    for _, stone in ipairs(self.stones) do
        -- Stone shadow
        love.graphics.setColor(self.shadowColor[1], self.shadowColor[2], self.shadowColor[3], 0.5)
        love.graphics.rectangle("fill", stone.x + 1, stone.y + 1, stone.width, stone.height, 1)
        
        -- Main stone
        love.graphics.setColor(
            self.baseColor[1] * stone.shade,
            self.baseColor[2] * stone.shade,
            self.baseColor[3] * stone.shade
        )
        love.graphics.rectangle("fill", stone.x, stone.y, stone.width, stone.height, 1)
        
        -- Stone highlight
        love.graphics.setColor(self.highlightColor[1], self.highlightColor[2], self.highlightColor[3], 0.3)
        love.graphics.rectangle("fill", stone.x, stone.y, stone.width, 3)
        
        -- Cracks
        if stone.crack then
            love.graphics.setColor(self.shadowColor[1], self.shadowColor[2], self.shadowColor[3], 0.3)
            love.graphics.setLineWidth(1)
            local crackX = stone.x + stone.width * 0.3 + math.random() * stone.width * 0.4
            love.graphics.line(
                crackX, stone.y + 2,
                crackX + math.random(-3, 3), stone.y + stone.height - 2
            )
        end
    end
    
    -- Edge highlights
    love.graphics.setColor(self.highlightColor[1], self.highlightColor[2], self.highlightColor[3], 0.2)
    love.graphics.setLineWidth(1)
    love.graphics.line(0, 0, self.width, 0)
    love.graphics.line(0, 0, 0, self.height)
    
    -- Edge shadows
    love.graphics.setColor(self.shadowColor[1], self.shadowColor[2], self.shadowColor[3], 0.3)
    love.graphics.line(0, self.height, self.width, self.height)
    love.graphics.line(self.width, 0, self.width, self.height)
    
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function Wall:drawPreview(x, y, rotation, alpha)
    alpha = alpha or 0.6
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(rotation)
    love.graphics.translate(-self.width/2, -self.height/2)
    
    -- Semi-transparent preview
    love.graphics.setColor(self.baseColor[1], self.baseColor[2], self.baseColor[3], alpha)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height, 2)
    
    -- Grid lines to show rotation
    love.graphics.setColor(1, 1, 1, alpha * 0.3)
    love.graphics.setLineWidth(1)
    for i = 0, self.width, 20 do
        love.graphics.line(i, 0, i, self.height)
    end
    
    -- Rotation indicator
    love.graphics.pop()
    
    -- Draw rotation angle text
    love.graphics.setColor(1, 1, 1, alpha)
    local angleDegrees = math.deg(rotation) % 360
    love.graphics.print(string.format("%.0f°", angleDegrees), x - 20, y - 30)
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Wall:getCollisionBox()
    -- Returns the four corners of the rotated wall for collision detection
    local cos = math.cos(self.rotation)
    local sin = math.sin(self.rotation)
    
    local hw = self.width / 2
    local hh = self.height / 2
    
    local corners = {
        {x = -hw, y = -hh},
        {x = hw, y = -hh},
        {x = hw, y = hh},
        {x = -hw, y = hh}
    }
    
    local rotatedCorners = {}
    for i, corner in ipairs(corners) do
        rotatedCorners[i] = {
            x = self.x + corner.x * cos - corner.y * sin,
            y = self.y + corner.x * sin + corner.y * cos
        }
    end
    
    return rotatedCorners
end

function Wall:checkCollision(x, y, radius)
    -- Simple point-to-rectangle collision with rotation
    local cos = math.cos(-self.rotation)
    local sin = math.sin(-self.rotation)
    
    -- Transform point to wall's local space
    local localX = (x - self.x) * cos - (y - self.y) * sin
    local localY = (x - self.x) * sin + (y - self.y) * cos
    
    local hw = self.width / 2
    local hh = self.height / 2
    
    return localX >= -hw - radius and localX <= hw + radius and
           localY >= -hh - radius and localY <= hh + radius
end

return Wall