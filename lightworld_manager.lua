local LightWorld = require "lib.light_world.lib"

local LightWorldManager = {}
LightWorldManager.enabled = false
LightWorldManager.world = nil
LightWorldManager.lights = {}
LightWorldManager.bodies = {}
LightWorldManager.mouseLight = nil

function LightWorldManager:load()
    -- Create the light world with ambient light
    self.world = LightWorld({
        ambient = {0.2, 0.2, 0.2}, -- Dark ambient light
        refractionStrength = 16,
        reflectionVisibility = 0.75,
    })
    
    -- Create mouse light only
    self.mouseLight = self.world:newLight(0, 0, 200, 190, 130, 300)
    self.mouseLight:setGlowStrength(0.3)
    table.insert(self.lights, self.mouseLight)
    
    self.enabled = false
end

function LightWorldManager:update(dt)
    if not self.enabled then return end
    
    -- Update light world
    self.world:update(dt)
    
    -- Update mouse light position
    local mx, my = love.mouse.getPosition()
    self.mouseLight:setPosition(mx, my)
end

function LightWorldManager:draw(drawFunc)
    if not self.enabled then
        -- Just draw normally without lighting
        drawFunc()
        return
    end
    
    -- Draw everything with lighting
    self.world:draw(drawFunc)
end

function LightWorldManager:addLight(x, y, r, g, b, range)
    local light = self.world:newLight(x, y, r, g, b, range or 200)
    table.insert(self.lights, light)
    return light
end

function LightWorldManager:addRectangleBody(x, y, width, height)
    local body = self.world:newRectangle(x, y, width, height)
    table.insert(self.bodies, body)
    return body
end

function LightWorldManager:addCircleBody(x, y, radius)
    local body = self.world:newCircle(x, y, radius)
    table.insert(self.bodies, body)
    return body
end

function LightWorldManager:addPolygonBody(...)
    local body = self.world:newPolygon(...)
    table.insert(self.bodies, body)
    return body
end

function LightWorldManager:setTranslation(x, y, scale)
    if self.world then
        self.world:setTranslation(x, y, scale)
    end
end

function LightWorldManager:toggle()
    self.enabled = not self.enabled
end

function LightWorldManager:keypressed(key)
    if key == "e" then
        self:toggle()
    end
end

return LightWorldManager