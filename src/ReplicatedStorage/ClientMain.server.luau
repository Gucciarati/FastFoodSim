--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local ServerScriptService = script.Parent
local Global              = require(ReplicatedStorage:WaitForChild('Global'))
local ClientModules = script.Parent.Client

local GameState     = ReplicatedStorage:WaitForChild('GameState')
local Utils         = ReplicatedStorage:WaitForChild('Utils')
local Vendor        = ReplicatedFirst.Vendor


-- vendor utils

local ConnectUtil     = require(Vendor.ConnectUtil)
local RegisterModules = require(Utils.RegisterModule)


local modules = {
	ClientModules.Placement.AimTrackerClient,
	ClientModules.GUI,
	ClientModules.GUI.Focus.FocusClient,
	ClientModules.ReplicationClient,
	ClientModules.PlacementClient,
	ClientModules.Cooking.FoodPlacementClient,
}:: {ModuleScript}


ConnectUtil.attributeChanged(GameState, Global.Attributes.GameState.ServerInitialized, function(serverInit)
	if serverInit then
		RegisterModules.requireModules(modules)
	end
end)





