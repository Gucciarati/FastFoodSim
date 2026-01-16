-----< Variables

local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local BadgeService = game:GetService("BadgeService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Remotes = ReplicatedStorage.Remotes
local APIs = ReplicatedStorage.APIs
local Settings = require(APIs.settings)
local QuestsAPI = require(APIs.quests)
local Handler = require(APIs.handler)
local GameplayAPI = require(APIs.gameplay)
local DataAPI = require(APIs.data)
local ProfileService = require(script.Parent.profile_service)
local BadgeAPI = require(script.Parent.badge_manager)
local ChatAPI = require(script.Parent.chat_manager)

-----< Starter Gui

StarterGui.ScreenOrientation = Settings.ScreenOrientation

-----< Profile Templates

local LeaderstatsTemplate = {
}

local Mirroring = {
	["TotalCash"] = {Mirror = "Cash", Parent = function(Data) return Data end},
}

-----< Automated

for Name,Information in pairs(Mirroring) do
	Information.Parent(DataAPI.ProfileTemplate)[Name] = 0
	if not Information.Reset then continue end
	Information.Parent(DataAPI.ProfileTemplate)[Name.."Version"] = 0
end

for _,GamePass in pairs(Settings.GamePasses) do
	DataAPI.ProfileTemplate.GamePasses[GamePass] = false
	DataAPI.ProfileTemplate.TemporaryGamePasses[GamePass] = 0
end

for _,Subscription in pairs(Settings.Subscriptions) do
	DataAPI.ProfileTemplate.Subscriptions[Subscription] = false
end

for Badge,_ in pairs(BadgeAPI.Badges) do
	DataAPI.ProfileTemplate.Badges[Badge] = false
end

-----< Profile Store

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData",
	DataAPI.ProfileTemplate
)

-----< Collision Groups

PhysicsService:RegisterCollisionGroup("Players")
PhysicsService:CollisionGroupSetCollidable("Players", "Players", Settings.PlayersCanCollide)

-----< Functions
	
