--[[
	Gameloop Main Script
	----------------
	Orchestrates the game's main loop: initializes and integrates modules
	(economy, inventory, seating, day/night, expansions, navigation),
	manages wandering NPCs and delegates customer flow to
	CustomerFlowModule (queue, order, service, exit), sets up player
	restaurants, and wires gameplay events/remotes.

	Created by: Guinogue — Modified on October 29, 2025
]]

-----< Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local Functions = ReplicatedStorage.Functions.Gameplay
local Remotes = ReplicatedStorage.Remotes.Gameplay
local Assets = ReplicatedStorage.Assets
local APIs = ReplicatedStorage.APIs
local GameplayAPI = require(APIs.gameplay)
local Settings = require(APIs.settings)
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)
local WillsAPI = require(APIs.willsAPI)
local Utilities = require(game.ReplicatedStorage.Utilities)
local SnapModule = require(ReplicatedStorage.Resources.Modules.SnapModule)
local Nav = require(ReplicatedStorage.Resources.Modules.NavModule)
local Helpers = require(ReplicatedStorage.Resources.Modules.HelpersModule)
local DeliveryModule = require(ReplicatedStorage.Resources.Modules.DeliveryModule)
local TrayServiceModule = require(ReplicatedStorage.Resources.Modules.TrayServiceModule)
local SeatingModule = require(ReplicatedStorage.Resources.Modules.SeatingModule)
local PathfindingModule = require(ReplicatedStorage.Resources.Modules.PathfindingModule)
local CustomerFlowModule = require(ReplicatedStorage.Resources.Modules.CustomerFlowModule)
local ResetModule = require(ReplicatedStorage.Resources.Modules.ResetModule)
local DayNightCycleModule = require(ReplicatedStorage.Resources.Modules.DayNightCycleModule)
local GroupRewardModule = require(ReplicatedStorage.Resources.Modules.GroupRewardModule)
local TrashModule = require(ReplicatedStorage.Resources.Modules.TrashModule)
local EmployeeTasksModule = require(ReplicatedStorage.Resources.Modules.EmployeeTasksModule)
local InventoryModule = require(ReplicatedStorage.Resources.Modules.InventoryModule)
local RestaurantModule = require(ReplicatedStorage.Resources.Modules.RestaurantModule)
local EconomyModule = require(ReplicatedStorage.Resources.Modules.EconomyModule)
local AssetInitModule = require(ReplicatedStorage.Resources.Modules.AssetInitModule)
local Tween = Utilities.Tween 

-----< Animation setup

local Animate = script.Animate
Animate.Parent = nil
Animate.Enabled = true

local OwnedRestaurants = Instance.new("Folder")
OwnedRestaurants.Name = "OwnedRestaurants"
OwnedRestaurants.Parent = workspace

-----< Core folders and module initialization
InventoryModule.initRemotes(OwnedRestaurants)
EconomyModule.init(OwnedRestaurants)

-----< Rewards hooks
Settings.RewardStringFunctions["Gameplay"] = function(Player, Reward)
	if Reward.NPC then return Reward.NPC.." NPC" end
	if Reward.Package then return "x"..Reward.Amount.." "..Reward.Package end
end

Settings.RewardPlayerFunctions["Gameplay"] = function(Player, Data, Reward) 
	if Reward.NPC then
		Data.NPCs[Handler.generateGUID()] = {Gender = Handler.randomInt(0,1), Time = os.time(), Type = Reward.NPC}
	elseif Reward.Package then
		local Restaurant = OwnedRestaurants:WaitForChild(Player.Name)
		for Index = 1,Reward.Amount do
			local GUID = Handler.generateGUID()
			local CF = Restaurant.Spawn.CFrame*CFrame.new(Handler.random(-10,10),Handler.random(5,10),Handler.random(-10,10))
			Data.Packages[GUID] = {Category = Reward.Category, Item = Reward.Package, CF = tostring(Restaurant:GetPivot():ToObjectSpace(CF))}
		end
	end
