display.setStatusBar( display.HiddenStatusBar ) 

--import the scrolling classes
local scrollView = require("scrollView2d")

local background = display.newRect(0, 0, display.viewableContentWidth, display.viewableContentHeight)
background:setFillColor(140, 140, 140)

-- Setup screen to be scrollable
local scrollObject = display.newGroup()
display.newRect(scrollObject, 10,10, 100, 100)
display.newRect(scrollObject, 15,150, 100, 100)
display.newRect(scrollObject, 5,300, 500, 100)
display.newRect(scrollObject, 300,450, 1000, 700)

--Setup a scrollable content group
local scrollView = scrollView:new()
scrollView:insert(scrollObject)
scrollView:addScrollBar()

-- Removing and Adding the scrollbar fixes orientation issues
local function onOrientation(event)
	scrollView:removeScrollBar()
	scrollView:addScrollBar()
end

Runtime:addEventListener("orientation", onOrientation)