--!strict


return function (RestaurantPos: Vector3): any
	local VehicleSpawns = workspace:FindFirstChild("VehicleSpawns")
	if not VehicleSpawns then return end
	
	local Lanes = {}
	
	for _, SpawnPart in pairs(VehicleSpawns:GetChildren()) do
		if SpawnPart:IsA("Part") then
			local Prefix = string.sub(SpawnPart.Name, 1, 1)
			if Prefix == "L" or Prefix == "R" then
				if not Lanes[Prefix] then
					Lanes[Prefix] = {}
				end
				table.insert(Lanes[Prefix], SpawnPart)
			end
		end
	end
	
	local ClosestLane: any
	local ClosestDistance = math.huge
	
	for LaneName, Parts in pairs(Lanes) do
		if #Parts == 2 then
			local Midpoint = (Parts[1].Position + Parts[2].Position) / 2
			local Distance = (Midpoint - RestaurantPos).Magnitude
			if Distance < ClosestDistance then
				ClosestDistance = Distance
				ClosestLane = {
					P1 = Parts[1],
					P2 = Parts[2],
					Dir = (Parts[1].Position - Parts[2].Position).Unit,
					Name = LaneName,
				}
			end
		end
	end
	
	return ClosestLane
end