end

-----< Employee management
Remotes.BuyEmployee.OnServerEvent:Connect(function(Player, Employee)
	local Data = DataAPI.Data(Player)
	if not Data or not GameplayAPI.Employees[Employee] then return end
	local Employees = Handler.dictionaryLength(Data.NPCs)
	if Employees >= Data.EmployeeSlots or Data.Cash < GameplayAPI.Employees[Employee].Price * (1 + (Employees * GameplayAPI.PriceMultiPerEmployee)) then return end
	Data.Cash -= GameplayAPI.Employees[Employee].Price * (1 + (Employees * GameplayAPI.PriceMultiPerEmployee))
	Data.NPCs[Handler.generateGUID()] = {Gender = Handler.randomInt(0,1), Time = os.time(), Type = Employee}
	DataAPI.UpdateData(Player)
end)

Remotes.DeleteEmployee.OnServerEvent:Connect(function(Player, Employee)
	local Data = DataAPI.Data(Player)
	if not Data or not Data.NPCs[Employee] then return end
	Data.NPCs[Employee] = nil
	DataAPI.UpdateData(Player)
end)

-----< Multipliers & products
Settings.MultiplierFunctions["Gameplay"] = function(Player, Data, Type) end

Handler.productPurchaseFunctions["Gameplay"] = function(Player, Data, Product) end

-----< Expansions bootstrap
local ExpansionsModule = require(ReplicatedStorage.Resources.Modules.ExpansionsModule)
ExpansionsModule.setup(Assets.Expansions)

local SampleRestaurant,Restaurants = Handler.sample(workspace.UnownedRestaurants.Sample)
local NewModel = Assets.Expansions["1"]:Clone()
NewModel.Name, NewModel.Parent = "Model", SampleRestaurant
NewModel:PivotTo(SampleRestaurant:GetPivot())
for _,Plot in pairs(Restaurants:GetChildren()) do
	local Restaurant = SampleRestaurant:Clone()
	Restaurant:PivotTo(Plot.CFrame) Restaurant.Parent, Plot.Parent = Restaurants, nil
end

-----< Snap system setup
Handler.tagAdded("Snap", function(Snap)
	if not Snap:IsDescendantOf(workspace) then return end
	for _,Child in pairs(Snap:GetChildren()) do
		Handler.invisible(Child)
		if Child:GetAttribute("Time") then Handler.create("IntValue", Child, "Timer", 0) end
	end
end)

-----< Friends initialization
Handler.playerAddedFunction(function(Player)
	local FriendIds = Handler.create("Folder", Player, "FriendIds")
	local PlayersFriends = Players:GetFriendsAsync(math.max(1, Player.UserId))
	while true do
		local Page = PlayersFriends:GetCurrentPage()
		for _,Info in pairs(Page) do Handler.create("StringValue", FriendIds, Info.Id, Info.Username) end
		if PlayersFriends.IsFinished then break end
		PlayersFriends:AdvanceToNextPageAsync()
	end
	if #FriendIds:GetChildren() < 1 then Handler.create("StringValue", FriendIds, 1, "Roblox") end
end)

