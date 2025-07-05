local Dog = require "dog"
local Light = require "light"
local LightWorldManager = require "lightworld_manager"
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
    BackgroundImage = result
  end

  -- Set the random seed
  math.randomseed(os.time())

  Dog:load()
  Light:load()
  LightWorldManager:load()
  select_menu.load(WIDTH, HEIGHT)
end

function love.update(dt)
  if CurrentState == GameState.MENU then
    Menu:update(dt)
  elseif CurrentState == GameState.GAME then
    Dog:update(dt)
    Light:update(dt)
    LightWorldManager:update(dt)
    select_menu.update(dt)
    levelManager.CheckCameraMoveTriggers()
  end
end

function love.draw()
  if CurrentState == GameState.MENU then
    Menu:draw()
  elseif CurrentState == GameState.GAME then
    -- Draw everything with light_world
    LightWorldManager:draw(function()
      Camera:attach()
      if BackgroundImage then
        love.graphics.draw(BackgroundImage, 0, 0, 0, 0.8, 0.8)
      end

      Dog:draw()

      -- Test red rectangle to see movement of the map
      local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
      local rectW, rectH = 100, 60
      love.graphics.setColor(1, 0, 0, 0.7)
      love.graphics.rectangle("fill", (screenW - rectW) / 2, (screenH - rectH) / 2, rectW, rectH)
      love.graphics.setColor(1, 1, 1, 1)
      --

      Camera:detach()
    end)
    
    -- Draw the old light overlay if enabled (on top of light world)
    Light:draw()

    -- Draw select_menu at the bottom (always visible in GAME)
    select_menu.draw()
  end

  if (DEBUG_MODE) then
    local mx, my = love.mouse.getPosition()
    love.graphics.print("X:" .. mx .. " Y:" .. my, 10, 10)
  end
end

function love.keypressed(key)
  if CurrentState == GameState.LIGHT_LEVEL or CurrentState == GameState.GAME then --Temp. make only light level in future
    -- Light:keypressed(key)  -- Comment out old light system
    LightWorldManager:keypressed(key)  -- Use light_world instead
  end
end

function love.mousepressed(x, y, button)
  if CurrentState == GameState.MENU then
    Menu:mousepressed(x, y, button)
  elseif CurrentState == GameState.GAME then
    -- Check if clicking on test object
    if button == 1 and testObject and x >= testObject.x and x <= testObject.x + testObject.width and
        y >= testObject.y and y <= testObject.y + testObject.height then
      testObject.isDragging = true
      testObject.vx = 0
      testObject.vy = 0
    else
      select_menu.mousepressed(x, y, button)
    end
  end
end

function love.mousereleased(x, y, button)
  if CurrentState == GameState.GAME then
    if button == 1 and testObject and testObject.isDragging then
      testObject.isDragging = false
    end
    select_menu.mousereleased(x, y, button)
  end
end

function love.mousemoved(x, y, dx, dy)
  if CurrentState == GameState.GAME then
    if testObject and testObject.isDragging then
      testObject.x = x - testObject.width / 2
      testObject.y = y - testObject.height / 2
    end
    select_menu.mousemoved(x, y, dx, dy)
  end
end
