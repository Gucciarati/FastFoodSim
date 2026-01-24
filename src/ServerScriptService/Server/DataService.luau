--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileService 			= require(script.Parent.ProfileService)
local DefaultFurnitureService 	= require(script.Parent.DefaultFurnitureService)
local FurnitureComponent 		= require(ServerScriptService.Server.Components.FurnitureComponent)
local FoodComponent 			= require(ServerScriptService.Server.Components.FoodComponent)
local PlotAssignment 			= require(ServerScriptService.Server.Features.PlotAssignment)
local CFrameSerdes 				= require(ReplicatedStorage.Utils.CFrameSerdes)

local Net = require(ReplicatedStorage.Packages.Net)
local SendPlayerDataRF = Net:RemoteFunction("SendPlayerData")

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
	
	profile.Data.Joins = (profile.Data.Joins or 0) + 1

	local PlotFolder = PlotAssignment.GetPlayerPlot(player) or PlotAssignment.AssignPlot(player)
	if not PlotFolder then
		return
	end
	
	local isReturningPlayer = next(profile.Data.Furniture) ~= nil
	
	DefaultFurnitureService.InjectDefaults(player, profile.Data)
	profile.Data.Cash = 100000000000
	if isReturningPlayer then
		FurnitureComponent.PlaceAll(player, profile.Data)
		FoodComponent.PlaceAllAssemblies(player, profile.Data)
	end
	
	profile:ListenToRelease(function()
		DataService.Profiles[player] = nil
		player:Kick("Profile released")
	end)
	
	DataService.Profiles[player] = profile
end

local function OnPlayerRemoving(player: Player)
	local profile = DataService.Profiles[player]
	if profile then

		local PlotFolder = PlotAssignment.GetPlayerPlot(player)
		if PlotFolder then
			local FoodFolder = PlotFolder:FindFirstChild("Food")
			local FurnitureFolder = PlotFolder:FindFirstChild("Furniture")
		
			if FurnitureFolder then
				for _, FurnitureModel in FurnitureFolder:GetChildren() do
					local Id = FurnitureModel:GetAttribute("Id")
					if Id and profile.Data.Furniture[Id] then
						local ObjectCFrame = CFrameSerdes.ToObjectSpace(PlotFolder, FurnitureModel:GetPivot())
						profile.Data.Furniture[Id].Cframe = CFrameSerdes.Serialize(ObjectCFrame)
					end
				end
			end
			
			if FoodFolder then
				for _, FoodModel in FoodFolder:GetChildren() do
					local Id = FoodModel:GetAttribute("Id")
					if Id and profile.Data.Assemblies[Id] then
						local ObjectCFrame = CFrameSerdes.ToObjectSpace(PlotFolder, FoodModel:GetPivot())
						profile.Data.Assemblies[Id].Cframe = CFrameSerdes.Serialize(ObjectCFrame)
						profile.Data.Assemblies[Id].Amount = FoodModel:GetAttribute("Amount") or 0
					end
				end
			end
		end
		
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

SendPlayerDataRF.OnServerInvoke = function(Player: Player)
	local PlayerData = DataService.GetData(Player)
	assert(PlayerData, `Couldn´t get player data for {Player.Name}`)
	
	return PlayerData
end

return DataService