-----< Player binding
Handler.playerAddedFunction(function(Player)
	local Restaurant = Restaurants:GetChildren()[math.random(#Restaurants:GetChildren())]
	Restaurant.Parent = OwnedRestaurants
	Restaurant.Name = Player.Name
	Handler.create("StringValue", Restaurant.Whitelist, Player.Name)
	local Folder = Handler.waitForData(Player)
	local Data = DataAPI.WaitForData(Player)
	if not Folder or not Data then return end
	RestaurantModule.bind(Player, Restaurant, Folder, Data, script.Talking, Assets)
	task.wait(1)

	InventoryModule.bind(Folder, Restaurant, Player)
	task.wait(1)
	EmployeeTasksModule.bind(Folder, Restaurant, Player, Data, Animate, script.Employees)
end)

-----< Player removal cleanup
Handler.playerRemovingFunction(function(Player)
	local Restaurant = Helpers.restaurantOf(Player)
	if not Restaurant then return end
	local NewRestaurant = SampleRestaurant:Clone()
	NewRestaurant:PivotTo(Restaurant:GetPivot())
	NewRestaurant.Parent = Restaurants
end)

-----< Trash handling
TrashModule.init(OwnedRestaurants)

-----< Asset models initialization
AssetInitModule.initAssetModels(Assets.Food, true, false, true)
AssetInitModule.initAssetModels(Assets.Ingredients, false, true, false)
AssetInitModule.initAssetModels(Assets.Packages, false, true, false)

-----< Ingredient & pickup remotes
Remotes.TakeIngredient.OnServerEvent:Connect(SnapModule.TakeIngredient)
Remotes.PickUpItem.OnServerEvent:Connect(function(Player, Item)
	local Restaurant = Handler.findFirstAncestorOfChild(Item, OwnedRestaurants)
	if not Restaurant or not Restaurant.Whitelist:FindFirstChild(Player.Name) then return end
	Remotes.PickUpItem:FireAllClients(Player, Item)
end)

-----< Snap remotes
Remotes.SnapIngredient.OnServerEvent:Connect(SnapModule.SnapIngredient)

-----< Reset
ResetModule.init()

-----< Whitelist
Remotes.SetWhitelist.OnServerEvent:Connect(function(Player, Other, Value)
	if Player == Other then return end
	local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
	if Value and not Restaurant.Whitelist:FindFirstChild(Other.Name) then
		Handler.create("StringValue", Restaurant.Whitelist, Other.Name)
		Remotes.TeleportPrompt:FireClient(Other, Player)
	elseif not Value then
		Handler.destroy(Restaurant.Whitelist:FindFirstChild(Other.Name))
	end
end)

-----< Day/Night cycle handled by module (DayNightCycleModule)
local NightDuration = 10
local DayDuration = 600
DayNightCycleModule.init(DayDuration, NightDuration)

-----< Group reward claim handled by module (GroupRewardModule)
GroupRewardModule.init()

-----< Wandering system variables
local wandering_waypoints = {}
local wanderingNPCsByPlayer = {}
local wanderingPerPlayerCount = {}
local WANDERING_PER_PLAYER_CAP = 6
local nextSpawnPlayerIdx = 1
local RushHour = false

-----< Wandering helpers
local function getRandomWanderingSpawn()
	return wandering_waypoints[math.random(#wandering_waypoints)]
end

local function totalWandering()
	local count = 0
	for _, list in pairs(wanderingNPCsByPlayer) do count += #list end
	return count
end

local function playerWandering(p) return wanderingPerPlayerCount[p.UserId] or 0 end
local function inc(p) wanderingPerPlayerCount[p.UserId] = playerWandering(p) + 1 end
local function dec(p) wanderingPerPlayerCount[p.UserId] = math.max(0, playerWandering(p) - 1) end

local function InitWandering()
	wandering_waypoints = {}
	for _, v in next, workspace.WanderingNPCWaypoints:GetChildren() do table.insert(wandering_waypoints, v) end
end

-----< Spawn wandering NPC
local function SpawnWanderingForOwner(owner, npcType, rigTemplate, vipTemplate, animateTemplate)
	local NPCType = npcType or Handler.chance(GameplayAPI.NPCs)
	local npc = (npcType == "VIP" and vipTemplate or rigTemplate):Clone()
	npc.Name = NPCType
	npc:SetAttribute("NPC", true)
	if animateTemplate then animateTemplate:Clone().Parent = npc end

	local Humanoid = npc.Humanoid
	local HRP = npc.HumanoidRootPart
	local Information = Handler.tableToObject({ Order = {}, OrderTime = 0, InLine = false, Ordered = false }, "Information")
	Information.Parent = npc
	for _, d in pairs(npc:GetDescendants()) do if d:IsA("BasePart") then d.CollisionGroup = "Players" end end
	local start = getRandomWanderingSpawn(); npc:PivotTo(start.CFrame)

	wanderingNPCsByPlayer[owner] = wanderingNPCsByPlayer[owner] or {}
	table.insert(wanderingNPCsByPlayer[owner], { NPC = npc, Owner = owner, Information = Information, NPCType = NPCType })

	Humanoid.WalkSpeed = Settings.Multiplier(owner, "NPCWalkSpeed")
	Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	npc.Parent = workspace

	local friendIdsChildrenCount = #(owner:FindFirstChild("FriendIds") and owner.FriendIds:GetChildren() or {})
	if not npcType and friendIdsChildrenCount > 0 then
		local FriendId = owner.FriendIds:GetChildren()[math.random(friendIdsChildrenCount)]
		if FriendId then npc.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(tonumber(FriendId.Name))) end
	end
	ReplicatedStorage.Remotes.Gameplay.UpdateNPCAppearances:FireAllClients()
	for _, d in pairs(npc:GetDescendants()) do if d:IsA("BasePart") then d.CollisionGroup = "Players" end end

	local newDestination = getRandomWanderingSpawn()
	while newDestination == start do newDestination = getRandomWanderingSpawn(); task.wait() end
	local pathWaypoints = Nav.GetPath(HRP.CFrame, newDestination.Position)
	npc:SetAttribute("IsWandering", true)
	local oldDestination
	task.spawn(function()
		while npc:GetAttribute("IsWandering") do
			for _, waypoint in ipairs(pathWaypoints) do
				Humanoid:MoveTo(waypoint.Position)
				Humanoid.MoveToFinished:Wait()
				if not npc:GetAttribute("IsWandering") then break end
			end
			task.wait(math.random(1, 3))
			repeat newDestination = getRandomWanderingSpawn(); task.wait() until newDestination ~= oldDestination or not npc:GetAttribute("IsWandering")
			pathWaypoints = Nav.GetPath(HRP.CFrame, newDestination.Position)
			oldDestination = newDestination
		end
	end)
	return npc
end

-----< Choose closest wandering NPC for intake
local function popClosestNPC(owner, restaurantModel)
	local registers = restaurantModel.Furniture.CashRegisters
	local reg = registers and registers:GetChildren()[1]; if not reg then return nil end
	local targetPos = reg.Placement.Position
	if not wanderingNPCsByPlayer[owner] or #wanderingNPCsByPlayer[owner] == 0 then return nil end
	local bestIdx, bestDist
	for i, npcData in ipairs(wanderingNPCsByPlayer[owner]) do
		local npc = npcData.NPC; if not npc then continue end
		local rootpart = npc:FindFirstChild("HumanoidRootPart"); if not rootpart then continue end
		if npc and npc:GetAttribute("IsWandering") then
			local dist = (rootpart.Position - targetPos).Magnitude
			if not bestDist or dist < bestDist then bestDist = dist; bestIdx = i end
		end
	end
	if bestIdx then return table.remove(wanderingNPCsByPlayer[owner], bestIdx) end
	return nil
end

-----< Wandering intake loop
local function StartWanderingIntakeLoop(intakeCallback, rigTemplate, vipTemplate, animateTemplate)
	task.spawn(function()
		while true do
			if Lighting.ClockTime >= 9 and Lighting.ClockTime <= 21 then
				if Lighting.ClockTime > 17 and Lighting.ClockTime < 18 then
					if not RushHour then
						RushHour = true; Helpers.notifyAll("RUSH HOUR! Lots of customers will spawn"); WANDERING_PER_PLAYER_CAP = 10
						task.spawn(function()
							repeat task.wait(.4) until Lighting.ClockTime > 18
							Helpers.notifyAll("Rush hour has ended"); RushHour = false; WANDERING_PER_PLAYER_CAP = 6
						end)
					end
				end
				for _, restaurant in ipairs(OwnedRestaurants:GetChildren()) do
					local owner = Players:FindFirstChild(restaurant.Name); if not owner then continue end
					local data = DataAPI.Data(owner); if not (data and data.Settings.Open) then continue end
					if playerWandering(owner) > 0 then
						local moved = 0
						while moved < WANDERING_PER_PLAYER_CAP and playerWandering(owner) > 0 and Helpers.seatsAvailable(restaurant) do
							local npcData = popClosestNPC(owner, restaurant); if not npcData then break end
							task.spawn(intakeCallback, npcData, restaurant)
							moved += 1; task.wait(0.25)
						end
					end
				end
			end
			local players = Players:GetPlayers()
			if totalWandering() < #players * WANDERING_PER_PLAYER_CAP then
				if nextSpawnPlayerIdx > #players then nextSpawnPlayerIdx = 1 end
				local ownerCandidate = players[nextSpawnPlayerIdx]; nextSpawnPlayerIdx += 1
				if ownerCandidate and playerWandering(ownerCandidate) < WANDERING_PER_PLAYER_CAP then
					inc(ownerCandidate)
					task.spawn(function()
						if workspace:GetAttribute("GoldRush") == true then
							local Chance = 25; local Rnd = Random.new(tick()); local Num = Rnd:NextNumber(0, 100)
							if Num < Chance then SpawnWanderingForOwner(ownerCandidate, "VIP", rigTemplate, vipTemplate, animateTemplate) else SpawnWanderingForOwner(ownerCandidate, nil, rigTemplate, vipTemplate, animateTemplate) end
						else
							SpawnWanderingForOwner(ownerCandidate, nil, rigTemplate, vipTemplate, animateTemplate)
						end
					end)
				end
			end
			task.wait(2)
		end
	end)
end

-----< Wandering player hooks
local function OnPlayerRemoving(player)
	wanderingPerPlayerCount[player.UserId] = nil
	if wanderingNPCsByPlayer[player] then
		for _, data in ipairs(wanderingNPCsByPlayer[player]) do if data.NPC then data.NPC:Destroy() end end
		table.clear(wanderingNPCsByPlayer[player]); wanderingNPCsByPlayer[player] = nil
	end
end

local function OnPlayerAdded(player)
	wanderingNPCsByPlayer[player] = {}
end

-----< Wandering initialization
InitWandering()

-----< Navigation exports
GetPath = Nav.GetPath

ScriptsWalkTo = Nav.ScriptsWalkTo

-----< Customer flow handled by module (CustomerFlowModule)

-----< Start wandering loop
StartWanderingIntakeLoop(function(npcData, restaurant)
	CustomerFlowModule.MakeNPCGoIntoRestaurant(npcData, restaurant, {
		eatingAnimation = script.EatingAnimation,
		orderScreenParent = script,
		onSeated = function() dec(npcData.Owner) end
	})
end, script.Rig, script.VIP, Animate)

-----< Dev products
WillsAPI.DevProducts["VIPCustomer"]:Connect(function(Player, Data)
	task.spawn(function() SpawnWanderingForOwner(Player, "VIP", script.Rig, script.VIP, Animate) end)
	Helpers.notifyPlayer(Player, "VIP Customer has spawned outside of your restaurant!")
end)

-----< Passive income tick
task.spawn(function()
	while true do
		for _, Player in Players:GetPlayers() do
			local Data = DataAPI.Data(Player)
			if Data then Data.Cash += 8 end
			DataAPI.UpdateData(Player)
		end

		task.wait(60)
	end
end)

-----< Player events wiring
game.Players.PlayerRemoving:Connect(OnPlayerRemoving)
game.Players.PlayerAdded:Connect(OnPlayerAdded)
task.spawn(function() for _, p in Players:GetPlayers() do OnPlayerAdded(p) end end)