local Light = {}

Light.enabled = false
Light.radius = 100

function Light:load()
    self.disable()
end

function Light.enable()
    Light.enabled = true
    function Light:update(dt)
        self.x, self.y = love.mouse.getPosition()
    end

    function Light:draw()
        if not self.enabled then return end

        -- Draw a black overlay on a canvas
        if not self._canvas then
            self._canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
        end
        self._canvas:renderTo(function()
            love.graphics.clear(0, 0, 0, 0)
            love.graphics.setColor(0, 0, 0, 0.85)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            -- Draw a transparent circle ("cut out")
            love.graphics.setBlendMode("replace", "premultiplied")
            for i = 5, 1, -1 do
                local alpha = 0.18 * i
                love.graphics.setColor(0, 0, 0, 0)
                love.graphics.circle("fill", self.x, self.y, self.radius * (i / 5))
            end
            love.graphics.setBlendMode("alpha")
        end)
        -- Draw the canvas over the scene
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setBlendMode("alpha")
        love.graphics.draw(self._canvas, 0, 0)
    end
end

function Light.disable()
    Light.enabled = false
    function Light:update(dt) end
    function Light:draw() end
end

function Light:keypressed(key)
    if key == "e" then
        if self.enabled then
            self.disable()
        else
            self.enable()
        end
    end
end

return Light
