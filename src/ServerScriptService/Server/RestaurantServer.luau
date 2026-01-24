--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local Players             = game:GetService('Players')

local RestaurantShared  = require(ReplicatedStorage.SharedModules.RestaurantShared)
local PlotAssignment    = require(ServerScriptService.Server.Features.PlotAssignment)

Players.PlayerAdded:Connect(function(player)
	local PlotFolder
	repeat

		PlotFolder = PlotAssignment.GetPlayerPlot(player)
	until PlotFolder or not task.wait()
	

	local restaurantName = `{player.DisplayName}'s Restaurant`
	local restaurant = RestaurantShared.spawnPlayerRestaurant(player, restaurantName, PlotFolder)
	
	

	RestaurantShared.tpPlayerToRestaurant(player, restaurant)	
end)


return true

