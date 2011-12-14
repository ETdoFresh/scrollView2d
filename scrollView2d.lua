-- Screen Width and Screen Height
local scrollView = {}

function scrollView:new(params)
	local scrollView = display.newGroup() -- Setup the instance
	
	-- Setup private variables
	local scrollBar = display.newGroup()
	local isFocus = false
	local prevPos = {x = 0, y = 0}
	local delta = {x = 0, y = 0}
	local xRatio, yRatio
	
	-- Setup event listeners
	scrollView:addEventListener("touch", scrollView)
	
	-- Touch Function
	function scrollView:touch(event)
		if (event.phase == "began") then
			-- Get starting position
			prevPos.x = event.x
			prevPos.y = event.y
			
			-- Focus self
			display.getCurrentStage():setFocus( self )
			isFocus = true
			
			-- Show Scrollbar
			transition.to(scrollBar, {delay = 1, time = 200, alpha = 1})
			
		elseif (isFocus) then
			if (event.phase == "moved") then
				-- Setup some local variables
				local screenW, screenH = display.contentWidth, display.contentHeight
				local top, left = 0, 0
				local bottomLimit = screenH - self.height
				local rightLimit = screenW - self.width
				
				-- Compute Delta and Update Previous Position (of touch event)
				delta.x = event.x - prevPos.x
				delta.y = event.y - prevPos.y
				prevPos.x = event.x
				prevPos.y = event.y
				
				-- Move scrollView by delta
				self.x = self.x + delta.x
				self.y = self.y + delta.y
				
				-- Limit movement of scrollView
				if (self.x > left) then self.x = left
				elseif (self.x < rightLimit) then self.x = rightLimit end
				if (self.y > top) then self.y = top
				elseif (self.y < bottomLimit) then self.y = bottomLimit end
				
				-- Move Scrollbar
				self:moveScrollBar()
				
			elseif (event.phase == "ended") then
				-- Remove focus so that touch events can happen elsewhere
				display.getCurrentStage():setFocus( nil )
				isFocus = false
			end
		end
	end
	
	function scrollView:addScrollBar(r,g,b,a)
		-- Reset Scrollbar
		local screenW, screenH = display.contentWidth, display.contentHeight
		if (scrollBar) then scrollBar:removeSelf() end
		scrollBar = display.newGroup()
		local sB = scrollBar
		
		-- Default color of scrollBar(s)
		r = r or 0
		g = g or 0
		b = b or 0
		a = a or 128
		
		-- Create Horizontal Scrollbar
		local viewPort = screenW --self.left - self.right
		local scroll = viewPort * self.width / (self.width * 2 - viewPort)
		local scrollGfx = display.newRoundedRect(sB, 0, screenH - 8, scroll, 7, 3)
		scrollGfx:setFillColor(r,g,b,a)
		xRatio = scroll / self.width
		sB.xBar = scrollGfx
		
		-- Create Vertical Scrollbar
		local viewPort = screenH --self.top - self.bottom
		local scroll = viewPort * self.height / (self.height * 2 - viewPort)
		local scrollGfx = display.newRoundedRect(sB, screenW - 8, 0, 7, scroll, 3)
		scrollGfx:setFillColor(r,g,b,a)
		yRatio = scroll / self.height
		sB.yBar = scrollGfx
		
		-- Hide Scrollbar
		transition.to(sB, {delay = 1, time = 200, alpha = 0})
	end
	
	function scrollView:moveScrollBar()
		local screenW, screenH = display.contentWidth, display.contentHeight 
		local sB = scrollBar
		local scrollBar = sB.xBar
		if (scrollBar) then			
			-- Move Horizontal Scrollbar based on scrollView's current position
			scrollBar.x = -self.x * xRatio + scrollBar.width / 2 -- + self.left
			
			-- Restrict the Scrollbar's movement
			if (scrollBar.x < 5 + scrollBar.width / 2) then -- + self.left
				scrollBar.x = 5 + scrollBar.width / 2 -- + self.left
			end
			if (scrollBar.x > screenW - 5 - scrollBar.width / 2) then -- - self.right
				scrollBar.x = screenW - 5 - scrollBar.width / 2 -- - self.right
			end
		end
		
		local scrollBar = sB.yBar
		if (scrollBar) then			
			-- Move Vertical Scrollbar based on scrollView's current position
			scrollBar.y = -self.y * yRatio + scrollBar.height / 2 -- + self.top	
			
			-- Restrict the Scrollbar's movement
			if (scrollBar.y < 5 + scrollBar.height / 2) then -- + self.top
				scrollBar.y = 5 + scrollBar.height / 2 -- + self.top
			end
			if (scrollBar.y > screenH - 5 - scrollBar.height / 2) then -- - self.bottom
				scrollBar.y = screenH - 5 - scrollBar.height / 2 -- - self.bottom
			end
		end
	end
	
	function scrollView:removeScrollBar()
		if (scrollBar) then
			scrollBar:removeSelf()
			scrollBar = nil
		end
	end
	
	function scrollView:cleanUp()
		Runtime:removeEventListener("enterFrame", trackVelocity)
		Runtime:removeEventListener("enterFrame", onRelease)
		self:removeScrollBar()
	end
	
	return scrollView
end

return scrollView