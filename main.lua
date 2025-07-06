local Light = require "light"
local LightWorldManager = require "lightworld_manager"
local Menu = require "menu"
local Camera = require "camera"
local SelectMenu = require "select_menu"
local LevelManager = require "levelManager"
local Settings = require "settings"
local Map = require "map"
local SoundManager = require "sound_manager"
local Fire = require "fire"
local Cyclone = require "cyclone"

local fires = {}
local cyclone

local Dog = require "dog_anim"

GameState = {
  MENU = "menu",
  GAME = "game",
  LIGHT_LEVEL = "light_level"
}

CurrentState = GameState.MENU

function love.load()
  Map:load()
  Settings:load()
  Light:load()
  LightWorldManager:load()
    SelectMenu.load()
  Dog:load()

  -- Load sounds and make globally accessible
  SoundManager:load()
  _G.SoundManager = SoundManager
  
  -- Start ambient nature sound as background music
  SoundManager:startAmbiance(SoundManager.AMBIANCE.NATURE)
  
  -- Create 3 fire elements for testing
  table.insert(fires, Fire:new(200, 400, {scale = 1.0, intensity = 1.0}))
  table.insert(fires, Fire:new(500, 450, {scale = 1.2, intensity = 1.3}))
  table.insert(fires, Fire:new(800, 380, {scale = 0.8, intensity = 0.8}))
end

function love.update(dt)
  if CurrentState == GameState.MENU then
        Menu:update(dt)

  elseif CurrentState == GameState.GAME then
    Light:update(dt)
    LightWorldManager:update(dt)
    SelectMenu.update(dt)
        LevelManager.CheckCameraMoveTriggers()
    Dog:update(dt)
    
    -- Update fires
    for _, fire in ipairs(fires) do
      fire:update(dt)
    end

    -- Update cyclone with wall collision
    if cyclone then
      -- Get walls from select menu
      local walls = SelectMenu.getWalls and SelectMenu.getWalls() or {}
      cyclone:update(dt, walls)
    end
  end
end

function love.draw()
  if CurrentState == GameState.MENU then
    Menu:draw()

  elseif CurrentState == GameState.GAME then
    LightWorldManager:draw(function()
      Camera:attach()
      Map:draw()

      -- Draw cyclone
      if cyclone then
        cyclone:draw()
      end

      -- Draw fires
      for _, fire in ipairs(fires) do
        fire:draw()
      end

      -- Draw the dog animation on the map
      Dog:draw()

      Camera:detach()
    end)

    -- Draw the old light overlay if enabled (on top of light world)
    Light:draw()

    -- Draw UI elements on top (not affected by lighting)
    SelectMenu.draw()
    Settings.draw_position()
  end
end

function love.keypressed(key)
  if CurrentState == GameState.LIGHT_LEVEL or CurrentState == GameState.GAME then --Temp. make only light level in future
    LightWorldManager:keypressed(key)                                             -- Use light_world instead
    SelectMenu.keypressed(key)                                                    -- Handle wall rotation
  end
end

function love.mousepressed(x, y, button)
  if CurrentState == GameState.MENU then
    Menu:mousepressed(x, y, button)
  elseif CurrentState == GameState.GAME then
    SelectMenu.mousepressed(x, y, button)
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
