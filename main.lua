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
local Amirani = require "amirani"

local fires = {}
local cyclone
local pits = {}
local dustEffects = {}
local fireExtinguishEffects = {}
local steamEffects = {}
local amirani

local SteamEffect = require "steam_effect"
local Dog = require "dog"

GameState = {
  MENU = "menu",
  GAME = "game",
  LIGHT_LEVEL = "light_level"
}

CurrentState = GameState.MENU


_G.screamDisable = false
local menuBgImage

function love.load()

  menuBgImage = love.graphics.newImage("assets/MenuBg.png")
  Map:load()
  -- Set camera to show the bottom left part of the map at the start
  if Map.getDimensions then
    local mapWidth, mapHeight = Map:getDimensions()
    -- Camera should start at (0, mapHeight - screenHeight)
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    -- Clamp to map bounds if needed
    local camX = 0
    local camY = math.max(0, (mapHeight or 0) - (screenHeight or 0))
    if Camera and Camera.setPosition then
      Camera:setPosition(camX, camY)
    elseif Camera then
      Camera.x = camX
      Camera.y = camY
    end
  end
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

  -- Start ambient valley sound as background music (background loop)
  SoundManager:startAmbiance(SoundManager.AMBIANCE.VALLEY, 1.0)
  _G.currentAmbiance = "valley"

  -- Example: switch to valley ambiance after 10 seconds (demo)
  -- You can trigger these on any event, e.g. map/background change
  _G.ambianceSwitchTimer = 0
  _G.ambianceTarget = nil

  local pit = Pit:new(600, 540, 50)
  local pit2 = Pit:new(820, 540, 50)
  table.insert(pits, pit)
  table.insert(pits, pit2)
  
end

