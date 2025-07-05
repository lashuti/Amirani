local Dog = require "dog"
local Light = require "light"
local Menu = require "menu"
local select_menu = require "select_menu"

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
  end
end

function love.draw()
  if CurrentState == GameState.MENU then
    Menu:draw()
  elseif CurrentState == GameState.GAME then
    -- Draw select_menu first (includes background)
    select_menu.draw()

    -- Draw game elements on top if needed
    if backgroundImage then
      love.graphics.draw(backgroundImage, 0, 0, 0, 0.8, 0.8) --0.8x scale temp
    end
    Dog:draw()                                               -- Uncomment if you want dog visible
    Light:draw()
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
