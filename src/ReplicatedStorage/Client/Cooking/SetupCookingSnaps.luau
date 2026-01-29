--!strict
--[[
	InitializeCookingSnaps
	
	Client-side initialization for cooking snap CustomHoverData.
	Sets up the default "Cook" action for unoccupied snaps.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local StateValue = require(ReplicatedStorage.Packages.StateValue)

local COOKING_SNAP_NAMES = {
	["Raw Patty"] = true,
	["Flipped Raw Patty"] = true,
}

StateValue.Create("CustomHoverData", {})


local function InitializeSnapHoverData(Snap: Instance)
	-- Only initialize if this snap has cooking-related children
	local hasCookingChild = false
	for _, child in Snap:GetChildren() do
		if COOKING_SNAP_NAMES[child.Name] then
			hasCookingChild = true
			break
		end
	end
	
	if not hasCookingChild then return end
	
	-- Set default CustomHoverData (unoccupied state)
	local CustomHoverData = StateValue.Peek("CustomHoverData")
	CustomHoverData[Snap] = {
		ActionList = {
			{ Action = "Cook", Bind = "Primary" },
		},
		ProgressMeter = nil,
	}
	StateValue.Set("CustomHoverData", CustomHoverData)
end

local function CleanupSnapHoverData(Snap: Instance)
	local CustomHoverData = StateValue.Peek("CustomHoverData")
	CustomHoverData[Snap] = nil
	StateValue.Set("CustomHoverData", CustomHoverData)
end

-- Initialize existing snaps
for _, Snap in CollectionService:GetTagged("Snap") do
	task.spawn(InitializeSnapHoverData, Snap)
end

-- Watch for new snaps
CollectionService:GetInstanceAddedSignal("Snap"):Connect(InitializeSnapHoverData)
CollectionService:GetInstanceRemovedSignal("Snap"):Connect(CleanupSnapHoverData)

return true
