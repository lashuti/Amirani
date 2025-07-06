-- Gun module for cursor targeting and shooting
local Gun = {}

Gun.active = false
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
end

function Gun:mousepressed(x, y, button, enemies)
    if self.active and button == 1 then
        for i = #enemies, 1, -1 do
            local e = enemies[i]
            if x >= e.x and x <= e.x + e.width and y >= e.y and y <= e.y + e.height then
                table.remove(enemies, i)
                --TODO add some particle too
                break
            end
        end
    end
end

return Gun
