--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')

local Shared              = ReplicatedStorage:WaitForChild('SharedModules')
local Utils               = ReplicatedStorage:WaitForChild('Utils')
local Vendor              = ReplicatedFirst.Vendor
local TweenBuilder        = require(Vendor.Tween)

local module = {
	Tags = {
		MouseHoverAnimation = "MouseHoverAnimation",
		LeftSidebarButton   = "LeftSidebarButton",
		ComputerSideButtons = "ComputerSideButtons",
	},
	Attribues = {
		OpenSize = "OpenSize",
		Shortcut = "Shortcut",		
	}
}

local defaultInfo = TweenInfo.new(.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

function module.open(frame:Frame, targetSize:UDim2, TInfo : TweenInfo?)
	frame.Visible = true
	TInfo = TInfo or defaultInfo
	frame.Size = UDim2.fromScale(0,0)
	local t = TweenBuilder(
		frame, 
		{ Size =  targetSize },
		TInfo
	)
	
	t:Play()
end

function module.close(frame:Frame, TInfo : TweenInfo?)
	TInfo = TInfo or defaultInfo
	local t = TweenBuilder(
		frame, 
		{ Size =  UDim2.fromScale(0,0) },
		TInfo
	)
	
	t:Play()
	t.Completed:Once(function()
		frame.Visible = false
	end)
end


function module.toggleVisibility(frames: {GuiObject}, visible: boolean)
	for _, guiElem in frames do
		if guiElem:IsA('Frame') or guiElem:IsA('ScrollingFrame') or guiElem:IsA('ScrollingFrame') or guiElem:IsA('ImageButton') or guiElem:IsA('TextButton') then
			guiElem.Visible = visible
		end
	end
end

function module.toggleVisibilityExcept(frames: {GuiObject}, exclude: string, visible: boolean)
	for _, guiElem in frames do
		if guiElem.Name == exclude then
			guiElem.Visible = true
			continue
		end
		
		if guiElem:IsA('Frame') or guiElem:IsA('ScrollingFrame') or guiElem:IsA('ScrollingFrame') or guiElem:IsA('ImageButton') or guiElem:IsA('TextButton') then
			guiElem.Visible = visible
		end
	end
end

return module
