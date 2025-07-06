local LevelManager = {}

local triggers = {
  --{x = 1280, y = 0, w = 50, h = 720, dx = 1, dy = 0}, -- right edge trigger
  --{x = 0, y = 0, w = 50, h = 720, dx = -1, dy = 0},    -- left edge trigger
  -- Add more triggers as needed
}

local Dog = require "dog"
local Camera = require "camera"

function LevelManager.CheckCameraMoveTriggers()
  for _, trig in ipairs(triggers) do
    if Dog.x > trig.x and Dog.x < trig.x + trig.w and Dog.y > trig.y and Dog.y < trig.y + trig.h then
      Camera:moveByScreen(trig.dx, trig.dy)
    end
  end
end

return LevelManager