--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local Players             = game:GetService('Players')

local Shared              = ReplicatedStorage:WaitForChild('SharedModules')
local Utils               = ReplicatedStorage:WaitForChild('Utils')
local Vendor              = ReplicatedFirst.Vendor

local DataService = require(script.Parent:WaitForChild("DataService"))
local PlayerShared = require(Shared.PlayerShared)

Players.PlayerAdded:Connect(function(player)
	local profile = DataService.GetProfile(player)
	if not profile then return end
	
	PlayerShared.setPlayerProfile(player, profile)
end)

return DataService