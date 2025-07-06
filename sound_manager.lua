local SoundManager = {}

SoundManager.AMBIANCE = {
  NATURE = "nature",
  VALLEY = "valley",
  WIND = "wind",
  TENSION = "tension",
  LAVA = "lava"
}

SoundManager.CATEGORY = {
  AMBIANCE = "ambiance",
  AMIRANI = "amirani",
  DOG = "dog",
  WATER = "water",
  LAVA = "lava",
  DIRT = "dirt",
  CHAIN = "chain"
}

SoundManager.DOG_SOUND = {
  BARK1 = "bark1",
  BARK2 = "bark2",
  BARK3 = "bark3",
  BARK4 = "bark4",
  BARK5 = "bark5",
  FOOTSTEP1 = "footstep1",
  FOOTSTEP2 = "footstep2",
  FOOTSTEP3 = "footstep3",
  WHINE = "whine"
}

SoundManager.WATER_SOUND = {
  BOTTLE_SHAKE1 = "bottleShake1",
  BOTTLE_SHAKE2 = "bottleShake2",
  BOTTLE_SHAKE3 = "bottleShake3",
  BOTTLE_SHAKE4 = "bottleShake4",
  BOTTLE_SHAKE5 = "bottleShake5",
  BOTTLE_SHAKE6 = "bottleShake6",
  BOTTLE_GRAB1 = "bottleGrab1",
  BOTTLE_GRAB2 = "bottleGrab2",
  SPLASH1 = "splash1",
  SPLASH2 = "splash2",
  SPLASH3 = "splash3",
  SPLASH4 = "splash4"
}

SoundManager.LAVA_SOUND = {
  LOOP = "loop",
  LOOP_THICK = "loopThick",
  DISTANCE = "distance",
  WATER_ON_LAVA = "waterOnLava",
  WATER_EVAPORATE = "waterEvaporate"
}

SoundManager.DIRT_SOUND = {
  GRAB1 = "grab1",
  GRAB2 = "grab2",
  WALL_PLACE1 = "wallPlace1",
  WALL_PLACE2 = "wallPlace2",
  BLOCK_PLACE = "blockPlace",
  BLOCK_PLACE_IMPACT = "blockPlaceImpact"
}

SoundManager.CHAIN_SOUND = {
  LAYER = "layer",
  BREAK_HIGH = "breakHigh",
  BREAK_LOW = "breakLow"
}

SoundManager.AMIRANI_SOUND = {
  SHOUT_CLOSE1 = "shoutClose1",
  SHOUT_CLOSE2 = "shoutClose2",
  SHOUT_MID = "shoutMid",
  SHOUT_FAR = "shoutFar"
}

SoundManager.sounds = {
  -- Ambiance & Environmental
  ambiance = {
    nature = nil,
    valley1 = nil,
    valley2 = nil,
    valley3 = nil,
    heavyWind = nil,
    windDirt = nil,
    tension = nil
  },

  -- Character sounds
  amirani = {
    shoutClose1 = nil,
    shoutClose2 = nil,
    shoutMid = nil,
    shoutFar = nil
  },

  -- Dog sounds
  dog = {
    bark1 = nil,
    bark2 = nil,
    bark3 = nil,
    bark4 = nil,
    bark5 = nil,
    footstep1 = nil,
    footstep2 = nil,
    footstep3 = nil,
    whine = nil
  },

  -- Water & Bottle
  water = {
    bottleShake1 = nil,
    bottleShake2 = nil,
    bottleShake3 = nil,
    bottleShake4 = nil,
    bottleShake5 = nil,
    bottleShake6 = nil,
    bottleGrab1 = nil,
    bottleGrab2 = nil,
    splash1 = nil,
    splash2 = nil,
    splash3 = nil,
    splash4 = nil
  },

  -- Lava
  lava = {
    loop = nil,
    loopThick = nil,
    distance = nil,
    waterOnLava = nil,
    waterEvaporate = nil
  },

  -- Dirt/Block
  dirt = {
    grab1 = nil,
    grab2 = nil,
    wallPlace1 = nil,
    wallPlace2 = nil,
    blockPlace = nil,
    blockPlaceImpact = nil
  },

  -- Chain
  chain = {
    layer = nil,
    breakHigh = nil,
    breakLow = nil
  }
}

