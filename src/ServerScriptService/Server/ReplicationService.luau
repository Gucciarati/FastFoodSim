--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local DataService = require(script.Parent:WaitForChild("DataService"))

local ReplicateRE = Net:RemoteEvent("Replicate")
local GetPlayerDataRF = Net:RemoteFunction("GetPlayerData")

local ReplicationService = {}

local ReplicatedFields = {
	"Cash",
	"XP",
	"Level",
	"Tutorial",
	"Assemblies",
	"Foods",
	"Furniture",
}

function ReplicationService.Update(player: Player, fieldName: string)
	local profile = DataService.GetProfile(player)
	if not profile then return end
	
	local fieldValue = profile.Data[fieldName]
	ReplicateRE:FireClient(player, fieldName, fieldValue)
end

GetPlayerDataRF.OnServerInvoke = function(player: Player)
	local profile = DataService.GetProfile(player)
	if not profile then return nil end
	
	local PlayerData = {}
	for _, fieldName in ReplicatedFields do
		PlayerData[fieldName] = profile.Data[fieldName]
	end
	
	return PlayerData
end

return ReplicationService
