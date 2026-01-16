local PathfindingService = game:GetService('PathfindingService')

local Nav = {}

function Nav.GetPath(pos, destination)
	local d = typeof(destination) == "CFrame" and destination.Position or destination
	local p = typeof(pos) == "CFrame" and pos.Position or pos
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true,
		WaypointSpacing = 15,
		Costs = { Snow = math.huge, Water = math.huge, StairPole = math.huge },
	})
	pcall(function() path:ComputeAsync(p, d) end)
	if path.Status == Enum.PathStatus.Success then return path:GetWaypoints() end
	return { PathWaypoint.new(d, Enum.PathWaypointAction.Walk) }
end

function Nav.ScriptsWalkTo(NPC, dest)
	local pathWaypoints = Nav.GetPath(NPC.HumanoidRootPart.Position, dest)
	local speed = NPC.Humanoid.WalkSpeed
	for _, waypoint in ipairs(pathWaypoints) do
		NPC.Humanoid:MoveTo(waypoint.Position)
		local startTime = tick()
		local dist = math.abs((NPC.HumanoidRootPart.Position - waypoint.Position).Magnitude)
		local taken = dist / speed
		while true do
			local distNow = math.abs((NPC.HumanoidRootPart.Position - waypoint.Position).Magnitude)
			if tick() - startTime >= taken then
				if (dist - distNow) > 14 then
					NPC:PivotTo(CFrame.new(waypoint.Position) * NPC:GetPivot().Rotation)
				end
				break
			end
			task.wait(.5)
		end
	end
end

return Nav


