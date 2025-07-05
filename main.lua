
---@diagnostic disable: undefined-global

local dog = require "dog"

function love.load()
  WIDTH = 1280
  HEIGHT = 720
  love.window.setMode(WIDTH, HEIGHT)
  love.window.setTitle("Amirani")

  -- Set the random seed
  math.randomseed(os.time())
end

function love.update(dt)
  dog:update(dt)
end
  
function love.draw()
  dog:draw()
end