SoundManager.activeLoops = {}

SoundManager.masterVolume = 1.0
SoundManager.sfxVolume = 1.0
SoundManager.ambientVolume = 0.7
SoundManager.musicVolume = 0.8

function SoundManager:load()
  -- Load all sound files
  local assets = "assets/sounds/"

  -- Ambiance
  self.sounds.ambiance.nature = love.audio.newSource(assets .. "nature ambaince_02.wav", "static")
  self.sounds.ambiance.valley1 = love.audio.newSource(assets .. "Valley ambiance_01-001.wav", "static")
  self.sounds.ambiance.valley2 = love.audio.newSource(assets .. "Valley ambiance_01-002.wav", "static")
  self.sounds.ambiance.valley3 = love.audio.newSource(assets .. "Valley ambiance_01-003.wav", "static")
  self.sounds.ambiance.heavyWind = love.audio.newSource(assets .. "heavy wind loop.wav", "static")
  self.sounds.ambiance.windDirt = love.audio.newSource(assets .. "wind with dirt wall stereo.wav", "static")
  self.sounds.ambiance.tension = love.audio.newSource(assets .. "tension layer .wav", "static")

  -- Amirani
  self.sounds.amirani.shoutClose1 = love.audio.newSource(assets .. "amirani shout close-001.wav", "static")
  self.sounds.amirani.shoutClose2 = love.audio.newSource(assets .. "amirani shout close-002.wav", "static")
  self.sounds.amirani.shoutMid = love.audio.newSource(assets .. "amirani shout mid distance.wav", "static")
  self.sounds.amirani.shoutFar = love.audio.newSource(assets .. "amirqani shout far.wav", "static")

  -- Dog
  self.sounds.dog.bark1 = love.audio.newSource(assets .. "dog bark 01.wav", "static")
  self.sounds.dog.bark2 = love.audio.newSource(assets .. "dog bark 02.wav", "static")
  self.sounds.dog.bark3 = love.audio.newSource(assets .. "dog bark 03.wav", "static")
  self.sounds.dog.bark4 = love.audio.newSource(assets .. "dog bark 04.wav", "static")
  self.sounds.dog.bark5 = love.audio.newSource(assets .. "dog bark 05.wav", "static")
  self.sounds.dog.footstep1 = love.audio.newSource(assets .. "dog FS loop 01.wav", "static")
  self.sounds.dog.footstep2 = love.audio.newSource(assets .. "dog FS loop 02.wav", "static")
  self.sounds.dog.footstep3 = love.audio.newSource(assets .. "dog FS loop 03.wav", "static")
  self.sounds.dog.whine = love.audio.newSource(assets .. "dog fast whine 01.wav", "static")

  -- Water & Bottle
  self.sounds.water.bottleShake1 = love.audio.newSource(assets .. "BOTTLE Water Shake Single 01.wav", "static")
  self.sounds.water.bottleShake2 = love.audio.newSource(assets .. "BOTTLE Water Shake Single 02.wav", "static")
  self.sounds.water.bottleShake3 = love.audio.newSource(assets .. "BOTTLE Water Shake Single 03.wav", "static")
  self.sounds.water.bottleShake4 = love.audio.newSource(assets .. "water bottle shake_02-001.wav", "static")
  self.sounds.water.bottleShake5 = love.audio.newSource(assets .. "water bottle shake_02-002.wav", "static")
  self.sounds.water.bottleShake6 = love.audio.newSource(assets .. "water bottle shake_03.wav", "static")
  self.sounds.water.bottleGrab1 = love.audio.newSource(assets .. "inventory water bottle grab 01.wav", "static")
  self.sounds.water.bottleGrab2 = love.audio.newSource(assets .. "inventory water bottle grab 02.wav", "static")
  self.sounds.water.splash1 = love.audio.newSource(assets .. "water splash_01.wav", "static")
  self.sounds.water.splash2 = love.audio.newSource(assets .. "water splash_02.wav", "static")
  self.sounds.water.splash3 = love.audio.newSource(assets .. "water splash_03.wav", "static")
  self.sounds.water.splash4 = love.audio.newSource(assets .. "water splash_04.wav", "static")

  -- Lava
  self.sounds.lava.loop = love.audio.newSource(assets .. "lava loop.wav", "static")
  self.sounds.lava.loopThick = love.audio.newSource(assets .. "lava loop thick.wav", "static")
  self.sounds.lava.distance = love.audio.newSource(assets .. "lava in distance.wav", "static")
  self.sounds.lava.waterOnLava = love.audio.newSource(assets .. "water on lava with cracks.wav", "static")
  self.sounds.lava.waterEvaporate = love.audio.newSource(assets .. "water splash on lava and it evaporates.wav", "static")

  -- Dirt/Block
  self.sounds.dirt.grab1 = love.audio.newSource(assets .. "dirt block grab.wav", "static")
  self.sounds.dirt.grab2 = love.audio.newSource(assets .. "dirt block grab 2.wav", "static")
  self.sounds.dirt.wallPlace1 = love.audio.newSource(assets .. "dirt wall place 01.wav", "static")
  self.sounds.dirt.wallPlace2 = love.audio.newSource(assets .. "dirt wall place 02.wav", "static")
  self.sounds.dirt.blockPlace = love.audio.newSource(assets .. "place dirt block.wav", "static")
  self.sounds.dirt.blockPlaceImpact = love.audio.newSource(assets .. "place dirt block with impact.wav", "static")

  -- Chain
  self.sounds.chain.layer = love.audio.newSource(assets .. "chain layer.wav", "static")
  self.sounds.chain.breakHigh = love.audio.newSource(assets .. "chain break with high impact.wav", "static")
  self.sounds.chain.breakLow = love.audio.newSource(assets .. "chain break with low impact.wav", "static")

  -- Set looping for appropriate sounds
  self.sounds.ambiance.nature:setLooping(true)
  self.sounds.ambiance.valley1:setLooping(true)
  self.sounds.ambiance.valley2:setLooping(true)
  self.sounds.ambiance.valley3:setLooping(true)
  self.sounds.ambiance.heavyWind:setLooping(true)
  self.sounds.ambiance.windDirt:setLooping(true)
  self.sounds.ambiance.tension:setLooping(true)
  self.sounds.lava.loop:setLooping(true)
  self.sounds.lava.loopThick:setLooping(true)
  self.sounds.lava.distance:setLooping(true)
  self.sounds.dog.footstep1:setLooping(true)
  self.sounds.dog.footstep2:setLooping(true)
  self.sounds.dog.footstep3:setLooping(true)
