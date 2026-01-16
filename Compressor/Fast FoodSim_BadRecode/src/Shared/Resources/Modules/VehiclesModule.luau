--[[
	Vehicles Module
	----------------
	Spawns random vehicles at lane spawns and notifies clients to move them.

	Created by: Guinogue — Modified on October 27, 2025
]]

local VehiclesModule = {}

-----< Module Setup >

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Vehicles = ReplicatedStorage:WaitForChild("Vehicles")
local VehicleSpawns = workspace:WaitForChild("VehicleSpawns")
local Utilities = require(ReplicatedStorage.Utilities)
local VehicleMover = ReplicatedStorage.Remotes.Vehicle.VehicleMover

-----< Config >

local SPAWN_RATE = {3, 6}
local VEHICLE_LANES = {"L","R"}
local SOUND_ID = "rbxassetid://269596439"

-----< Spawn Logic >

local function randomLane() return VEHICLE_LANES[math.random(1, #VEHICLE_LANES)] end
local function pickModel() local list = Vehicles:GetChildren(); return list[math.random(1, #list)] end

local function spawnOnce()
	local lane = randomLane()
	local fromStr = lane.."1"
	local toStr = lane.."2"
	local from = VehicleSpawns:FindFirstChild(fromStr)
	if not from then return end
	local model = pickModel():Clone(); model.Parent = workspace
	model:PivotTo(from.CFrame * CFrame.new(0, -1, 0))
	for _,d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then d.CollisionGroup = "Players" end end
	task.wait(1)
	local basePartDescendant = model:FindFirstChildWhichIsA("MeshPart", true)
	if basePartDescendant then local s = Instance.new("Sound"); s.SoundId = SOUND_ID; s.Volume = 2; s.Parent = basePartDescendant; s:Play() end
	Debris:AddItem(model, 10)
	VehicleMover:FireAllClients(model, toStr)
end

-----< Initialize >

function VehiclesModule.Initialize()
	task.spawn(function()
		while true do task.wait(math.random(SPAWN_RATE[1], SPAWN_RATE[2])); spawnOnce() end
	end)
	return true
end

return VehiclesModule