function CharacterAdded(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	
	if not Player:HasAppearanceLoaded() then
		Player.CharacterAppearanceLoaded:Wait()
	end
	
	for _,Descendant in pairs(Character:GetDescendants()) do
		if not Descendant:IsA("BasePart") then continue end
		Descendant.CollisionGroup = "Players"
	end
end

-----< Device

local Devices = {"PC", "Console", "Mobile"}

Remotes.Handler.Device.OnServerEvent:Connect(function(Player, Device)
	if not table.find(Devices, Device) then return end
	Player:WaitForChild("Device").Value = Device
end)

-----< Datastore

Handler.playerAddedFunction(function(Player)
	Handler.characterAddedFunction(Player, CharacterAdded)
	Handler.create("StringValue", Player, "Device", "PC")
	Handler.create("BoolValue", Player, "Premium", Player.MembershipType == Enum.MembershipType.Premium)
	local Leaderstats = Handler.create("Folder", Player, "leaderstats")
	local PlayerGui = Player:WaitForChild("PlayerGui")
	
	task.spawn(function()
		local InGroup = Handler.forcePcall(1, .1, Player.IsInGroup, Player, Settings.GroupId)
		local GroupRank = Handler.forcePcall(1, .1, Player.GetRankInGroup, Player, Settings.GroupId)
		local CountryCode = Handler.forcePcall(1, .1, LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, Player)
		
		Handler.create("BoolValue", Player, "Group", InGroup)
		Handler.create("IntValue", Player, "GroupRank", GroupRank)
		Handler.create("StringValue", Player, "CountryCode", CountryCode)
		
		ChatAPI.updateChat(Player)
		ChatAPI.chatted(Player)
	end)
	
	ChatAPI.systemMessage(Player.Name.." has joined the game!", "rgb(180,180,180)")
	
	local Profile = DataAPI.ProfileStore:LoadProfileAsync(DataAPI.Version .. Player.UserId)
	local Data,Folder
	
	local AdminLoadedProfile;
	
	local Commands = {
		["/addxp"] = function(Plr, Amount, offline)
			Amount = tonumber(Amount)
			if typeof(Amount) ~= "number" then return end
			
			
			if offline then

				local ProfileForUser = DataAPI.ProfileStore:LoadProfileAsync(DataAPI.Version .. Plr)
				Remotes.Handler.Notify:FireClient(Player, `Loaded Profile ({DataAPI.Version}.{Plr})`, "Green")
				ProfileForUser.Data.XP += Amount
				ProfileForUser:Release()
				Remotes.Handler.Notify:FireClient(Player, `Released Profile ({DataAPI.Version}.{Plr})`, "Green")

				return
			end
			
			local Data = DataAPI.Data(Plr)
			Data.XP += Amount
			DataAPI.UpdateData(Plr)
		end,
		
		["/addcash"] = function(Plr, Amount, offline)
			Amount = tonumber(Amount)
			if typeof(Amount) ~= "number" then return end


			if offline then
				
				local ProfileForUser = DataAPI.ProfileStore:LoadProfileAsync(DataAPI.Version .. Plr)
				
				Remotes.Handler.Notify:FireClient(Player, `Loaded Profile ({DataAPI.Version}.{Plr})`, "Green")
				
				ProfileForUser.Data.Cash += Amount
				
				ProfileForUser:Release()
				
				Remotes.Handler.Notify:FireClient(Player, `Released Profile ({DataAPI.Version}.{Plr})`, "Green")
				
				return
			end

			local Data = DataAPI.Data(Plr)
			Data.Cash += Amount
			DataAPI.UpdateData(Plr)
		end,
		
		["/setlevel"] = function(Plr, Amount, offline)
			Amount = tonumber(Amount)
			if typeof(Amount) ~= "number" then return end


			if offline then

				local ProfileForUser = DataAPI.ProfileStore:LoadProfileAsync(DataAPI.Version .. Plr)
				Remotes.Handler.Notify:FireClient(Player, `Loaded Profile ({DataAPI.Version}.{Plr})`, "Green")
				ProfileForUser.Data.XP = GameplayAPI.LevelToXP(math.clamp(Amount, 0, 50))
				Remotes.Handler.Notify:FireClient(Player, `Success, Level set to {GameplayAPI.XPToLevel(ProfileForUser.Data.XP)})`, "Green")
				ProfileForUser:Release()
				Remotes.Handler.Notify:FireClient(Player, `Released Profile ({DataAPI.Version}.{Plr})`, "Green")

				return
			end

			local Data = DataAPI.Data(Plr)
			Data.XP = GameplayAPI.LevelToXP(math.clamp(Amount, 0, 50))
			Remotes.Handler.Notify:FireClient(Player, `Success, Level set to {GameplayAPI.XPToLevel(Data.XP)})`, "Green")
			DataAPI.UpdateData(Plr)
		end,
	}
	
	-- @Bap - v1.0
	local admins: {[number]: boolean} = require(ReplicatedStorage.Configurations.Admins)
	
	Player.Chatted:Connect(function(Message)
		local isAdmin: boolean = table.find(admins, Player.UserId) ~= nil
		if isAdmin then
		--if Player.UserId == 3391256576 or Player.UserId == 1734127771 then
			local Splits = string.split(Message, " ")
			local Command = Splits[1]
			local User = Splits[2]
			local PlayerFound
			local Amount = Splits[3]
			
			for i, v in Players:GetPlayers() do
				if v.Name == User or v.DisplayName == User then
					PlayerFound = v
					break
				end
			end
			
			if not PlayerFound then
				local UserId;
				local success, error = pcall(function()
					UserId = Players:GetUserIdFromNameAsync(User)
				end)
				if not success then
					Remotes.Handler.Notify:FireClient(Player, "Failed to fetch user.", "Red")
				else
					Commands[Command](UserId, Amount, true)
				end
				return
			end
			
			if Commands[Command] then
				Commands[Command](PlayerFound, Amount)
				
				Remotes.Handler.Notify:FireClient(Player, "Command Worked", "Green")
				Remotes.Handler.Notify:FireClient(Player, `{Player.Name} has changed your stats`, "Green")
			end
		end
	end)
	
	if Profile ~= nil then
		--Profile:AddUserId(Player.UserId)
		Profile:Reconcile()
		Profile:ListenToRelease(function()
			DataAPI.Profiles[Player] = nil
			Player:Kick()
		end)
		if Player:IsDescendantOf(Players) then
			DataAPI.Profiles[Player] = Profile
			
			Data = Profile.Data
			Data.Joins += 1
			
			for _,Info in pairs(Data.NPCs) do
				Info.Time = Info.Time or os.time()
			end
			
			if Data.Joins == 1 then
				Data.FirstJoin = os.time()
				Data.Furniture = {
					["Chair"] =  {
						["CF"] = "-38.5, 1, 27.9999695, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Furniture",
						["Item"] = "Basic Chair"
					},
					["Cooktop"] =  {
						["CF"] = "-38.5, 1, -7, 0, 0, 1, 0, 1, 0, -1, 0, 0",
						["Category"] = "Appliances",
						["Item"] = "Cooktop"
					},
					["Counter"] =  {
						["CF"] = "-38.5, 1, 1, -1, 0, 0, 0, 1, 0, 0, 0, -1",
						["Category"] = "Appliances",
						["Item"] = "Table"
					},
					["Register"] =  {
						["CF"] = "-28.5, 1, 6.99996948, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Appliances",
						["Item"] = "Register"
					},
					["Table"] =  {
						["CF"] = "-38.5, 1, 23.9999695, 0, 0, 1, 0, 1, 0, -1, 0, 0",
						["Category"] = "Furniture",
						["Item"] = "Dirty Table"
					},
					["{08b28526-158c-4554-95bf-6cd21e5a58cc}"] =  {
						["CF"] = "-11.5, 1.00000012, -14, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Decoration",
						["Item"] = "Rectangle Light"
					},
					["{0c170c7c-baa3-4604-bb27-abcfe31ead07}"] =  {
						["CF"] = "-10.5, 1.00000012, 30, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Decoration",
						["Item"] = "Rectangle Light"
					},
					["{1901f0cd-c9f1-44dc-8f7d-b93d0b7ef3ad}"] =  {
						["CF"] = "-22.5, 1, -17, -1, 0, 0, 0, 1, 0, 0, 0, -1",
						["Category"] = "Appliances",
						["Item"] = "Trashbin"
					},
					["{57fb758a-d2f3-4063-a198-c6a13e8ff990}"] =  {
						["CF"] = "-10.5, 1.00000012, 14, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Decoration",
						["Item"] = "Rectangle Light"
					},
					["{70c9e241-277d-4c10-9460-3116d34499f5}"] =  {
						["CF"] = "-33.5, 1.00000012, -14, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Decoration",
						["Item"] = "Rectangle Light"
					},
					["{7739e120-b152-4c48-b50f-20d3e5ba829b}"] =  {
						["CF"] = "-34.5, 1.00000012, 30, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Decoration",
						["Item"] = "Rectangle Light"
					},
					["{939649b7-7630-4fdc-97d1-622a02d9d3d4}"] =  {
						["CF"] = "-34.5, 1.00000012, 22, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Decoration",
						["Item"] = "Rectangle Light"
					},
					["{94520b16-0d07-4034-b60e-bb287d74a527}"] =  {
						["CF"] = "-33.5, 1.00000012, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Decoration",
						["Item"] = "Rectangle Light"
					},
					["{ea0e7dd0-d612-49ec-bf23-2bef0b6f1ecd}"] =  {
						["CF"] = "-11.5, 1.00000012, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Decoration",
						["Item"] = "Rectangle Light"
					},
					["{ee7f1fb0-5608-41bf-af3d-783e140fef65}"] =  {
						["CF"] = "-24.5, 1.00000012, 12, 1, 0, 0, 0, 1, 0, 0, 0, 1",
						["Category"] = "Decoration",
						["Item"] = "Rectangle Light"
					}
				}
			end
			
			if Data.Settings.Tutorial < 29 then 
				print(Data.Settings.Tutorial)
				Data.Settings.Tutorial = 1 -- reset tutorial if not fully complete
				Data.Settings.Packages = {}
				Data.Settings.Foods = {}
				Data.Settings.Open = false 
				Data.Foods = {}
				Data.Packages = {} 
			end
			if os.time() - Data.LastLeft > Settings.SessionBuffer then
				Data.SessionPlayTime = 0
			end
			
			Data.LastPlaceVersion = game.PlaceVersion
			task.spawn(DataAPI.GetOfflineData, Player)
		else
			Profile:Release()
			return
		end
	else
		Player:Kick()
		return
	end
	
	Folder = Handler.tableToObject(Data, "Data")
	Handler.descendantAdded(Folder, function(Descendant)
		Folder:SetAttribute("Descendants", #Folder:GetDescendants())
		Handler.onDestroy(Descendant, function()
			Folder:SetAttribute("Descendants", #Folder:GetDescendants())
		end)
	end)
	Folder.Parent = Player
	
	for _,Info in pairs(LeaderstatsTemplate) do
		local Instance = Info.Ancestry(Folder)
		local NewValue = Handler.create(Instance.ClassName, Leaderstats, Info.Name)
		
		Handler.changed(Instance, function(Value)
			NewValue.Value = Value
		end)
	end
	
	for Name,Information in pairs(Mirroring) do
		local Mirror = Folder[Information.Mirror]
		
		Handler.changed(Mirror, function(Value, Old)
			if Value > Old then
				Information.Parent(Data)[Name] += Value - Old
				DataAPI.UpdateData(Player)
			end
		end)
	end
	
	task.spawn(function()
		BadgeAPI.AwardBadge(Player, "Welcome")
		
		for Stat,Badges in pairs(BadgeAPI.Amounts) do
			Handler.changed(Folder[Stat], function(Value)
				for Requirement,Badge in pairs(Badges) do
					if Value < Requirement then return end
					BadgeAPI.AwardBadge(Player, Badge)
				end
			end)
		end
		
		for Parent,Badges in pairs(BadgeAPI.Children) do
			Handler.childAdded(Folder[Parent], function(Child)
				local Badge = Badges[Child.Name]
				if not Badge then return end
				BadgeAPI.AwardBadge(Player, Badge)
			end)
		end
		
		for Badge,UserIds in pairs(BadgeAPI.Meet) do
			for _,UserId in pairs(UserIds) do
				local Found = false
				if Player.UserId == UserId then
					Found = true
					for _,Player in pairs(Players:GetPlayers()) do
						BadgeAPI.AwardBadge(Player, Badge)
					end
				else
					for _,Player in pairs(Players:GetPlayers()) do
						if Player.UserId ~= UserId then continue end
						Found = true
					end
				end

				if Found then
					BadgeAPI.AwardBadge(Player, Badge)
					break
				end
			end
		end
	end)
	
	while Player.Parent do
		Data.SessionPlayTime += 1
		Data.PlayTime += 1
		--[[
		if Data.PlayTime % 60 == 0 then
			Data.Cash += 50
		end
		]]
		for TemporaryGamePass,Value in pairs(Data.TemporaryGamePasses) do
			if Value < 1 then continue end
			if DateTime.now().UnixTimestamp > Value then
				Data.TemporaryGamePasses[TemporaryGamePass] = 0
				Data.GamePasses[TemporaryGamePass] = false
			end
		end
		
		for Name,Information in pairs(Mirroring) do
			if not Information.Reset then continue end
			local Version = Handler.version(Information.Reset, Information.ResetFrom)
			if Data[Name.."Version"] == Version then continue end
			Data[Name.."Version"] = Version
			Data[Name] = 0
		end
		
		local Date,LastJoined = Handler.version(86400, Data.FirstJoin),Data.LastJoined
		
		if LastJoined ~= Date then
			Data.LoginStreak = ((Date - 1) == LastJoined and Data.LoginStreak + 1) or 1
			Data.LastJoined = Date
			if (Date - 1) ~= LastJoined then
				for Day,_ in pairs(Data.DailyRewards) do
					Data.DailyRewards[Day] = false
				end
			end
		end
		
		for Potion,Value in pairs(Data.ActivePotions) do
			if Value < 1 then continue end
			Data.ActivePotions[Potion] -= 1
		end
		
		--[[for Type,Info in pairs(QuestsAPI.Quests) do
			local Version = QuestsAPI.GetVersion(Data, Type)
			if Data.Quests[Type].Version == Version then continue end
			Data.Quests[Type].Version = Version
			QuestsAPI.SetSession(Data, Type)
		end]]
		
		DataAPI.UpdateData(Player)
		
		task.wait(1)
	end
end)

Handler.playerRemovingFunction(function(Player)
	local Restaurant = workspace:WaitForChild("OwnedRestaurants"):FindFirstChild(Player.Name)
	local Profile = DataAPI.Profile(Player)
	if Profile ~= nil then
		if Restaurant then
			for _,Package in pairs(Restaurant.Packages:GetChildren()) do
				Profile.Data.Packages[Package.Name].CF = tostring(Restaurant:GetPivot():ToObjectSpace(Package.Drag.CFrame))
			end
			for _,Food in pairs(Restaurant.Ingredients:GetChildren()) do
				Profile.Data.Foods[Food.Name].CF = tostring(Restaurant:GetPivot():ToObjectSpace(Food.Drag.CFrame))
			end
		end
		Profile.Data.LastLeft = os.time()
		
		-- make it so tutorial doesnt saveu nless fully done
		
		Profile:Release()
	end
	if Restaurant then
		Restaurant:Destroy()
	end
end)

-----< 