end

function SoundManager:play(category, soundName, volume, pitch)
  local sound = self.sounds[category] and self.sounds[category][soundName]
  if not sound then
    print("Warning: Sound not found -", category, soundName)
    return
  end

  -- Clone the source for simultaneous playback
  local source = sound:clone()
  source:setVolume((volume or 1.0) * self.sfxVolume * self.masterVolume)
  source:setPitch(pitch or 1.0)
  source:play()

  return source
end

-- Start a looping sound
function SoundManager:startLoop(category, soundName, volume, pitch)
  local sound = self.sounds[category] and self.sounds[category][soundName]
  if not sound then
    print("Warning: Sound not found -", category, soundName)
    return
  end

  -- Stop existing instance if already playing
  local key = category .. "." .. soundName
  if self.activeLoops[key] then
    self.activeLoops[key]:stop()
  end

  -- Start new loop
  local source = sound:clone()
  source:setLooping(true)
  source:setVolume((volume or 1.0) * self.ambientVolume * self.masterVolume)
  source:setPitch(pitch or 1.0)
  source:play()

  self.activeLoops[key] = source
  return source
end

-- Stop a looping sound
function SoundManager:stopLoop(category, soundName)
  local key = category .. "." .. soundName
  if self.activeLoops[key] then
    self.activeLoops[key]:stop()
    self.activeLoops[key] = nil
  end
