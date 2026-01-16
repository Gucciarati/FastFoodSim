local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vehicles = ReplicatedStorage:WaitForChild('Vehicles')
local VehicleSpawns = workspace.VehicleSpawns
local Utilities = require(game.ReplicatedStorage.Utilities)
local Tween = Utilities.Tween 
local VehicleMover = ReplicatedStorage.Remotes.Vehicle.VehicleMover

local VEHICLE_SPAWN_RATE = {3, 6}


while task.wait(math.random(VEHICLE_SPAWN_RATE[1], VEHICLE_SPAWN_RATE[2])) do--task.wait(math.random(VEHICLE_SPAWN_RATE[1], VEHICLE_SPAWN_RATE[2])) do 
	local vehicleSpawnStr = `{({'L', 'R'})[math.random(1, 2)]}1`
	local vehicleDestinationStr = vehicleSpawnStr:gsub('1', '2')
	local vehicleSpawn = VehicleSpawns:FindFirstChild(vehicleSpawnStr)
	local vehicleDestination = VehicleSpawns:FindFirstChild(vehicleDestinationStr)
	
	local vehicle = Vehicles:GetChildren()[math.random(1, #Vehicles:GetChildren())]:Clone()
	vehicle.Parent = workspace
	vehicle:PivotTo(vehicleSpawn.CFrame * CFrame.new(0, -1, 0))
	
	local basePartDescendant = vehicle:FindFirstChildWhichIsA('MeshPart', true)
	
	for _, v in next, vehicle:GetDescendants() do 
		pcall(function()
			v.CollisionGroup = "Players"
		end)
	end
	
	task.wait(1)

	if basePartDescendant then 
		local sound = Instance.new("Sound", basePartDescendant)
		sound.SoundId = 'rbxassetid://269596439'
		sound.Volume = 2
		sound:Play()
	end
	
	game:GetService('Debris'):AddItem(vehicle, 10)
	
	VehicleMover:FireAllClients(vehicle, vehicleDestinationStr)
	
	--task.spawn(function()
	--	local vehicleCF = vehicle:GetPivot()
	--	Tween(VEHICLE_CROSS_TIME + math.random() * 2, nil, function(a)
	--		vehicle:PivotTo(vehicleCF:Lerp(vehicleDestination.CFrame, a))
	--	end)

	--	pcall(function()
	--		vehicle:Destroy()
	--	end)
	--end)
end