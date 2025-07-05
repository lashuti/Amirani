local Dog = require "dog"
local Light = require "light"
local Menu = require "menu"
local select_menu = require "select_menu"
local cyclone = require "cyclone"

GameState = {
  MENU = "menu",
  GAME = "game",
  LIGHT_LEVEL = "light_level"
}

CurrentState = GameState.MENU

-- Test objects for cyclone
local testCyclone = nil
local testObject = nil

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

  -- Create test cyclone at center, positioned at ground level
  testCyclone = cyclone.new(WIDTH / 2, HEIGHT - 100)
  
  -- Initialize test object near cyclone
  testObject = {
    x = WIDTH / 2 - 100,  -- Position near cyclone
    y = HEIGHT - 200,     -- Near bottom where cyclone is
    vx = 0,
    vy = 0,
    width = 40,
    height = 40,
    isDragging = false
  }
end

function love.update(dt)
  if CurrentState == GameState.MENU then
    Menu:update(dt)
  elseif CurrentState == GameState.GAME then
    Dog:update(dt)
    Light:update(dt)
    select_menu.update(dt)

    -- Update cyclone test
    if testCyclone then
      testCyclone:update(dt)

      -- Update test object physics
      if testObject and not testObject.isDragging then
        -- Apply cyclone force
        local fx, fy = testCyclone:getPushForce(testObject.x + testObject.width / 2,
          testObject.y + testObject.height / 2)
        
        
        testObject.vx = testObject.vx + fx * dt
        testObject.vy = testObject.vy + fy * dt

        -- Apply friction
        testObject.vx = testObject.vx * 0.9
        testObject.vy = testObject.vy * 0.9

        -- Update position
        testObject.x = testObject.x + testObject.vx * dt
        testObject.y = testObject.y + testObject.vy * dt
      end
    end
  end
end

function love.draw()
  if CurrentState == GameState.MENU then
    Menu:draw()
  elseif CurrentState == GameState.GAME then
    -- Draw select_menu first (includes background)
    -- It is bug fornow
    select_menu.draw()

    -- Draw game elements on top if needed
    if backgroundImage then
      --love.graphics.draw(backgroundImage, 0, 0, 0, 0.8, 0.8) --0.8x scale temp
    end
    Dog:draw() -- Uncomment if you want dog visible
    Light:draw()

    -- Draw cyclone test
    if testCyclone then
      testCyclone:draw()

      -- Draw test object
      if testObject then
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.rectangle("fill", testObject.x, testObject.y,
          testObject.width, testObject.height, 5)
        love.graphics.setColor(1, 1, 1)
      end
    end
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
