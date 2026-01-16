local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Helpers = require(ReplicatedStorage.Resources.Modules.HelpersModule)

local Delivery = {}

local activeTrucksByRestaurant = {}

function Delivery.isActive(restaurant)
	return activeTrucksByRestaurant[restaurant] ~= nil
end

function Delivery.startDelivery(Restaurant, Player, CF, DELIVERY_TIME, Tween)
	local vehicle
	local closestLane = ''
	if not activeTrucksByRestaurant[Restaurant] then
		vehicle = ReplicatedStorage:WaitForChild("DeliveryTruck"):Clone()
		vehicle:SetAttribute('ForPlayer', Player.Name)
		activeTrucksByRestaurant[Restaurant] = vehicle

		local L1 = Workspace.VehicleSpawns:FindFirstChild('L1')
		local L2 = Workspace.VehicleSpawns:FindFirstChild('L2')
		local R1 = Workspace.VehicleSpawns:FindFirstChild('R1')
		local R2 = Workspace.VehicleSpawns:FindFirstChild('R2')
		if not (L1 and L2 and R1 and R2) then return end
		local restPos = Restaurant:GetPivot().Position
		local dL = (L1.Position - restPos).Magnitude
		local dR = (R1.Position - restPos).Magnitude
		local closestSpawnPoint
		if dL <= dR then closestSpawnPoint = L1 closestLane = 'L' else closestSpawnPoint = R1 closestLane = 'R' end

		vehicle.Parent = Workspace
		vehicle:PivotTo(closestSpawnPoint.CFrame * CFrame.new(0, -1, 0))
		vehicle:SetAttribute('Status', 'Began')

		Helpers.setCollisionGroupForModelParts(vehicle, "Players")

		local vehicleCF = vehicle:GetPivot()
		local p1 = Workspace.VehicleSpawns:FindFirstChild(string.format("%s1", closestLane))
		local p2 = Workspace.VehicleSpawns:FindFirstChild(string.format("%s2", closestLane))
		if not (p1 and p2) then return end
		local laneDir = (p1.Position - p2.Position).Unit

		local orangePos = CF.Position
		local bluePos   = closestSpawnPoint.Position
		local toOrange  = orangePos - bluePos
		local t         = toOrange:Dot(laneDir)
		local pinkPos   = bluePos + laneDir * t

		Tween(DELIVERY_TIME, 'easeOutCubic', function(a)
			vehicle:PivotTo(vehicleCF:Lerp(CFrame.new(pinkPos, vehicleCF.Position + vehicleCF.LookVector * 10000), a))
		end)

		Helpers.playAudio(Player, "PackagesArrived")
		Helpers.playAudio(Player, "TruckHorn")
		Helpers.notifyPlayer(Player, "Packages have arrived out front!", "Green")
	end

	-- vehicle departure
	task.delay(2, function()
		if vehicle then
			local vehicleCF = vehicle:GetPivot()
			local endPoint = Workspace.VehicleSpawns:FindFirstChild(string.format("%s2", closestLane))
			if not endPoint then return end
			local endCFrame = endPoint.CFrame
			Tween(5, 'easeInCubic', function(a)
				vehicle:PivotTo(vehicleCF:Lerp(endCFrame, a))
			end)
			pcall(function() vehicle:Destroy() end)
			activeTrucksByRestaurant[Restaurant] = nil
		end
	end)
end

return Delivery