function love.update(dt)
  -- Dynamically switch ambient sound based on map image
    if Map.showTopRight and (_G.currentAmbiance ~= "tension") then
      SoundManager:stopAmbiance()
      SoundManager:startAmbiance(SoundManager.AMBIANCE.TENSION)
      _G.currentAmbiance = "tension"
    elseif Map.imagePath and Map.imagePath:find("darkLevelBg") and (_G.currentAmbiance ~= "dark") then
      SoundManager:stopAmbiance()
      SoundManager:startAmbiance(SoundManager.AMBIANCE.TENSION)
      _G.currentAmbiance = "dark"
    elseif Map.imagePath and Map.imagePath:find("map.png") and (_G.currentAmbiance ~= "nature") and not Map.showTopRight then
      SoundManager:stopAmbiance()
      SoundManager:startAmbiance(SoundManager.AMBIANCE.NATURE)
      _G.currentAmbiance = "nature"
    end


  -- Toggle light world if LEVEL == 3
  if LEVEL == 3 then
    LightWorldManager:ToggleOn()
    -- Delete cyclone if present
    cyclone = nil
    SelectMenu.removeAllWallsIfLevel3(LEVEL)
  else
    LightWorldManager:ToggleOff()
    -- Spawn cyclone at (430, 490) only once if level 2
    if LEVEL == 2 then
      if not _G.cycloneSpawnedForLevel2 then
        cyclone = Cyclone.new(420, 440)
        Gun:deactivate()
        _G.cycloneSpawnedForLevel2 = true
      end

      for i = #pits, 1, -1 do
        table.remove(pits, i)
      end
    else
      _G.cycloneSpawnedForLevel2 = false
    end
  end

  if LEVEL == 4 then
    if not _G.firesSpawnedForLevel4 then
      table.insert(fires, Fire:new(600, 600, { scale = 1.0, intensity = 1.0 }))
      table.insert(fires, Fire:new(680, 560, { scale = 1.2, intensity = 1.3 }))
      table.insert(fires, Fire:new(750, 610, { scale = 0.8, intensity = 0.8 }))
      _G.firesSpawnedForLevel4 = true
    end
    -- Play Amirani scream every 2 seconds in level 4, unless screamDisable is set
    if not _G.screamDisabled then
      if not _G.amiraniScreamTimer then _G.amiraniScreamTimer = 0 end
      _G.amiraniScreamTimer = _G.amiraniScreamTimer + dt
      if _G.amiraniScreamTimer >= 2.0 then
        _G.amiraniScreamTimer = 0
        if SoundManager and SoundManager.play then
          SoundManager:play("amirani", "shoutClose1", 1.0)
        end
      end
    end
  else
    _G.firesSpawnedForLevel4 = false
    _G.amiraniScreamTimer = 0
  end
  
  -- Play Amirani shout every 15 seconds, randomly choosing a shout, but only if map is showing top right or upper part
  if (Map.showTopRight or Map.showUpperPart) then
    if not _G.amiraniShoutTimer then _G.amiraniShoutTimer = 0 end
    _G.amiraniShoutTimer = _G.amiraniShoutTimer + dt
    if _G.amiraniShoutTimer >= 15.0 then
      _G.amiraniShoutTimer = 0
      if SoundManager and SoundManager.play then
        local shoutKeys = {"shoutClose1", "shoutClose2", "shoutMid", "shoutFar"}
        local key = shoutKeys[math.random(1, #shoutKeys)]
        SoundManager:play("amirani", key, 1.0)
      end
    end
  else
    _G.amiraniShoutTimer = 0
  end
  if CurrentState == GameState.MENU then
    Menu:update(dt)
  elseif CurrentState == GameState.GAME then
    Light:update(dt)
    LightWorldManager:update(dt)
    SelectMenu.update(dt)
    LevelManager.CheckCameraMoveTriggers()
    Dog:update(dt)
    
    if Map.showTopRight and not amirani then
      amirani = Amirani:new(1175, 270)
    end
    -- Update Amirani
    if amirani then
      amirani:update(dt, Dog.x, Dog.y)
      
      -- Check if game is won
      if amirani:isGameWon() then
        -- Game is won, you could pause updates or transition to a win state
        return
      end
    end

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

local menuTitleFont

function love.draw()
  if CurrentState == GameState.MENU then
    if menuBgImage then
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(menuBgImage, 0, 0, 0, love.graphics.getWidth() / menuBgImage:getWidth(), love.graphics.getHeight() / menuBgImage:getHeight())
    end
    -- Draw beautiful big title
    if not menuTitleFont then
      menuTitleFont = love.graphics.newFont("assets/ChunkFive-Regular.ttf", 72)
    end
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(menuTitleFont)
    love.graphics.setColor(0.95, 0.8, 0.2)
    local title = "AMIRANI'S CUGA"
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local tw = menuTitleFont:getWidth(title)
    local th = menuTitleFont:getHeight()
    -- Shadow
    love.graphics.setColor(0.2, 0.1, 0, 0.5)
    love.graphics.print(title, (sw-tw)/2+4, 60+4)
    -- Main text
    love.graphics.setColor(0.95, 0.8, 0.2)
    love.graphics.print(title, (sw-tw)/2, 60)
    love.graphics.setFont(prevFont)
    love.graphics.setColor(1, 1, 1)
    -- Draw menu buttons after title
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
      
      -- Draw Amirani
      if amirani then
        amirani:draw()
      end

      -- Draw the dog animation on the map
      Dog:draw()

      -- Draw enemy eagles
      if CurrentState == GameState.GAME then
        for _, e in ipairs(enemies) do
          if e.active then e:draw() end
        end
      end

      Camera:detach()
    end)

    -- Draw the old light overlay if enabled (on top of light world)
    Light:draw()

    -- Draw UI elements on top (not affected by lighting)
    SelectMenu.draw()
    Settings:draw_position()

    Gun:draw()

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
  if CurrentState == GameState.LIGHT_LEVEL or CurrentState == GameState.GAME then --Temp. make only light level in future                                        -- Use light_world instead
    SelectMenu.keypressed(key)                                                    -- Handle wall rotation
  end
end

function love.mousepressed(x, y, button)
  if CurrentState == GameState.MENU then
    Menu:mousepressed(x, y, button)
  elseif CurrentState == GameState.GAME then
    SelectMenu.mousepressed(x, y, button)
    Gun:mousepressed(x, y, button, enemies, Eagle)
  end
end

function love.mousereleased(x, y, button)
  if CurrentState == GameState.GAME then
    -- Removed testObject drag logic (testObject is undefined)
    SelectMenu.mousereleased(x, y, button)
  end
end

function love.mousemoved(x, y, dx, dy)
  if CurrentState == GameState.GAME then
    -- Removed testObject drag logic (testObject is undefined)
    SelectMenu.mousemoved(x, y, dx, dy)
  end
end
