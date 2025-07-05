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

function cyclone:update(dt)
  self.time = self.time + dt

  -- Update particles
  for _, p in ipairs(self.particles) do
    if p.type == "spiral" then
      p.angle = p.angle + p.speed * dt
      -- Make particles rise (increase height)
      p.height = p.height + 80 * dt
      if p.height > self.height then
        p.height = 0
        p.angle = math.random() * math.pi * 2
      end
      -- Update radius based on height
      p.baseRadius = self.baseRadius + (self.topRadius - self.baseRadius) * (p.height / self.height)
    else
      -- Straight particles
      p.angle = p.angle + p.speed * dt
      p.height = p.height + 120 * dt -- Rise faster
      if p.height > self.height then
        p.height = 0
        p.offsetX = (math.random() - 0.5) * 20
        p.offsetY = (math.random() - 0.5) * 10
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
      x = self.x + math.cos(p.angle) * radius
      y = self.y - p.height
    else
      -- Straight particles with small offset
      x = self.x + p.offsetX + math.sin(self.time * 2 + p.height * 0.05) * 3
      y = self.y - p.height + p.offsetY
    end

    -- Fade particles based on height
    local heightAlpha = 1 - (p.height / self.height) * 0.5
    love.graphics.setColor(0.7, 0.7, 0.9, p.alpha * heightAlpha)
    love.graphics.circle("fill", x, y, p.size)
  end

  -- Draw base shadow
  love.graphics.setColor(0.2, 0.2, 0.3, 0.3)
  love.graphics.ellipse("fill", self.x, self.y + 5, self.baseRadius * 1.5, self.baseRadius * 0.5)
end

return cyclone
