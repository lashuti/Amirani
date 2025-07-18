local LightWorld = require "lighting"

local LightWorldManager = {}
LightWorldManager.enabled = false
LightWorldManager.world = nil
LightWorldManager.mouseLight = nil

function LightWorldManager:load()
  self.world = LightWorld({
    ambient = { 0.15, 0.15, 0.15 }
  })
  -- Simple mouse light
  self.mouseLight = self.world:newLight(0, 0, 255, 255, 255, 200)
  self.enabled = false
end

function LightWorldManager:update(dt)
  if not self.enabled then return end

  -- Update light world
  self.world:update(dt)

  -- just follow the mouse
  local mx, my = love.mouse.getPosition()
  self.mouseLight:setPosition(mx, my)
end

function LightWorldManager:draw(drawFunc)
  if not self.enabled then
    drawFunc()
    return
  end

  self.world:draw(drawFunc)
end


function LightWorldManager:ToggleOn()
    self.enabled = true
end

function LightWorldManager:ToggleOff()
    self.enabled = false
end

return LightWorldManager
