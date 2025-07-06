local Amirani = {}
Amirani.__index = Amirani

function Amirani:new(x, y)
  local self = setmetatable({}, Amirani)

  self.x = x or 1200
  self.y = y or 200

  -- States
  self.isChained = true
  self.isReleased = false
  self.showingWin = false
  self.releaseAnimationPlaying = false

  -- Assets
  self.chainedImage = love.graphics.newImage("assets/amiran_cut.png")
  self.releasedImage = love.graphics.newImage("assets/amiran_released.png")
  self.releaseSprite = love.graphics.newImage("assets/animations/amiran/amiran_release_sprite.png")
  self.winImage = love.graphics.newImage("assets/win.png")

  -- Release animation (5 frames)
  self.releaseAnimation = {
    frames = 5,
    currentFrame = 1,
    frameWidth = self.releaseSprite:getWidth() / 5,
    frameHeight = self.releaseSprite:getHeight(),
    frameDuration = 0.15,
    frameTimer = 0,
    scale = 2.0
  }

  -- Voice system
  self.voiceTimer = 0
  self.voiceInterval = 5.0 -- Shout every 5 seconds when chained
  self.lastVoiceDistance = 0
  
  -- Chain sound system
  self.chainSoundTimer = 0
  self.chainSoundInterval = 3.0 -- Play chain sounds every 3 seconds
  self.chainSoundActive = false

  -- Interaction
  self.releaseRadius = 80 -- How close the dog needs to be
  self.voiceRadius = 800  -- Maximum distance for voice to be heard

  -- Win display
  self.winAlpha = 0
  self.winScale = 0.1
  self.winAnimationTime = 0

  return self
end

function Amirani:update(dt, dogX, dogY)
  if not dogX or not dogY then return end

  -- Calculate distance to dog
  local dx = dogX - self.x
  local dy = dogY - self.y
  local distance = math.sqrt(dx * dx + dy * dy)

  if self.isChained and not self.isReleased then
    -- Chain sound system when dog is near
    if distance < 300 then -- Play chain sounds when dog is fairly close
      self.chainSoundTimer = self.chainSoundTimer + dt
      if self.chainSoundTimer >= self.chainSoundInterval then
        self.chainSoundTimer = 0
        if SoundManager and SoundManager.play then
          -- Play chain layer sound
          SoundManager:play("chain", "layer", 0.6)
        end
      end
    end

    -- Check if dog is close enough to release
    if distance < self.releaseRadius then
      self:release()
    end
  elseif self.releaseAnimationPlaying then
    -- Update release animation
    self.releaseAnimation.frameTimer = self.releaseAnimation.frameTimer + dt
    if self.releaseAnimation.frameTimer >= self.releaseAnimation.frameDuration then
      self.releaseAnimation.frameTimer = 0
      self.releaseAnimation.currentFrame = self.releaseAnimation.currentFrame + 1

      -- Animation finished
      if self.releaseAnimation.currentFrame > self.releaseAnimation.frames then
        self.releaseAnimationPlaying = false
        self.isReleased = true
        -- Don't immediately show win, let player see released Amirani
        self.winTimer = 0
      end
    end
  elseif self.isReleased and not self.showingWin then
    -- Wait a bit before showing win screen
    self.winTimer = (self.winTimer or 0) + dt
    if self.winTimer > 2.0 then -- Show win screen after 2 seconds
      self.showingWin = true
      -- Stop background music and play victory sound if available
      if SoundManager then
        SoundManager:stopAllLoops()
        -- Play a victory fanfare if available
      end
    end
  elseif self.showingWin then
    -- Animate win screen
    self.winAnimationTime = self.winAnimationTime + dt

    -- Fade in and scale up
    self.winAlpha = math.min(1, self.winAlpha + dt * 2)
    self.winScale = math.min(1, self.winScale + dt * 3)

    -- Add floating effect
    self.winY = math.sin(self.winAnimationTime * 2) * 10
  end
end

function Amirani:release()
  if not self.isChained or self.releaseAnimationPlaying then return end

  self.isChained = false
  self.releaseAnimationPlaying = true
  self.releaseAnimation.currentFrame = 1
  self.releaseAnimation.frameTimer = 0

  -- Play chain breaking sound
  if SoundManager and SoundManager.play then
    -- Play chain break sound with high impact
    SoundManager:play("chain", "breakHigh", 0.9)
  end
end

function Amirani:draw()
  love.graphics.push()
  love.graphics.translate(self.x, self.y)

  if self.isChained and not self.releaseAnimationPlaying then
    -- Draw chained Amirani
    local scale = 0.5
    love.graphics.draw(
      self.chainedImage,
      -self.chainedImage:getWidth() * scale / 2,
      -self.chainedImage:getHeight() * scale / 2,
      0, scale, scale
    )
  elseif self.releaseAnimationPlaying then
    -- Draw release animation
    local frame = self.releaseAnimation.currentFrame - 1
    local quad = love.graphics.newQuad(
      frame * self.releaseAnimation.frameWidth, 0,
      self.releaseAnimation.frameWidth, self.releaseAnimation.frameHeight,
      self.releaseSprite:getDimensions()
    )

    local scale = self.releaseAnimation.scale
    love.graphics.draw(
      self.releaseSprite, quad,
      -self.releaseAnimation.frameWidth * scale / 2,
      -self.releaseAnimation.frameHeight * scale / 2,
      0, scale, scale
    )
  elseif self.isReleased then
    -- Always draw released Amirani after animation (even during win screen)
    local scale = 0.5
    love.graphics.draw(
      self.releasedImage,
      -self.releasedImage:getWidth() * scale / 2,
      -self.releasedImage:getHeight() * scale / 2,
      0, scale, scale
    )
  end

  love.graphics.pop()

  -- Draw win screen overlay
  if self.showingWin then
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Dark overlay
    love.graphics.setColor(0, 0, 0, self.winAlpha * 0.7)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Win image scaled to full width
    love.graphics.setColor(1, 1, 1, self.winAlpha)
    
    -- Calculate scale to fit screen width
    local imageWidth = self.winImage:getWidth()
    local imageHeight = self.winImage:getHeight()
    local targetScale = screenWidth / imageWidth
    
    -- Apply animated scale effect
    local animatedScale = targetScale * self.winScale
    
    -- Center the image
    local winX = screenWidth / 2 - imageWidth * animatedScale / 2
    local winY = screenHeight / 2 - imageHeight * animatedScale / 2 + (self.winY or 0)

    love.graphics.draw(self.winImage, winX, winY, 0, animatedScale, animatedScale)

    love.graphics.setColor(1, 1, 1, 1)
  end
end

function Amirani:debugDraw()
  -- Draw release radius
  love.graphics.setColor(0, 1, 0, 0.3)
  love.graphics.circle("line", self.x, self.y, self.releaseRadius)

  -- Draw voice radius
  love.graphics.setColor(1, 1, 0, 0.1)
  love.graphics.circle("line", self.x, self.y, self.voiceRadius)

  love.graphics.setColor(1, 1, 1, 1)
end

function Amirani:isGameWon()
  return self.showingWin
end

return Amirani
