local Gun = require "gun"
local Eagle = require "eagle"
local enemies = {}

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
local Pit = require "pit"
local DustEffect = require "dust_effect"
local FireExtinguishEffect = require "fire_extinguish_effect"

local fires = {}
local cyclone
local pits = {}
local dustEffects = {}
local fireExtinguishEffects = {}
local steamEffects = {}

local SteamEffect = require "steam_effect"
local Dog = require "dog"

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
  Gun:load()
  Eagle:load()
  -- Load sounds and make globally accessible
  SoundManager:load()
  _G.SoundManager = SoundManager

  -- Start ambient nature sound as background music
  SoundManager:startAmbiance(SoundManager.AMBIANCE.NATURE)

  -- Create 3 fire elements for testing
  table.insert(fires, Fire:new(200, 400, { scale = 1.0, intensity = 1.0 }))
  table.insert(fires, Fire:new(500, 450, { scale = 1.2, intensity = 1.3 }))
  table.insert(fires, Fire:new(800, 380, { scale = 0.8, intensity = 0.8 }))

  -- Create 2 pit traps for testing
  table.insert(pits, Pit:new(350, 500, 60)) -- x, y, radius
  table.insert(pits, Pit:new(650, 350, 50))
  
  -- Create cyclone
  cyclone = Cyclone.new(600, 500)
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

    Eagle:update(dt, Dog.x, Dog.y)
    -- Update fires
    for _, fire in ipairs(fires) do
      fire:update(dt)
    end


    for i = #dustEffects, 1, -1 do
      local dust = dustEffects[i]
      dust:update(dt)

      if dust:isDone() then
        table.remove(dustEffects, i)
      end
    end

    for i = #fireExtinguishEffects, 1, -1 do
      local effect = fireExtinguishEffects[i]
      effect:update(dt)

      if effect:isDone() then
        table.remove(fireExtinguishEffects, i)
      end
    end

    -- Update steam effects
    for i = #steamEffects, 1, -1 do
      local steam = steamEffects[i]
      steam:update(dt)

      -- Remove finished steam effects
      if steam:isDone() then
        table.remove(steamEffects, i)
      end
    end

    -- Update cyclone with wall collision
    if cyclone and cyclone.update then
      -- Get walls from select menu
      local walls = SelectMenu.getWalls and SelectMenu.getWalls() or {}
      cyclone:update(dt, walls)
    end

    for _, pit in ipairs(pits) do
      pit:update(dt, Dog)

      -- Check collision with sand items
      local sandItems = SelectMenu.getSandItems and SelectMenu.getSandItems() or {}
      for sandIndex = #sandItems, 1, -1 do
        local sand = sandItems[sandIndex]
        if sand and not pit.filledWithSand and sand:checkCollision(pit) then
          -- Fill the pit with sand
          pit:fillWithSand()

          -- Create dust effect at pit position
          local dust = DustEffect:new(pit.x, pit.y, { duration = 2.0, intensity = 1.0 })
          table.insert(dustEffects, dust)

          -- Remove the sand item (it fell into the pit)
          sand.active = false
          SelectMenu.removeSandItem(sand)

          -- Play a sand/dirt sound if available
          if SoundManager and SoundManager.play then
            -- You can add a dirt/sand falling sound here
            -- SoundManager:play("dirt", "blockPlace", 0.7)
          end
        end
      end
    end

    -- Check water-fire collisions
    local waterBottles = SelectMenu.getWaterBottles and SelectMenu.getWaterBottles() or {}
    for _, bottle in ipairs(waterBottles) do
      local droplets = bottle:getDroplets()
      -- Track droplets to remove
      local dropletsToRemove = {}

      for dropletIndex, droplet in ipairs(droplets) do
        -- Track fires to remove
        local fireHit = false

        -- Check collision with each fire
        for fireIndex = #fires, 1, -1 do -- Iterate backwards for safe removal
          local fire = fires[fireIndex]
          local dx = droplet.x - fire.x
          local dy = droplet.y - (fire.y + (fire.collisionOffsetY or -20))
          local distance = math.sqrt(dx * dx + dy * dy)

          -- Simple collision check based on distance
          if distance < (fire.collisionRadius or 40) + droplet.size then
            -- Create fire extinguish effect
            local extinguishEffect = FireExtinguishEffect:new(fire.x, fire.y, { duration = 1.5 })
            table.insert(fireExtinguishEffects, extinguishEffect)
            
            -- Create steam effect at fire position
            local steam = SteamEffect:new(fire.x, fire.y, { duration = 3.0 })
            table.insert(steamEffects, steam)

            -- Destroy the fire
            fire:destroy()
            table.remove(fires, fireIndex)
            fireHit = true
            print(string.format("Fire extinguished at (%.1f, %.1f)!", fire.x, fire.y))

            -- Play water evaporation sound
            if SoundManager and SoundManager.play then
              SoundManager:play("lava", "waterEvaporate", 0.8)
            end
            break -- One droplet can only hit one fire
          end
        end

        -- Mark droplet for removal if it hit a fire
        if fireHit then
          table.insert(dropletsToRemove, dropletIndex)
        end
      end

      -- Remove droplets that hit fires (iterate backwards)
      for i = #dropletsToRemove, 1, -1 do
        table.remove(droplets, dropletsToRemove[i])
      end
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

      -- Draw pits (should be drawn before other objects)
      for _, pit in ipairs(pits) do
        pit:draw()
      end

      Eagle:draw()
      -- Draw cyclone
      if cyclone and cyclone.draw then
        cyclone:draw()
      end

      -- Draw fires
      for _, fire in ipairs(fires) do
        fire:draw()
      end


      -- Draw dust effects
      for _, dust in ipairs(dustEffects) do
        dust:draw()
      end

      -- Draw fire extinguish effects
      for _, effect in ipairs(fireExtinguishEffects) do
        effect:draw()
      end
      
      -- Draw steam effects
      for _, steam in ipairs(steamEffects) do
        steam:draw()
      end

      -- Draw the dog animation on the map
      Dog:draw()

      -- Draw enemy eagles
      if CurrentState == GameState.GAME then
        for _, e in ipairs(enemies) do
          if e.active then e:draw() end
        end
        Gun:draw()
      end

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
  -- TODO instead of G make it a button in the menu
  if key == 'g' and CurrentState == GameState.GAME then
    if Gun.active then Gun:deactivate() else Gun:activate() end
  end
  if key == 'r' and CurrentState == GameState.GAME then
    Eagle:activate(Dog.x, Dog.y)
  end
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
    Gun:mousepressed(x, y, button, enemies)
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
