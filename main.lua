local Dog = require "dog"
local Light = require "light"
local Menu = require "menu"
local Camera = require "camera"
local select_menu = require "select_menu"
local levelManager = require "levelManager"

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

  -- Load background if it exists
  local success, result = pcall(love.graphics.newImage, "assets/backgroundTemp.jpg")
  if success then
    backgroundImage = result
  end

  -- Set the random seed
  math.randomseed(os.time())

  Dog:load()
  Light:load()
  select_menu.load(WIDTH, HEIGHT)
end

function love.update(dt)
  if CurrentState == GameState.MENU then
    Menu:update(dt)
  elseif CurrentState == GameState.GAME then
    Dog:update(dt)
    Light:update(dt)
    select_menu.update(dt)
    levelManager.CheckCameraMoveTriggers()
  end
end

function love.draw()
  if CurrentState == GameState.MENU then
    Menu:draw()
  elseif CurrentState == GameState.GAME then
    -- Draw game background first
    if backgroundImage then
      love.graphics.draw(backgroundImage, 0, 0, 0, 0.8, 0.8)
    end

    Camera:attach()
    Dog:draw()
    Light:draw()
    Camera:detach()

    -- Draw select_menu at the bottom (always visible in GAME)
    select_menu.draw()
  end

    if(DEBUG_MODE) then
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
  elseif CurrentState == GameState.GAME then
    select_menu.mousepressed(x, y, button)
  end
end

function love.mousereleased(x, y, button)
  if CurrentState == GameState.GAME then
    select_menu.mousereleased(x, y, button)
  end
end

function love.mousemoved(x, y, dx, dy)
  if CurrentState == GameState.GAME then
    select_menu.mousemoved(x, y, dx, dy)
  end
end
