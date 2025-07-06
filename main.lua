local Dog = require "dog"
local Light = require "light"
local LightWorldManager = require "lightworld_manager"
local Menu = require "menu"
local Camera = require "camera"
local SelectMenu = require "select_menu"
local LevelManager = require "levelManager"
local Settings = require "settings"
local Map = require "map"


GameState = {
  MENU = "menu",
  GAME = "game",
  LIGHT_LEVEL = "light_level"
}

CurrentState = GameState.MENU

function love.load()
  Map:load()
  Settings:load()
  Dog:load()
  Light:load()
  LightWorldManager:load()
  SelectMenu.load()
end

function love.update(dt)

  if CurrentState == GameState.MENU then
        Menu:update(dt)

  elseif CurrentState == GameState.GAME then

    Dog:update(dt)
    Light:update(dt)
    LightWorldManager:update(dt)
    SelectMenu.update(dt)
    LevelManager.CheckCameraMoveTriggers()

  end
end

function love.draw()
  if CurrentState == GameState.MENU then
        Menu:draw()

    elseif CurrentState == GameState.GAME then
    Map:draw()
    Dog:draw()
    Light:draw()
    SelectMenu.draw()
    Settings.draw_position()

    LightWorldManager:draw(function()
      Camera:attach()
      if BackgroundImage then
        love.graphics.draw(BackgroundImage, 0, 0, 0, 0.8, 0.8)
      end
      Camera:detach()
    end)
    -- Draw the old light overlay if enabled (on top of light world)
    -- Draw select_menu at the bottom (always visible in GAME)
  end
end

function love.keypressed(key)
  if CurrentState == GameState.LIGHT_LEVEL or CurrentState == GameState.GAME then --Temp. make only light level in future
    LightWorldManager:keypressed(key)                                             -- Use light_world instead
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
      SelectMenu.mousepressed(x, y, button)
    end
  end
end

function love.mousereleased(x, y, button)
  if CurrentState == GameState.GAME then
    if button == 1 and testObject and testObject.isDragging then
      testObject.isDragging = false
    end
    SelectMenu.mousereleased(x, y, button)
  end
end

function love.mousemoved(x, y, dx, dy)
  if CurrentState == GameState.GAME then
    if testObject and testObject.isDragging then
      testObject.x = x - testObject.width / 2
      testObject.y = y - testObject.height / 2
    end
    SelectMenu.mousemoved(x, y, dx, dy)
  end
end
