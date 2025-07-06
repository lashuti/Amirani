local select_menu = {}
local waterBottle = require("water_bottle")
local settings = require("settings")

-- Configuration parameters
local config = {
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
local waterBottles = {}
local activeBottle = nil

-- Snap areas (grey rectangles)
local snapAreas = {
    {x = 180, y = 200, w = 100, h = 100},
    {x = 400, y = 200, w = 100, h = 100},
    {x = 620, y = 200, w = 100, h = 100},
}
local snapHighlightIndex = nil

function select_menu.load()
	config.screenWidth = settings.WIDTH
	config.screenHeight = settings.HEIGHT

	menu = {}
	placedItems = {}

	for i = 1, config.numItems do
		local x = (
			config.screenWidth - ((config.itemWidth + config.itemSpacing) * config.numItems - config.itemSpacing)
		)
				/ 2
			+ (i - 1) * (config.itemWidth + config.itemSpacing)
		local y = config.screenHeight - config.menuHeight + (config.menuHeight - config.itemHeight) / 2
		
		local itemType = "normal"
		local label = "Item " .. i
		if i == 1 then
			itemType = "water_bottle"
			label = ""  -- No label for water bottle
		end
		
		table.insert(menu, {
			x = x,
			y = y,
			w = config.itemWidth,
			h = config.itemHeight,
			label = label,
			type = itemType,
		})
	end
end

function select_menu.draw()
	-- Remove or comment out the next two lines to keep the area above the menu transparent
	-- love.graphics.setColor(config.colorBackground)
	-- love.graphics.rectangle("fill", 0, 0, config.screenWidth, config.screenHeight - config.menuHeight)

	-- Draw regular placed items
	for _, item in ipairs(placedItems) do
		-- Draw wetness effect if item is wet
		if item.wetness and item.wetness > 0 then
			love.graphics.setColor(0.2, 0.4, 0.8, item.wetness * 0.3)
			love.graphics.rectangle("fill", item.x - 2, item.y - 2, item.w + 4, item.h + 4, 12, 12)
		end
		
		love.graphics.setColor(config.colorPlacedItem)
		love.graphics.rectangle("fill", item.x, item.y, item.w, item.h, 10, 10)
		
		-- Add water droplets on wet items
		if item.wetness and item.wetness > 0 then
			love.graphics.setColor(0.3, 0.6, 1, item.wetness * 0.5)
			for i = 1, 3 do
				local dx = math.sin(love.timer.getTime() * 2 + i) * 5
				local dy = math.cos(love.timer.getTime() * 3 + i) * 3
				love.graphics.circle("fill", item.x + item.w/2 + dx, item.y + item.h - 10 + dy, 2)
			end
		end
		
		love.graphics.setColor(config.textColor)
		love.graphics.printf(item.label, item.x, item.y + item.h / 2 - 6, item.w, "center")
	end
	
	-- Draw water bottles
	for _, bottle in ipairs(waterBottles) do
		bottle:draw()
	end

	love.graphics.setColor(config.colorMenuBackground)
	love.graphics.rectangle("fill", 0, config.screenHeight - config.menuHeight, config.screenWidth, config.menuHeight)

	for i, item in ipairs(menu) do
		if draggingItem == i then
			love.graphics.setColor(config.colorItemDragging)
			love.graphics.rectangle("fill", item.x, item.y, item.w, item.h, 10, 10)
			love.graphics.setColor(config.textColorDim)
			-- No index for menu, only for snap areas
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

			-- Draw water bottle icon for water items
			if item.type == "water_bottle" then
				love.graphics.push()
				love.graphics.translate(item.x + item.w/2, item.y + item.h/2)
				
				-- Bottle body
				love.graphics.setColor(0.3, 0.6, 1, 0.7)
				love.graphics.rectangle("fill", -12, -20, 24, 35, 4)
				
				-- Bottle cap
				love.graphics.setColor(0.5, 0.5, 0.6)
				love.graphics.rectangle("fill", -7, -25, 14, 8, 2)
				
				-- Water level inside
				love.graphics.setColor(0.2, 0.5, 0.9, 0.8)
				love.graphics.rectangle("fill", -10, -5, 20, 20, 3)
				
				love.graphics.pop()
			end
		end
	end

	-- Draw snap areas
    for i, area in ipairs(snapAreas) do
        if snapHighlightIndex == i then
            love.graphics.setColor(0.2, 0.8, 0.2, 0.5) -- green highlight
            love.graphics.setLineWidth(5)
            love.graphics.rectangle("line", area.x, area.y, area.w, area.h, 12, 12)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 0.18)
            love.graphics.rectangle("fill", area.x, area.y, area.w, area.h, 12, 12)
            love.graphics.setColor(0.5, 0.5, 0.5, 0.4)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", area.x, area.y, area.w, area.h, 12, 12)
        end
        -- Draw index number in the center of empty snap area
        local isOccupied = false
        for _, item in ipairs(placedItems) do
            if item.x == area.x and item.y == area.y then
                isOccupied = true
                break
            end
        end
        if not isOccupied then
            love.graphics.setColor(1, 1, 1, 0.7)
            love.graphics.printf(tostring(i), area.x, area.y + area.h/2 - 12, area.w, "center")
        end
    end
    love.graphics.setLineWidth(1)

	if draggingItem then
		local item = menu[draggingItem]
		if item.type == "water_bottle" then
			-- Draw water bottle preview while dragging
			love.graphics.push()
			love.graphics.translate(dragX, dragY)
			
			-- Semi-transparent bottle
			love.graphics.setColor(0.3, 0.6, 1, 0.5)
			love.graphics.rectangle("fill", -12, -20, 24, 35, 4)
			
			love.graphics.setColor(0.5, 0.5, 0.6, 0.5)
			love.graphics.rectangle("fill", -7, -25, 14, 8, 2)
			
			love.graphics.setColor(0.2, 0.5, 0.9, 0.4)
			love.graphics.rectangle("fill", -10, -5, 20, 20, 3)
			
			love.graphics.pop()
		else
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
				item.label,
				dragX - dragOffsetX,
				dragY - dragOffsetY + config.itemHeight / 2 - 6,
				config.itemWidth,
				"center"
			)
		end
	end
