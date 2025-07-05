local Dog = require "dog"
local Light = require "light"
local Menu = require "menu"

GameState = {
  MENU = "menu",
  GAME = "game",
  LIGHT_LEVEL = "light_level"
}

CurrentState = GameState.MENU

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
  if CurrentState == GameState.MENU then
    Menu:update(dt)
  elseif CurrentState == GameState.GAME then
    Dog:update(dt)
    Light:update(dt)
  end
end

function love.draw()
  if CurrentState == GameState.MENU then
    Menu:draw()
  elseif CurrentState == GameState.GAME then
    love.graphics.draw(backgroundImage, 0, 0, 0, 0.8, 0.8) --0.8x scale temp
    Dog:draw()
    Light:draw()
  end

  if (DEBUG_MODE) then
    local mx, my = love.mouse.getPosition()
    love.graphics.print("X:" .. mx .. " Y:" .. my, 10, 10)
  end
end

function love.keypressed(key)
  if CurrentState == GameState.LIGHT_LEVEL or CurrentState == GameState.GAME then --Temp. make only light level in future
    Light:keypressed(key)
  end
end

function love.mousepressed(x, y, button)
  if CurrentState == GameState.MENU then
    Menu:mousepressed(x, y, button)
  end
end