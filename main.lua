display.setStatusBar( display.HiddenStatusBar ) 

--import the scrolling classes
local scrollView = require("scrollView2d")

local background = display.newRect(0, 0, display.viewableContentWidth, display.viewableContentHeight)
background:setFillColor(140, 140, 140)

--Setup a scrollable content group
local scrollView = scrollView:new()

-- add some text to the scrolling screen
local scrollObject = display.newImageRect("scroll.jpg", 1024, 607)
scrollView:insert(scrollObject)
scrollObject.x = scrollView.width/2
scrollObject.y = scrollView.height/2

scrollView:addScrollBar()

-- Removing and Adding the scrollbar fixes orientation issues
local function onOrientation(event)
	scrollView:removeScrollBar()
	scrollView:addScrollBar()
end

Runtime:addEventListener("orientation", onOrientation)