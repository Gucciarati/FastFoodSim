-----< Variables

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Remotes = ReplicatedStorage.Remotes.Store
local APIs = ReplicatedStorage.APIs
local ChatAPI = require(script.Parent.chat_manager)
local Settings = require(APIs.settings)
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)
local WillsAPI = require(APIs.willsAPI)

-----< Gifting

Handler.playerAddedFunction(function(Player)
	Handler.create("StringValue", Player, "GiftingUsername")
	Handler.create("BoolValue", Player, "IsGifting")
end)

Remotes.Gift.OnServerEvent:Connect(function(Player, Gifting)
	Player.IsGifting.Value = Gifting
	Player.GiftingUsername.Value = Gifting or ""
end)

DataAPI.OfflineData["GiftProduct"] = function(Player, Data, OfflineData)
	local Product = Settings.DevProducts[OfflineData.Id]
	if not Product then return end
	local GamePass = Settings.DevProducts[OfflineData.Id]:match("^Gift(.+)")
	BoughtProduct(Player, Data, Product, GamePass)
end

-----< Bought gamepass

function BoughtGamePass(Player, GamePass, Free)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	
	if Data.GamePasses[GamePass] then
		if Data.TemporaryGamePasses[GamePass] < 1 then return end
		Data.TemporaryGamePasses[GamePass] = 0
	end
	
	if not Free then
		Data.RobuxSpent += Handler.productInfo(Settings.GamePassId[GamePass], "GamePass").PriceInRobux
	end
	Data.GamePasses[GamePass] = true
	
	if Settings.PurchaseRewards[GamePass] then
		Settings.RewardPlayer(Player, Settings.PurchaseRewards[GamePass])
	end
	
	DataAPI.UpdateData(Player)
	ChatAPI.updateChat(Player)
end

-----< Temporary gamepasses

function TemporaryGamePass(Player, GamePass, Duration)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local TemporaryTimer = Data.TemporaryGamePasses[GamePass]
	if Data.GamePasses[GamePass] and TemporaryTimer < 1 then return end
	local Time = DateTime.now().UnixTimestamp
	local Value = (TemporaryTimer > Time and TemporaryTimer or Time) + Duration
	Data.TemporaryGamePasses[GamePass] = Value
	Data.GamePasses[GamePass] = true
end

-----< Rewards

Settings.RewardStringFunctions["Store"] = function(Player, Reward)
	if Reward.TemporaryGamePass then
		return Handler.timer(Reward.Duration, 2).." "..Reward.TemporaryGamePass.." GamePass"
	elseif Reward.GamePass then
		return Reward.GamePass.." GamePass"
	elseif Reward.Product then
		return Reward.Product.." Product"
	end
end

Settings.RewardPlayerFunctions["Store"] = function(Player, Data, Reward)
	if Reward.TemporaryGamePass then
		TemporaryGamePass(Player, Reward.TemporaryGamePass, Reward.Duration)
	elseif Reward.GamePass then
		BoughtGamePass(Player, Reward.GamePass, true)
	elseif Reward.Product then
		BoughtProduct(Player, Data, Reward.Product, Reward.Product:match("^Gift(.+)"))
	end
end

-----< Subscriptions

function UpdateSubscription(Player, Subscription)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local Result,Success = Handler.forcePcall(3, .5, MarketplaceService.GetUserSubscriptionStatusAsync, MarketplaceService, Player, Settings.SubscriptionId[Subscription])
	
	Data.Subscriptions[Subscription] = Success and Result.IsSubscribed
	DataAPI.UpdateData(Player)
	ChatAPI.updateChat(Player)
end

Players.UserSubscriptionStatusChanged:Connect(function(Player, SubscriptionId)
	for Id,Subscription in pairs(Settings.Subscriptions) do
		if Id ~= SubscriptionId then continue end
		UpdateSubscription(Player, Settings.Subscriptions[SubscriptionId])
	end
end)

-----< Website purchases

Handler.playerAddedFunction(function(Player)
	local Data = DataAPI.WaitForData(Player)
	if not Data then return end
	
	for GamePass,Value in pairs(Data.GamePasses) do
		if Value then continue end
		local Owned,Success = Handler.forcePcall(3, .5, MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, Player.UserId, Settings.GamePassId[GamePass])
		if Success and Owned then
			BoughtGamePass(Player, GamePass)
		end
	end
	
	for Subscription,_ in pairs(Data.Subscriptions) do
		UpdateSubscription(Player, Subscription)
	end
end)

-----< GamePasses

Handler.gamePassPurchase(function(Player, Id)
	local GamePass = Settings.GamePasses[Id]
	if GamePass then
		BoughtGamePass(Player, GamePass)
	end
end)

-----< Limiteds

local StockAPI = require(APIs.stock)
StockAPI.CreateGroup(Settings.LimitedsVersion)

for Product,Info in pairs(Settings.Limiteds) do
	StockAPI.CreateStock(Settings.LimitedsVersion, Product, Info.Limited)
end

Handler.childAdded(StockAPI.Live:WaitForChild(Settings.LimitedsVersion), function(Limited)
	local Info = Settings.Limiteds[Limited.Name]
	Handler.changed(Limited, function(Value)
		Settings.PurchaseRewards[Limited.Name] = Value > 0 and Info.Rewards or nil
	end)
end)

-----< Products

function BoughtProduct(Player, Data, Product, GamePass)
	if GamePass then
		BoughtGamePass(Player, GamePass, true)
	end
	
	if Settings.PurchaseRewards[Product] then
		Settings.RewardPlayer(Player, Settings.PurchaseRewards[Product])
	end
	
	if WillsAPI.DevProducts[Product] then
		WillsAPI.DevProducts[Product]:Fire(Player, Data)
	end
	
	for _,Function in pairs(Handler.productPurchaseFunctions) do
		Function(Player, Data, Product)
	end
	
	if Settings.Limiteds[Product] then
		StockAPI.IncrementStock(Settings.LimitedsVersion, Product, -1)
	end
	
	DataAPI.UpdateData(Player)
end

MarketplaceService.ProcessReceipt = function(Info)
	local From,Id = Players:GetPlayerByUserId(Info.PlayerId),Info.ProductId
	if not From then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local RecipientName = Handler.gifting(From) or From.Name
	local Product = Settings.DevProducts[Id]
	if not Product then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local GamePass = Settings.DevProducts[Id]:match("^Gift(.+)")
	local ProductInfo = Handler.productInfo(Id, "Product")
	
	if From.Name ~= RecipientName then
		ChatAPI.systemMessage(From.Name.." bought "..ProductInfo.Name.." for "..RecipientName.."!", "rgb(0,255,0)")
	end
	
	local FromData = DataAPI.Data(From)
	
	if FromData then
		FromData.RobuxSpent += ProductInfo.PriceInRobux
		DataAPI.UpdateData(From)
	end
	
	local Recipient = Players:FindFirstChild(RecipientName)
	
	if Recipient then
		BoughtProduct(Recipient, DataAPI.Data(Recipient), Product, GamePass)
	else
		local UserId = Handler.forcePcall(1, .1, Players.GetUserIdFromNameAsync, Players, RecipientName)
		if UserId then
			DataAPI.SetOfflineData(UserId, {
				Key = "GiftProduct",
				From = From.Name,
				Id = Id,
			})
		end
	end
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-----< 