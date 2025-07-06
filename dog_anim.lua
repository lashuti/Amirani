-- dog_anim.lua
-- Handles loading and animating a sequence of PNGs for the dog animation

local DogAnim = {}

local frames = {}
local frameIndex = 1
local frameTimer = 0
local frameDuration = 0.1 -- seconds per frame
local scale = 0.4 -- Default scale factor for the dog animation

function DogAnim.load()
    frames = {}
    for i = 1, 6 do -- Change 6 to however many frames you have
        frames[i] = love.graphics.newImage("assets/animations/dog/" .. i .. ".png")
    end
    frameIndex = 1
    frameTimer = 0
    scale = 0.4 -- Set the scale factor for the dog animation (adjust as needed)
end
-- ...existing code...

function DogAnim.update(dt)
    frameTimer = frameTimer + dt
    if frameTimer >= frameDuration then
        frameTimer = frameTimer - frameDuration
        frameIndex = frameIndex + 1
        if frameIndex > #frames then
            frameIndex = 1
        end
    end
end

function DogAnim.draw(x, y, s)
    if #frames > 0 then
        love.graphics.draw(frames[frameIndex], x or 30, y or 30, 0, s or scale, s or scale)
    end
end

function DogAnim.setScale(s)
    scale = s or scale
end

return DogAnim
