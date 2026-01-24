--!strict

return function (Truck: Model, Lane: any, DepartTime: number)
	if not Truck or not Truck.Parent then return end
	
	local TruckCFrame = Truck:GetPivot()
	local EndCFrame = Lane.P2.CFrame
	
	local StartTime = tick()
	local DepartConnection
	DepartConnection = game:GetService("RunService").Heartbeat:Connect(function()
		local Elapsed = tick() - StartTime
		local Progress = math.min(Elapsed / DepartTime, 1)
		
		if Truck and Truck.Parent then
			Truck:PivotTo(TruckCFrame:Lerp(EndCFrame, Progress))
		end
		
		if Progress >= 1 then
			DepartConnection:Disconnect()
			pcall(function()
				Truck:Destroy()
			end)
		end
	end)
end
