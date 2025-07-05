local select_menu = {}

-- Configuration parameters
local config = {
	screenWidth = 1000,
	screenHeight = 1000,

	menuHeight = 100,
	itemWidth = 80,
	itemHeight = 80,
	itemSpacing = 20,
	numItems = 5,

	-- Colors
	colorBackground = { 0.2, 0.2, 0.25 },
	colorPlacedItem = { 0.3, 0.5, 0.8 },
	colorMenuBackground = { 0.1, 0.1, 0.1, 0.8 },
	colorItemNormal = { 0.5, 0.5, 0.5 },
	colorItemHovered = { 0.7, 0.7, 0.3 },
	colorItemSelected = { 0.3, 0.7, 0.3 },
	colorItemDragging = { 0.3, 0.3, 0.3, 0.5 },
	colorDraggedItem = { 0.3, 0.7, 0.3, 0.6 },
	textColor = { 1, 1, 1 },
	textColorDim = { 1, 1, 1, 0.5 },
	textColorDragged = { 1, 1, 1, 0.6 },
}

-- State
local menu = {}
local selectedItemIndex = nil
local draggingItem = nil
local dragOffsetX, dragOffsetY = 0, 0
local dragX, dragY = 0, 0
local placedItems = {}

function select_menu.load(sw, sh)
	config.screenWidth = sw or config.screenWidth
	config.screenHeight = sh or config.screenHeight

	menu = {}
	placedItems = {}

	for i = 1, config.numItems do
		local x = (
			config.screenWidth - ((config.itemWidth + config.itemSpacing) * config.numItems - config.itemSpacing)
		)
				/ 2
			+ (i - 1) * (config.itemWidth + config.itemSpacing)
		local y = config.screenHeight - config.menuHeight + (config.menuHeight - config.itemHeight) / 2
		table.insert(menu, {
			x = x,
			y = y,
			w = config.itemWidth,
			h = config.itemHeight,
			label = "Item " .. i,
		})
	end
end

function select_menu.draw()
	love.graphics.setColor(config.colorBackground)
	love.graphics.rectangle("fill", 0, 0, config.screenWidth, config.screenHeight - config.menuHeight)

	for _, item in ipairs(placedItems) do
		love.graphics.setColor(config.colorPlacedItem)
		love.graphics.rectangle("fill", item.x, item.y, item.w, item.h, 10, 10)
		love.graphics.setColor(config.textColor)
		love.graphics.printf(item.label, item.x, item.y + item.h / 2 - 6, item.w, "center")
	end

	love.graphics.setColor(config.colorMenuBackground)
	love.graphics.rectangle("fill", 0, config.screenHeight - config.menuHeight, config.screenWidth, config.menuHeight)

	for i, item in ipairs(menu) do
		if draggingItem == i then
			love.graphics.setColor(config.colorItemDragging)
			love.graphics.rectangle("fill", item.x, item.y, item.w, item.h, 10, 10)
			love.graphics.setColor(config.textColorDim)
			love.graphics.printf(item.label, item.x, item.y + item.h / 2 - 6, item.w, "center")
		else
			local mx, my = love.mouse.getPosition()
			local isHovered = mx >= item.x and mx <= item.x + item.w and my >= item.y and my <= item.y + item.h

			if selectedItemIndex == i then
				love.graphics.setColor(config.colorItemSelected)
			elseif isHovered then
				love.graphics.setColor(config.colorItemHovered)
			else
				love.graphics.setColor(config.colorItemNormal)
			end
			love.graphics.rectangle("fill", item.x, item.y, item.w, item.h, 10, 10)

			love.graphics.setColor(config.textColor)
			love.graphics.printf(item.label, item.x, item.y + item.h / 2 - 6, item.w, "center")
		end
	end

	if draggingItem then
		love.graphics.setColor(config.colorDraggedItem)
		love.graphics.rectangle(
			"fill",
			dragX - dragOffsetX,
			dragY - dragOffsetY,
			config.itemWidth,
			config.itemHeight,
			10,
			10
		)
		love.graphics.setColor(config.textColorDragged)
		love.graphics.printf(
			menu[draggingItem].label,
			dragX - dragOffsetX,
			dragY - dragOffsetY + config.itemHeight / 2 - 6,
			config.itemWidth,
			"center"
		)
	end
end

function select_menu.mousepressed(x, y, button)
	if button == 1 then
		for i, item in ipairs(menu) do
			if x >= item.x and x <= item.x + item.w and y >= item.y and y <= item.y + item.h then
				draggingItem = i
				dragOffsetX = x - item.x
				dragOffsetY = y - item.y
				dragX, dragY = x, y
				break
			end
		end
	end
end

function select_menu.mousereleased(x, y, button)
	if button == 1 and draggingItem then
		if y < config.screenHeight - config.menuHeight then
			table.insert(placedItems, {
				x = x - dragOffsetX,
				y = y - dragOffsetY,
				w = config.itemWidth,
				h = config.itemHeight,
				label = menu[draggingItem].label,
			})
		end
		draggingItem = nil
	end
end

function select_menu.mousemoved(x, y, dx, dy)
	if draggingItem then
		dragX, dragY = x, y
	end
end

return select_menu