end

function select_menu.mousepressed(x, y, button)
	if button == 1 then
		-- Check if clicking on an existing water bottle
		for _, bottle in ipairs(waterBottles) do
			local dx = x - bottle.x
			local dy = y - bottle.y
			if math.abs(dx) < bottle.width and math.abs(dy) < bottle.height then
				bottle:startDrag()
				activeBottle = bottle
				return
			end
		end
		
		-- Check menu items
		for i, item in ipairs(menu) do
			if x >= item.x and x <= item.x + item.w and y >= item.y and y <= item.y + item.h then
				draggingItem = i
				dragOffsetX = item.w / 2  -- Center the drag
				dragOffsetY = item.h / 2
				dragX, dragY = x, y
				break
			end
		end
	end
end

function select_menu.mousereleased(x, y, button)
	if button == 1 then
		if activeBottle then
			activeBottle:stopDrag()
			activeBottle = nil
		elseif draggingItem then
			if y < config.screenHeight - config.menuHeight then
				local item = menu[draggingItem]
				local snapTo = nil
				if snapHighlightIndex then
					snapTo = snapAreas[snapHighlightIndex]
				end
				if item.type == "water_bottle" then
					local bx, by = x, y
					if snapTo then
						bx = snapTo.x + snapTo.w/2
						by = snapTo.y + snapTo.h/2
					end
					local bottle = waterBottle.new(bx, by)
					table.insert(waterBottles, bottle)
				else
					local px, py = x - dragOffsetX, y - dragOffsetY
					if snapTo then
						px = snapTo.x
						py = snapTo.y
					end
					table.insert(placedItems, {
						x = px,
						y = py,
						w = config.itemWidth,
						h = config.itemHeight,
						label = item.label,
					})
				end
			end
			draggingItem = nil
			snapHighlightIndex = nil
		end
	end
end

function select_menu.mousemoved(x, y, dx, dy)
    if draggingItem then
        dragX, dragY = x, y
        -- Check for snap area collision
        snapHighlightIndex = nil
        local itemW, itemH = config.itemWidth, config.itemHeight
        local dragLeft = dragX - dragOffsetX
        local dragTop = dragY - dragOffsetY
        for i, area in ipairs(snapAreas) do
            if dragLeft + itemW > area.x and dragLeft < area.x + area.w and
               dragTop + itemH > area.y and dragTop < area.y + area.h then
                snapHighlightIndex = i
                break
            end
        end
    end
end

function select_menu.update(dt)
	-- Update all water bottles
	for _, bottle in ipairs(waterBottles) do
		bottle:update(dt)
	end
	
	-- Check water droplet collisions with placed items
	for _, bottle in ipairs(waterBottles) do
		local droplets = bottle:getDroplets()
		for _, droplet in ipairs(droplets) do
			-- Check collision with placed items
			for _, item in ipairs(placedItems) do
				if droplet.x >= item.x and droplet.x <= item.x + item.w and
				   droplet.y >= item.y and droplet.y <= item.y + item.h then
					-- Water hit the item!
					droplet.life = 0 -- Remove droplet
					
					-- Visual feedback (optional)
					item.wetness = (item.wetness or 0) + 0.1
					item.wetness = math.min(1, item.wetness)
				end
			end
		end
	end
	
	-- Dry out items slowly
	for _, item in ipairs(placedItems) do
		if item.wetness then
			item.wetness = item.wetness - dt * 0.1
			if item.wetness <= 0 then
				item.wetness = nil
			end
		end
	end
end

-- Get all collidable objects (for external collision checks)
function select_menu.getCollidableObjects()
	local objects = {}
	
	-- Add placed items
	for _, item in ipairs(placedItems) do
		table.insert(objects, {
			x = item.x,
			y = item.y,
			width = item.w,
			height = item.h,
			type = "item",
			data = item
		})
	end
	
	-- Add water bottles as collidable
	for _, bottle in ipairs(waterBottles) do
		table.insert(objects, {
			x = bottle.x - bottle.width/2,
			y = bottle.y - bottle.height/2,
			width = bottle.width,
			height = bottle.height,
			type = "bottle",
			data = bottle
		})
	end
	
	return objects
end

-- Get all water droplets (for external systems)
function select_menu.getAllDroplets()
	local allDroplets = {}
	for _, bottle in ipairs(waterBottles) do
		local droplets = bottle:getDroplets()
		for _, droplet in ipairs(droplets) do
			table.insert(allDroplets, droplet)
		end
	end
	return allDroplets
end

return select_menu
