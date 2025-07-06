-- Gun module for cursor targeting and shooting
local Gun = {}

Gun.active = false
Gun.ammo = 3
Gun.cursorImage = nil
Gun.cursorHotX = 16
Gun.cursorHotY = 16

function Gun:load()
    -- Create a red target cursor (drawn manually, not a real image)
    self.cursorImage = nil -- We'll draw it in love.draw
end

function Gun:activate()
    self.active = true
    love.mouse.setVisible(false)
    self.ammo = 3 -- reset ammo when gun is activated
end

function Gun:deactivate()
    self.active = false
    love.mouse.setVisible(true)
end

function Gun:update(dt)
end

function Gun:draw()
    if self.active then
        local mx, my = love.mouse.getPosition()
        love.graphics.setColor(1, 0, 0)
        love.graphics.setLineWidth(2)
        love.graphics.circle('line', mx, my, 18)
        love.graphics.line(mx-22, my, mx+22, my)
        love.graphics.line(mx, my-22, mx, my+22)
        love.graphics.setColor(1, 1, 1)
    end
    -- Draw ammo count at bottom right, always visible
    local sw, sh = love.graphics.getDimensions()
    love.graphics.setColor(1, 1, 1)
    local text = "[G] Ammo: " .. tostring(self.ammo)
    local font = love.graphics.getFont() or love.graphics.newFont(12)
    local tw = font:getWidth(text)
    local th = font:getHeight()
    love.graphics.print(text, sw - tw - 20, sh - th - 10)
end

function Gun:mousepressed(x, y, button, enemies, eagle)
    if self.active and button == 1 and self.ammo > 0 then
        if SoundManager and SoundManager.playGunShoot then
            SoundManager:playGunShoot(1.0)
        end
        self.ammo = self.ammo - 1
        -- Check for eagle object hit
        if eagle and eagle.active then
            local ex, ey = eagle.x or 0, eagle.y or 0
            local ew, eh = 40, 40
            if eagle.image and eagle.scale then
                ew = eagle.image:getWidth() * eagle.scale
                eh = eagle.image:getHeight() * eagle.scale
            elseif eagle.width and eagle.height then
                ew = eagle.width
                eh = eagle.height
            end
            if x >= ex and x <= ex + ew and y >= ey and y <= ey + eh then
                eagle.active = false
                if SoundManager and SoundManager.playBirdDeath then
                    SoundManager:playBirdDeath(1.0)
                end
                --TODO add some particle too
                return
            end
        end
        -- Check for enemies table as fallback
        for i = #enemies, 1, -1 do
            local e = enemies[i]
            local ex, ey = e.x or 0, e.y or 0
            local ew, eh = 40, 40
            if e.image and e.scale then
                ew = e.image:getWidth() * e.scale
                eh = e.image:getHeight() * e.scale
            elseif e.width and e.height then
                ew = e.width
                eh = e.height
            end
            if e.active ~= false and x >= ex and x <= ex + ew and y >= ey and y <= ey + eh then
                table.remove(enemies, i)
                if SoundManager and SoundManager.playBirdDeath then
                    SoundManager:playBirdDeath(1.0)
                end
                --TODO add some particle too
                break
            end
        end
    end
end

return Gun
