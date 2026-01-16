local module = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local APIs = ReplicatedStorage.APIs
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)

module.GroupId = game.CreatorId
module.SessionBuffer = 5*60
module.PlayersCanCollide = false
module.VirtualCursorMode = true
module.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

module.Subscriptions = require(script.subscriptions)
module.GamePasses = require(script.gamepasses)
module.DevProducts = require(script.devproducts)
module.GamePassId,module.DevProductId,module.SubscriptionId = {},{},{}

for Id,GamePass in pairs(module.GamePasses) do
	module.GamePassId[GamePass] = Id
end
for Id,DevProduct in pairs(module.DevProducts) do
	module.DevProductId[DevProduct] = Id
end
for Id,Subscription in pairs(module.Subscriptions) do
	module.SubscriptionId[Subscription] = Id
end

module.PurchaseRewards = {
	["CashPack1"] = {
		{Type = "Cash", Amount = 100},
	},
	["CashPack2"] = {
		{Type = "Cash", Amount = 250},
	},
	["CashPack3"] = {
		{Type = "Cash", Amount = 1250},
	},
	["CashPack4"] = {
		{Type = "Cash", Amount = 2500},
	},
	["CashPack5"] = {
		{Type = "Cash", Amount = 3750},
	},
	["CashPack6"] = {
		{Type = "Cash", Amount = 6900},
	},
	["CashPack7"] = {
		{Type = "Cash", Amount = 25000},
	},
	["CashPack8"] = {
		{Type = "Cash", Amount = 50000},
	},
	["UnlockEmployeeSlot"] = {
		{Type = "EmployeeSlots", Amount = 1},
	},
	["GrillChef"] = {
		{NPC = "Grill"},
	},
	["Janitor"] = {
		{NPC = "Janitor"},
	},
	["FryChef"] = {
		{NPC = "Fry"},
	},
	["Cashier"] = {
		{NPC = "Cashier"},
	},
	["Server"] = {
		{NPC = "Server"},
	},
	["GoldBooth"] = {
		{Package = "Gold Booth", Category = "Furniture", Amount = 1},
	},
	["GoldChair"] = {
		{Package = "Gold Chair", Category = "Furniture", Amount = 1},
	},
	["GoldTable"] = {
		{Package = "Gold Table", Category = "Furniture", Amount = 1},
	},
	["GoldLargeTable"] = {
		{Package = "Large Gold Table", Category = "Furniture", Amount = 1},
	},
	["GoldFryer"] = {
		{Package = "Gold Fryer", Category = "Appliances", Amount = 1},
	},
	["GoldCooktop"] = {
		{Package = "Gold Cooktop", Category = "Appliances", Amount = 1},
	},
}

module.LimitedsVersion = "LimitedsV1"
module.Limiteds = {
}

module.EventMultipliers = {
	["Cash"] = 1,
}

module.MultiplierFunctions = {
	["Default"] = function(Player, Data, Type)
		if Type == "Cash" then
			return Data.GamePasses["DoubleCash"] and 2 or 1
		elseif Type == "XP" then
			return Data.GamePasses["DoubleXP"] and 2 or 1
		elseif Type == "FoodDiscount" then
			return Data.GamePasses["FoodPlus"] and 0.75 or 1
		elseif Type == "WorkerSpeed" then
			return Data.GamePasses["FastWorkers"] and 0.5 or 1
		end
	end,
	["Events"] = function(Player, Data, Type)
		return module.EventMultipliers[Type] or 1
	end,
}

function module.Multiplier(Player, Type)
	local Data = RunService:IsServer() and DataAPI.Data(Player) or Handler.waitForData(Player)
	if not Data then return end
	
	if typeof(Data) == "Instance" then
		Data = Handler.objectToTable(Data)
	end
	
	local Multiplier = 1
	
	for _,Function in pairs(module.MultiplierFunctions) do
		Multiplier *= Function(Player, Data, Type, Multiplier) or 1
	end
	
	return Multiplier
end

module.RewardStringFunctions = {
	["Default"] = function(Player, Reward)
		if Reward.Type then
			return Handler.abbreviate(Reward.Amount * module.Multiplier(Player, Reward.Type)).." "..Reward.Type
		end
	end,
}

function module.RewardString(Player, Rewards)
	local RewardString = "You recieved "
	
	for Index,Reward in pairs(Rewards) do
		local Prefix, String = (Index == 1 and "") or (Index == #Rewards and " and ") or ", ", nil
		
		for _,Function in pairs(module.RewardStringFunctions) do
			String = Function(Player, Reward)
			if String then
				RewardString = RewardString..Prefix..String
				break
			end
		end
	end
	
	RewardString = RewardString.."!"
	return RewardString
end

module.RewardPlayerFunctions = {
	["Default"] = function(Player, Data, Reward)
		if Reward.Type then
			Data[Reward.Type] += Reward.Amount * module.Multiplier(Player, Reward.Type)
		end
	end,
}
	
function module.RewardPlayer(Player, Rewards)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	
	for _,Reward in pairs(Rewards) do
		for _,Function in pairs(module.RewardPlayerFunctions) do
			Function(Player, Data, Reward)
		end
	end
	
	DataAPI.UpdateData(Player)
	
	return module.RewardString(Player, Rewards)
end

function module.Owns(Player, Data, T)
	if not Player or not Data then return end
	
	local Group,UserIds,GamePass,Subscription,Premium,LB = T.Group,T.UserIds,T.GamePass,T.Subscription,T.Premium,T.Leaderboard
	Subscription = Data.Subscriptions[Subscription]
	GamePass = Data.GamePasses[GamePass]
	
	--if LB then
	--	local LeaderboardInfo = LeaderboardAPI.GetUser(LB.Leaderboard, Player.UserId)
	--	local Rank,Placement,Higher = LeaderboardInfo and LeaderboardInfo.Rank or math.huge,LB.Placement,LB.Higher
	--	if Rank == Placement or (Higher and Rank < Placement) then
	--		return true
	--	end
	--end
	
	if Group then
		local Rank,Success = Handler.forcePcall(1, .1, Player.GetRankInGroup, Player, Group.Id)
		if Rank and Success then
			local Placement,Higher = Group.Rank,Group.Higher
			if Rank == Placement or (Higher and Rank > Placement) then
				return true
			end
		end
	end
	
	return T.Everyone
		or (GamePass)
		or (Subscription)
		or (UserIds and table.find(UserIds, Player.UserId))
		or (Premium and Player:WaitForChild("Premium").Value)
end

return module