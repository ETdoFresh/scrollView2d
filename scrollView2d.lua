-- Screen Width and Screen Height
local scrollView = {}

function scrollView:new(params)
	local scrollView = display.newGroup() -- Setup the instance
	
	-- Setup private variables
	local scrollBar = display.newGroup()
	local isFocus = false
	local prevPos = {x = 0, y = 0}
	local delta = {x = 0, y = 0}
	local prevTime = {x = 0, y = 0}
	local trackTime = 0
	local trackPos = {x = 0, y = 0}
	local velocity = {x = 0, y = 0}
	local xRatio, yRatio
	local friction = 0.9
	local tween = {x = nil, y = nil}
	
	-- Setup event listeners
	scrollView:addEventListener("touch", scrollView)
	
	-- As the screen is touched, velocity is computed
	local function trackVelocity(event)
		-- get time that has passed and update prevTime
		local timePassed = event.time - trackTime
		trackTime = trackTime + timePassed
		
		-- Obtain velocities and update trackPos
		if (trackPos.x) then
			velocity.x = (scrollView.x - trackPos.x) / timePassed
		end
		trackPos.x = scrollView.x
		if (trackPos.y) then
			velocity.y = (scrollView.y - trackPos.y) / timePassed
		end
		trackPos.y = scrollView.y
	end
	
	-- When the screen is released, move screen with velocity
	local function onReleaseX(event)
		local timePassed = event.time - prevTime.x
		prevTime.x = prevTime.x + timePassed
		
		-- Turn off scrolling if velocity is near zero
		if (math.abs(velocity.x) < .01) then
			velocity.x = 0
		-- Slowdown velocity by friction and move scrollView
		else
			velocity.x = velocity.x * friction
			scrollView.x = math.floor(scrollView.x + velocity.x * timePassed)
		end
		
		-- If scrollView is outside of screen horizontally, bring it back in
		local screenW, screenH = display.contentWidth, display.contentHeight
		local leftLimit = 0
		local rightLimit = screenW - scrollView.width -- - scrollView.right
		if ( scrollView.x > leftLimit ) then
			velocity.x = 0
			tween.x = transition.to(scrollView, { time=400, x=leftLimit, transition=easing.outQuad})
		elseif ( scrollView.x < rightLimit and rightLimit < 0 ) then 
			velocity.x = 0
			tween.x = transition.to(scrollView, { time=400, x=rightLimit, transition=easing.outQuad})
		elseif ( scrollView.x < rightLimit ) then 
			velocity.x = 0
			tween.x = transition.to(scrollView, { time=400, x=leftLimit, transition=easing.outQuad})        
		end 
		
		-- Move Scrollbar
		scrollView:moveScrollBarX()
		
		-- Stop running this function when velocities is 0
		if (velocity.x == 0) then
			Runtime:removeEventListener("enterFrame", onReleaseX)
			
			-- Hide Scrollbar
			transition.to(scrollBar, {delay = 1, time = 200, alpha = 0})
		end
	end
	
	-- When the screen is released, move screen with velocity
	local function onReleaseY(event)
		local timePassed = event.time - prevTime.y
		prevTime.y = prevTime.y + timePassed
		
		-- Turn off scrolling if velocity is near zero
		if (math.abs(velocity.y) < .01) then
			velocity.y = 0
		-- Slowdown velocity by friction and move scrollView
		else
			velocity.y = velocity.y * friction
			scrollView.y = math.floor(scrollView.y + velocity.y * timePassed)
		end
		
		-- If scrollView is outside of screen vertically, bring it back in
		local screenW, screenH = display.contentWidth, display.contentHeight
		local upperLimit = 0
		local bottomLimit = screenH - scrollView.height -- - scrollView.bottom
		if ( scrollView.y > upperLimit ) then
			velocity.y = 0
			tween.y = transition.to(scrollView, { time=400, y=upperLimit, transition=easing.outQuad})
		elseif ( scrollView.y < bottomLimit and bottomLimit < 0 ) then 
			velocity.y = 0
			tween.y = transition.to(scrollView, { time=400, y=bottomLimit, transition=easing.outQuad})
		elseif ( scrollView.y < bottomLimit ) then 
			velocity.y = 0
			tween.y = transition.to(scrollView, { time=400, y=upperLimit, transition=easing.outQuad})        
		end
			
		-- Move Scrollbar
		scrollView:moveScrollBarY()
		
		-- Stop running this function when velocity is 0
		if (velocity.y == 0) then
			Runtime:removeEventListener("enterFrame", onReleaseY)
			
			-- Hide Scrollbar
			transition.to(scrollBar, {delay = 1, time = 200, alpha = 0})
		end
	end
	
	-- Touch Function
	function scrollView:touch(event)
		if (event.phase == "began") then
			-- Get starting position
			prevPos.x = event.x
			prevPos.y = event.y
			
			-- Focus self
			display.getCurrentStage():setFocus( self )
			isFocus = true
			
			-- Cancel any movement currently happening
			if (tween.x) then transition.cancel(tween.x) end
			if (tween.y) then transition.cancel(tween.y) end
			
			-- Show Scrollbar
			transition.to(scrollBar, {delay = 1, time = 200, alpha = 1})
			
			-- Start tracking velocity
			Runtime:addEventListener("enterFrame", trackVelocity)
			Runtime:removeEventListener("enterFrame", onReleaseX)
			Runtime:removeEventListener("enterFrame", onReleaseY)
			trackTime = 0
			trackPos.x = 0
			trackPos.y = 0
			
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
				
				-- If scrollView is outside of bounds, move scrollView by a divided factor
				local factor = 5
				if (self.x > left or self.x < rightLimit) then
					self.x = self.x + delta.x / factor
				-- Else move scrollView by delta
				else
					self.x = self.x + delta.x
				end
				
				-- If scrollView is outside of bounds, move scrollView by a divided factor
				if (self.y > top or self.y < bottomLimit) then
					self.y = self.y + delta.y / factor
				-- Else move scrollView by delta
				else
					self.y = self.y + delta.y
				end
				
				-- Move Scrollbar
				self:moveScrollBarX()
				self:moveScrollBarY()
				
			elseif (event.phase == "ended") then
				-- Remove focus so that touch events can happen elsewhere
				display.getCurrentStage():setFocus( nil )
				isFocus = false
				
				-- Stop tracking velocity and move scrollView accordingly
				Runtime:addEventListener("enterFrame", onReleaseX)
				Runtime:addEventListener("enterFrame", onReleaseY)
				Runtime:removeEventListener("enterFrame", trackVelocity)
				prevTime.x = trackTime
				prevTime.y = trackTime
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
	
	function scrollView:moveScrollBarX()
		local screenW, screenH = display.contentWidth, display.contentHeight 
		local scrollBar = scrollBar.xBar
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
	end
	
	function scrollView:moveScrollBarY()
		local screenW, screenH = display.contentWidth, display.contentHeight 
		local scrollBar = scrollBar.yBar
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