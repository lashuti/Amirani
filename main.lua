local Dog = require "dog"
local Light = require "light"

function love.load()
  DEBUG_MODE = true
  WIDTH = 1280
  HEIGHT = 720
  love.window.setMode(WIDTH, HEIGHT)
  love.window.setTitle("Amirani")

  backgroundImage = love.graphics.newImage("assets/backgroundTemp.jpg")
  -- Set the random seed
  math.randomseed(os.time())

  Dog:load()
  Light:load()
end

function love.update(dt)
  Dog:update(dt)
  Light:update(dt)
end

function love.draw()
  love.graphics.draw(backgroundImage, 0, 0, 0, 0.8, 0.8) --0.8x scale temp
  Dog:draw()
  Light:draw()

  if(DEBUG_MODE) then
    local mx, my = love.mouse.getPosition()
    love.graphics.print("X:" .. mx .. " Y:" .. my, 10, 10)
  end
end

function love.keypressed(key)
  HandleLightToggle(key)
end

function HandleLightToggle(key)
  if key == "e" then
    if Light.enabled then
      Light.disable()
    else
      Light.enable()
    end
  end
end