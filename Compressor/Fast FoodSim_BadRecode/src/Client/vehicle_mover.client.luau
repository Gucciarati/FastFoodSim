local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleMover = ReplicatedStorage.Remotes.Vehicle.VehicleMover
local Utilities = require(game.ReplicatedStorage.Utilities)
local Tween = Utilities.Tween 
local VehicleSpawns = workspace.VehicleSpawns

local VEHICLE_CROSS_TIME = 10

VehicleMover.OnClientEvent:Connect(function(vehicle, vehicleDestinationStr)
	local vehicleDestination = VehicleSpawns:FindFirstChild(vehicleDestinationStr)
	local vehicleCF = vehicle:GetPivot()
	
	Tween(VEHICLE_CROSS_TIME + math.random() * 2, nil, function(a)
		vehicle:PivotTo(vehicleCF:Lerp(vehicleDestination.CFrame, a))
	end)

	pcall(function() -- server destroys it too, but just in case
		vehicle:Destroy()
	end)
end)