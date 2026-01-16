--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local Players             = game:GetService('Players')

local Shared              = ReplicatedStorage:WaitForChild('SharedModules')
local Utils               = ReplicatedStorage:WaitForChild('Utils')
local Vendor              = ReplicatedFirst.Vendor

local RestaurantShared = require(Shared.RestaurantShared)

RestaurantShared.initPlots()

Players.PlayerAdded:Connect(function(player)
	local restaurantName = `{player.DisplayName}'s Restaurant`
	local restaurant = RestaurantShared.spawnPlayerRestaurant(player, restaurantName)	
	player.CharacterAdded:Connect(function(character)
		RestaurantShared.tpPlayerToRestaurant(player,restaurant)	
	end)
end)


return true

