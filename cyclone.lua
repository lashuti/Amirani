local cyclone = {}

function cyclone.new(x, y)
  local self = {
    x = x,
    y = y,
    baseRadius = 20,
    topRadius = 80,
    height = 250,
    strength = 300,
    particles = {},
    time = 0,

    rotation = math.pi / 2, -- 90 degrees in radians
  }

  -- Initialize spiral particles
  for i = 1, 150 do
    local height = math.random() * self.height
    local radiusAtHeight = self.baseRadius + (self.topRadius - self.baseRadius) * (height / self.height)

    table.insert(self.particles, {
      angle = math.random() * math.pi * 2,
      height = height,
      baseRadius = radiusAtHeight,
      speed = 2 + math.random() * 2,
      size = 1 + math.random() * 3,
      alpha = 0.3 + math.random() * 0.3,
      type = "spiral"
    })
  end

  -- Initialize straight upward particles (center stream)
  for i = 1, 50 do
    table.insert(self.particles, {
      angle = 0,
      height = math.random() * self.height,
      baseRadius = math.random() * 10,   -- Stay close to center
      speed = 0.5 + math.random() * 0.5, -- Slower rotation
      size = 2 + math.random() * 2,
      alpha = 0.4 + math.random() * 0.3,
      type = "straight",
      offsetX = (math.random() - 0.5) * 20,
      offsetY = (math.random() - 0.5) * 10
    })
  end


  self.update = cyclone.update
  self.draw = cyclone.draw
  self.getPushForce = cyclone.getPushForce

  return self
end

function cyclone:update(dt, walls)
  self.time = self.time + dt
  walls = walls or {}

  -- Update particles
  for _, p in ipairs(self.particles) do
    -- Calculate particle position with cyclone rotation
    local x, y
    if p.type == "spiral" then
      local radius = p.baseRadius + math.sin(self.time * 3 + p.height * 0.1) * 5
      local localX = math.cos(p.angle) * radius
      local localY = -p.height
      -- Apply cyclone rotation
      x = self.x + (localX * math.cos(self.rotation) - localY * math.sin(self.rotation))
      y = self.y + (localX * math.sin(self.rotation) + localY * math.cos(self.rotation))
    else
      local localX = p.offsetX + math.sin(self.time * 2 + p.height * 0.05) * 3
      local localY = -p.height + p.offsetY
      x = self.x + (localX * math.cos(self.rotation) - localY * math.sin(self.rotation))
      y = self.y + (localX * math.sin(self.rotation) + localY * math.cos(self.rotation))
    end
    
    -- Check collision with walls
    local blocked = false
    local deflectAngle = 0
    
    for _, wall in ipairs(walls) do
      if wall.checkCollision and wall:checkCollision(x, y, p.size) then
        blocked = true
        -- Calculate deflection angle based on wall rotation
        deflectAngle = wall.rotation
        break
      end
    end
    
    if blocked then
      -- Particle is blocked by wall, deflect it diagonally
      if not p.deflected then
        p.deflected = true
        p.deflectTime = 0
        p.deflectAngle = deflectAngle
        -- Choose left or right deflection randomly
        p.deflectDirection = math.random() < 0.5 and -1 or 1
      end
    end
    
    -- Update particle movement
    if p.deflected then
      p.deflectTime = p.deflectTime + dt
      
      -- Move particle diagonally away from wall
      local deflectSpeed = 100 + p.deflectTime * 50
      local angle = p.deflectAngle + (math.pi/2) * p.deflectDirection
      
      if p.type == "spiral" then
        p.baseRadius = p.baseRadius + math.cos(angle) * deflectSpeed * dt
        p.height = p.height + math.sin(angle) * deflectSpeed * dt * 0.3
      else
        p.offsetX = p.offsetX + math.cos(angle) * deflectSpeed * dt
        p.offsetY = p.offsetY + math.sin(angle) * deflectSpeed * dt * 0.3
      end
      
      -- Fade out deflected particles
      p.alpha = math.max(0, (p.alpha or 1) - dt * 0.5)
      
      -- Reset particle when it fades out completely
      if p.alpha <= 0 then
        p.height = 0
        p.angle = math.random() * math.pi * 2
        p.baseRadius = self.baseRadius
        p.offsetX = (math.random() - 0.5) * 20
        p.offsetY = (math.random() - 0.5) * 10
        p.deflected = false
        p.alpha = p.type == "spiral" and (0.3 + math.random() * 0.3) or (0.4 + math.random() * 0.3)
      end
    else
      -- Normal particle movement
      if p.type == "spiral" then
        p.angle = p.angle + p.speed * dt
        p.height = p.height + 80 * dt
        if p.height > self.height then
          p.height = 0
          p.angle = math.random() * math.pi * 2
        end
        p.baseRadius = self.baseRadius + (self.topRadius - self.baseRadius) * (p.height / self.height)
      else
        p.angle = p.angle + p.speed * dt
        p.height = p.height + 120 * dt
        if p.height > self.height then
          p.height = 0
          p.offsetX = (math.random() - 0.5) * 20
          p.offsetY = (math.random() - 0.5) * 10
        end
      end
    end
  end
end

function cyclone:getPushForce(objX, objY)
  local dx = objX - self.x
  local dy = objY - self.y

  -- Calculate full distance from cyclone center
  local distance = math.sqrt(dx * dx + dy * dy)

  -- Check if within influence radius
  if distance < self.topRadius + 100 then
    -- Calculate angle from cyclone center to object
    local angle = math.atan2(dy, dx)

    -- Calculate push strength based on distance
    local pushStrength = 1 - (distance / (self.topRadius + 100))
    pushStrength = pushStrength * pushStrength -- Make it stronger near center

    -- Outward push force
    local outwardForce = pushStrength * self.strength

    -- Apply forces in the direction away from cyclone
    local fx = math.cos(angle) * outwardForce
    local fy = math.sin(angle) * outwardForce

    return fx, fy
  end

  return 0, 0
end

function cyclone:draw()
  -- Draw all particles
  for _, p in ipairs(self.particles) do
    local x, y

    if p.type == "spiral" then
      local radius = p.baseRadius + math.sin(self.time * 3 + p.height * 0.1) * 5
      local localX = math.cos(p.angle) * radius
      local localY = -p.height
      x = self.x + (localX * math.cos(self.rotation) - localY * math.sin(self.rotation))
      y = self.y + (localX * math.sin(self.rotation) + localY * math.cos(self.rotation))
    else
      local localX = p.offsetX + math.sin(self.time * 2 + p.height * 0.05) * 3
      local localY = -p.height + p.offsetY
      x = self.x + (localX * math.cos(self.rotation) - localY * math.sin(self.rotation))
      y = self.y + (localX * math.sin(self.rotation) + localY * math.cos(self.rotation))
    end

    -- Fade particles based on height and deflection
    local heightAlpha = 1 - (p.height / self.height) * 0.5
    local particleAlpha = p.alpha or (p.type == "spiral" and 0.3 or 0.4)
    love.graphics.setColor(0.7, 0.7, 0.9, particleAlpha * heightAlpha)
    love.graphics.circle("fill", x, y, p.size)
  end

  -- Draw base shadow, rotated
  love.graphics.setColor(0.2, 0.2, 0.3, 0.3)
  local shadowX = self.x + math.cos(self.rotation) * 5
  local shadowY = self.y + math.sin(self.rotation) * 5
  love.graphics.ellipse("fill", shadowX, shadowY, self.baseRadius * 1.5, self.baseRadius * 0.5, self.rotation)
end

return cyclone
