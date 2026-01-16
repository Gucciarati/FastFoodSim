local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Remotes = ReplicatedStorage.Remotes.Gameplay
local StoreRemotes = ReplicatedStorage.Remotes.Store

local APIs = ReplicatedStorage.APIs
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)
local Settings = require(APIs.settings)
local GameplayAPI = require(APIs.gameplay)
local Helpers = require(ReplicatedStorage.Resources.Modules.HelpersModule)
local WillsAPI = require(APIs.willsAPI)

local M = {}

function M.init(OwnedRestaurants)
	Remotes.Buy.OnServerEvent:Connect(function(Player, Cart)
		local Data = DataAPI.Data(Player)
		if not Data then return end
		local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
		if not Restaurant then return end
		for _,Info in pairs(Cart) do
			local ItemInfo = GameplayAPI.Items[Info.Category][Info.Item]
			if not ItemInfo then continue end
			local Discount = Info.Category == "Food" and Settings.Multiplier(Player, "FoodDiscount") or 1
			if GameplayAPI.XPToLevel(Data.XP) < ItemInfo.Lvl then continue end
			for Index = 1,Info.Amount do
				local InTutorial = Data.Settings.Tutorial <= 3
				if InTutorial and Data.Packages[Info.Item] then continue end
				local Cost = (ItemInfo.Unit * ItemInfo.UnitPrice) * Discount
				if Data.Cash < Cost or GameplayAPI.XPToLevel(Data.XP) < ItemInfo.Lvl then break end
				if Handler.dictionaryLength(Data.Packages) >= 25 then break end
				Data.Cash -= Cost
				Data.BoughtCount[Info.Item] = (Data.BoughtCount[Info.Item] or 0) + 1
				local GUID = InTutorial and Info.Item or Handler.generateGUID()
				local CF = Restaurant.Spawn.CFrame*CFrame.new(Handler.random(-10,10),Handler.random(5,10),Handler.random(-10,10))
				Data.Packages[GUID] = { Category = Info.Category, Item = Info.Item, CF = tostring(Restaurant:GetPivot():ToObjectSpace(CF)) }
			end
		end
		DataAPI.UpdateData(Player)
		Helpers.notifyPlayer(Player, "Packages are arriving out front!", "Yellow")
	end)

	Remotes.BuyExpansion.OnServerEvent:Connect(function(Player)
		local Data = DataAPI.Data(Player)
		if not Data then return end
		local ExpansionInfo = GameplayAPI.Expansions[Data.Expansions + 1]
		if not ExpansionInfo then return end
		if Data.Cash < ExpansionInfo.Price or GameplayAPI.XPToLevel(Data.XP) < ExpansionInfo.Lvl then return end
		Data.Cash -= ExpansionInfo.Price
		Data.Expansions += 1
		DataAPI.UpdateData(Player)
	end)

	Remotes.RobuxExpansion.OnServerEvent:Connect(function(Player, Expansion)
		local Data = DataAPI.Data(Player)
		if not Data then return end
		if Data.Expansions + 1 ~= Expansion then
			Helpers.notifyPlayer(Player, "This expansion is locked! Buy the next one", "Red")
			return
		end
		MarketplaceService:PromptProductPurchase(Player, 3289954104)
		StoreRemotes.StartRobux:FireClient(Player)
	end)

	WillsAPI.DevProducts.NewExpansion:Connect(function(Player)
		local Data = DataAPI.Data(Player)
		if not Data then return end
		local ExpansionInfo = GameplayAPI.Expansions[Data.Expansions + 1]
		if not ExpansionInfo then return end
		Data.Expansions += 1
		DataAPI.UpdateData(Player)
	end)
end

return M


