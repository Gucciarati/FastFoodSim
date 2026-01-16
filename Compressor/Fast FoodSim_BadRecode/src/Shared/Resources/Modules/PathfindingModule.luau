--[[
	Pathfinding Module
	----------------
	Provides simple in-restaurant pathfinding and movement helpers used by
	server scripts. Computes a corner-based path with line-of-sight checks
	through restaurant waypoints and moves NPCs along that path.

	Created by: Guinogue — Modified on October 29, 2025
]]

-----< Services and dependencies

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local APIs = ReplicatedStorage.APIs
local Handler = require(APIs.handler)

-----< Module table
local M = {}

-----< Public API
function M.FindPath(Restaurant, Start, Target, Path)
	Path = Path or {}
	local StartPos = Start.Position
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {Restaurant.Model}
	local Corners = Restaurant.Model.Waypoints:GetChildren()
	table.sort(Corners, function(A,B) return (StartPos-A.Position).Magnitude < (StartPos-B.Position).Magnitude end)
	table.insert(Corners, 1, Start)
	for _,Corner in pairs(Corners) do
		local Pos = Corner.Position
		if not workspace:Blockcast(CFrame.new(Pos, Target), Vector3.new(2,0.5,0.5), Target - Pos, Params) then
			local Last = Corner == Start
			table.insert(Path, Last and Target or Pos)
			return Last and Path or M.FindPath(Restaurant, Corner, Target, Path)
		end
	end
	table.insert(Path, Target)
	return Path
end

function M.WalkTo(Restaurant, NPC, Target, Yield, Turn)
	task.spawn(function()
		local Path = M.FindPath(Restaurant, NPC.HumanoidRootPart, Target.Position)
		for Index = 1,#Path do NPC.Humanoid:MoveTo(Path[Index]) NPC.Humanoid.MoveToFinished:Wait() end
		if Turn then
			task.wait(0.2)
			Handler.tween(NPC.HumanoidRootPart, {0.2}, {CFrame = Target + Vector3.new(0,NPC.HumanoidRootPart.Position.Y-Target.Y,0)}):Play()
		end
		Yield = false
	end)
	while Yield do task.wait() end
end

-----< Exports
return M


