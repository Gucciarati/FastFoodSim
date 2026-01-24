--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Scope = Fusion.scoped(Fusion)

local Net           = require(ReplicatedStorage.Packages.Net)
local StateValue    = require(ReplicatedStorage.Packages.StateValue)

local ReplicateRE = Net:RemoteEvent("Replicate")
local GetPlayerDataRF = Net:RemoteFunction("GetPlayerData")



local StateValues = {
	Cash = StateValue.Create("Cash", Scope:Value(0)),
	XP = StateValue.Create("XP", Scope:Value(0)),
	Level = StateValue.Create("Level", Scope:Value(1)),
	Tutorial = StateValue.Create("Tutorial", false),
    Assemblies = StateValue.Create("Assemblies", {}),
    Foods = StateValue.Create("Foods", {}),
    Furniture = StateValue.Create("Furniture", {}),
	CurrentComputerTab = StateValue.Create("CurrentComputerTab", Scope:Value("Market")),
}

local function SetStateValue(fieldName: string, fieldValue: any)
	local StateObject = StateValue.Peek(fieldName)
	if not StateObject then return end
	
	local CurrentValue = StateObject
	local IsFusionValue = typeof(CurrentValue) == "table" and CurrentValue.set
	
	if IsFusionValue then
		CurrentValue:set(fieldValue)
	else
		StateValue.Set(fieldName, fieldValue)
	end
end

local function InitializeStateValues()
	local PlayerData = GetPlayerDataRF:InvokeServer()
	if not PlayerData then return end
	
	for fieldName, fieldValue in PlayerData do
		if StateValues[fieldName] then
			SetStateValue(fieldName, fieldValue)
		end
	end
end

ReplicateRE.OnClientEvent:Connect(function(fieldName: string, fieldValue: any)
	if not StateValues[fieldName] then return end
	SetStateValue(fieldName, fieldValue)
end)

InitializeStateValues()

return StateValues