end

-- Stop all loops
function SoundManager:stopAllLoops()
  for key, source in pairs(self.activeLoops) do
    source:stop()
  end
  self.activeLoops = {}
end

-- Helper function to play random sounds
function SoundManager:playRandom(category, soundPrefix, count, volume)
  local soundName = soundPrefix .. math.random(1, count)
  return self:play(category, soundName, volume)
end

-- Convenience functions for common sounds
function SoundManager:playDogBark(volume)
  return self:playRandom("dog", "bark", 5, volume)
end

function SoundManager:playWaterSplash(volume)
  return self:playRandom("water", "splash", 4, volume)
end

function SoundManager:playBottleShake(volume)
  local shakes = { "bottleShake1", "bottleShake2", "bottleShake3", "bottleShake4", "bottleShake5", "bottleShake6" }
  local shake = shakes[math.random(1, #shakes)]
  return self:play("water", shake, volume)
end

function SoundManager:playWaterOnFire(volume)
  -- Play the water evaporation sound when water hits fire
  return self:play("lava", "waterEvaporate", volume or 0.8)
end

function SoundManager:playAmiraniShout(distance)
  if distance < 200 then
    return self:playRandom("amirani", "shoutClose", 2)
  elseif distance < 500 then
    return self:play("amirani", "shoutMid")
  else
    return self:play("amirani", "shoutFar")
  end
end

function SoundManager:startAmbiance(type)
  if type == self.AMBIANCE.NATURE then
    self:startLoop(self.CATEGORY.AMBIANCE, "nature", 0.5)
  elseif type == self.AMBIANCE.VALLEY then
    -- Play random valley ambiance
    local valley = "valley" .. math.random(1, 3)
    self:startLoop(self.CATEGORY.AMBIANCE, valley, 0.5)
  elseif type == self.AMBIANCE.WIND then
    self:startLoop(self.CATEGORY.AMBIANCE, "heavyWind", 0.6)
  elseif type == self.AMBIANCE.TENSION then
    self:startLoop(self.CATEGORY.AMBIANCE, "tension", 0.4)
  elseif type == self.AMBIANCE.LAVA then
    self:startLoop(self.CATEGORY.LAVA, self.LAVA_SOUND.LOOP, 0.7)
    self:startLoop(self.CATEGORY.LAVA, self.LAVA_SOUND.DISTANCE, 0.3)
  end
end

function SoundManager:stopAmbiance()
  self:stopLoop("ambiance", "nature")
  self:stopLoop("ambiance", "valley1")
  self:stopLoop("ambiance", "valley2")
  self:stopLoop("ambiance", "valley3")
  self:stopLoop("ambiance", "heavyWind")
  self:stopLoop("ambiance", "windDirt")
  self:stopLoop("ambiance", "tension")
  self:stopLoop("lava", "loop")
  self:stopLoop("lava", "loopThick")
  self:stopLoop("lava", "distance")
end

function SoundManager:setMasterVolume(volume)
  self.masterVolume = math.max(0, math.min(1, volume))
  self:updateAllVolumes()
end

function SoundManager:setSFXVolume(volume)
  self.sfxVolume = math.max(0, math.min(1, volume))
end

function SoundManager:setAmbientVolume(volume)
  self.ambientVolume = math.max(0, math.min(1, volume))
  self:updateAllVolumes()
end

function SoundManager:updateAllVolumes()
  for key, source in pairs(self.activeLoops) do
    source:setVolume(source:getVolume()) -- This will recalculate with new master volume
  end
end

return SoundManager
