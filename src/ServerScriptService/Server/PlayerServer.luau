--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local Players             = game:GetService('Players')

local Shared              = ReplicatedStorage:WaitForChild('SharedModules')
local Utils               = ReplicatedStorage:WaitForChild('Utils')
local Vendor              = ReplicatedFirst.Vendor

local PlayerShared = require(Shared.PlayerShared)

Players.PlayerAdded:Connect(function(player)
	PlayerShared.setPlayerProfile(player)
end)


return true