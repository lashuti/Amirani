local select_menu = require("select_menu")

function love.load()
	select_menu.load(1000, 1000)
end

function love.update(dt)
	select_menu.update(dt)
end

function love.draw()
	select_menu.draw()
end

function love.mousepressed(x, y, button)
	select_menu.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	select_menu.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
	select_menu.mousemoved(x, y, dx, dy)
end
