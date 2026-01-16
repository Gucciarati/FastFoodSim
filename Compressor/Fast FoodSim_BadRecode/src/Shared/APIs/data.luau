local module = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Functions = ReplicatedStorage.Functions
local Remotes = ReplicatedStorage.Remotes
local Handler = require(script.Parent.handler)

module.Profiles = {}
module.OfflineData = {}
module.ProfileTemplate = {
	XP = 0,
	Cash = 250,
	EmployeeSlots = 0,
	ClaimedGroupReward = false,
	
	Day = 1,
	Popularity = 10,
	Customers = 0,
	CustomersServed = 0,
	
	NPCs = {},
	Foods = {},
	Packages = {},
	Furniture = {},
	Expansions = 1,
	
	BoughtCount = {},
	ServedItemCount = {},
	ServedIngredientCount = {},
	
	DailyStats = {
		Customers = 0,
		CustomersServed = 0,
		StartXP = 0,
		StartPopularity = 10,
		StartCash = 0,
	},
	
	Settings = {
		SFX = 0.8,
		Open = false,
		Tutorial = 1,
		RestaurantName = "Empty Restaurant",
	},
	
	Badges = {},
	
	Keybinds = {
		["Prompt"] = {["1"] = "E", ["2"] = "ButtonX"},
	},
	
	GamePasses = {},
	Subscriptions = {},
	TemporaryGamePasses = {},
	RobuxSpent = 0,
	
	Joins = 0,
	LastLeft = 0,
	FirstJoin = 0,
	LastJoined = 0,
	LoginStreak = 1,
	LastPlaceVersion = game.PlaceVersion,
	
	PlayTime = 0,
	SessionPlayTime = 0,
}

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	local DataStoreService = game:GetService("DataStoreService")
	local MessagingService = game:GetService("MessagingService")
	local Players = game:GetService("Players")
	local ProfileService = require(ServerScriptService.profile_service)
	local DataStore = DataStoreService:GetDataStore("OfflineData")
	local Studio = RunService:IsStudio()
	module.Version = (Studio and "Studio" or "Game") .. ServerScriptService[Studio and "StudioVersion" or "Version"].Value
	
	module.ProfileStore = ProfileService.GetProfileStore(
		"PlayerData",
		module.ProfileTemplate
	)
	
	MessagingService:SubscribeAsync("OfflineData", function(Message)
		local UserId = tonumber(Message.Data)
		local Player = Players:GetPlayerByUserId(UserId)
		if Player then
			module.GetOfflineData(Player)
		end
	end)
	
	function module.SetOfflineData(UserId, Data, Key)
		local Key = "OfflineData" .. module.Version .. UserId
		Handler.forcePcall(3, 5, DataStore.UpdateAsync, DataStore, Key, function(Old)
			Old = Old or {}
			Old[Key or Handler.generateGUID()] = Data
			return Old
		end)
		MessagingService:PublishAsync("OfflineData", UserId)
	end
	
	function module.GetOfflineData(Player)
		local Data = module.Data(Player)
		if not Data then return end
		local Key = "OfflineData" .. module.Version .. Player.UserId
		local OfflineData,Success = Handler.forcePcall(3, 5, DataStore.RemoveAsync, DataStore, Key)
		if not Success or not OfflineData then return end
		for _,Information in pairs(OfflineData) do
			module.OfflineData[Information.Key](Player, Data, Information)
		end
	end
	
	Functions.Data.GetData.OnServerInvoke = function(Player)
		return module.WaitForData(Player)
	end
end

function module.GlobalUpdateFunction(String, Function)
	module.GlobalUpdates[String] = Function
end

function module.Profile(Player)
	return module.Profiles[Player]
end

function module.Data(Player)
	local Profile = module.Profile(Player)
	return Profile and Profile.Data
end

function module.WaitForData(Player)
	local Profile,Start = nil,tick()
	while not Profile and Player and Player.Parent do
		Profile = module.Profile(Player)
		task.wait()
		if tick() - Start > 60 then break end
	end
	return Profile and Profile.Data
end

function Recursive(Data, Folder)
	local DataJSON = HttpService:JSONEncode(Data)
	local FolderJSON = Folder:GetAttribute("JSON") or ""
	
	if DataJSON ~= FolderJSON then
		Folder:SetAttribute("JSON", DataJSON)
		
		for Name, Value in pairs(Data) do
			local Instance = Folder:FindFirstChild(Name)
			
			if typeof(Value) == "table" then
				if not Instance then
					Instance = Handler.tableToObject(Value, Name)
					Instance.Parent = Folder
				else
					Recursive(Value, Instance)
				end
			else
				if not Instance or Handler.getType(Value) ~= Instance.ClassName then
					Handler.destroy(Instance)
					Instance = Handler.valueToObject(Value, Name)
					Instance.Parent = Folder
				elseif Instance.Value ~= Value then
					Instance.Value = Value
				end
			end
		end
		
		for _, Child in pairs(Folder:GetChildren()) do
			if Data[Child.Name] == nil then
				Handler.destroy(Child)
			end
		end
	end
end

function module.UpdateData(Player)
	local Data = module.Data(Player)
	local Folder = Handler.data(Player)
	if not Data or not Folder then return end
	
	Remotes.Data.DataUpdated:FireClient(Player, Data)
	Recursive(Data, Folder)
end

return module