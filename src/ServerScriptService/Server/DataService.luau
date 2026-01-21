--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ProfileService = require(script.Parent:WaitForChild("ProfileService"))

local DataService = {}

local ProfileTemplate = {
	Cash = 0,
	Level = 1,
	XP = 0,
	
	Furniture = {},
	Food = {},
	Assemblies = {},
	
	Foods = {},
	
	Joins = 0,
	FirstJoin = 0,
	LastLeft = 0,
	SessionPlayTime = 0,
	LastPlaceVersion = 0,
	
	Settings = {
		Tutorial = 0,
		Open = false,
	},
	
	GamePasses = {},
	TemporaryGamePasses = {},
	Subscriptions = {},
	Badges = {},
}

DataService.Profiles = {}
DataService.ProfileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)

local function OnPlayerAdded(player: Player)
	local version = game:GetService("RunService"):IsStudio() and "Studio" or "Game"
	local profile = DataService.ProfileStore:LoadProfileAsync(version .. player.UserId)
	
	if not profile then
		player:Kick("Failed to load profile")
		return
	end
	
	profile:Reconcile()
	
	profile:ListenToRelease(function()
		DataService.Profiles[player] = nil
		player:Kick("Profile released")
	end)
	
	DataService.Profiles[player] = profile
end

local function OnPlayerRemoving(player: Player)
	local profile = DataService.Profiles[player]
	if profile then
		profile.Data.LastLeft = os.time()
		profile.Data.SessionPlayTime = (profile.Data.SessionPlayTime or 0) + (os.time() - (profile.Data._sessionStart or os.time()))
		profile:Release()
		DataService.Profiles[player] = nil
	end
end

function DataService.GetProfile(player: Player)
	return DataService.Profiles[player]
end

function DataService.GetData(player: Player)
	local profile = DataService.Profiles[player]
	return profile and profile.Data or nil
end

function DataService.UpdateData(player: Player)
	local profile = DataService.Profiles[player]
	if profile then
		profile:Save()
	end
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

return DataService
