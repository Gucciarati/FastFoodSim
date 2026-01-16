-----< Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Potions
local APIs = ReplicatedStorage.APIs
local PotionsAPI = require(APIs.potions)
local Settings = require(APIs.settings)
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)

-----< Data

DataAPI.ProfileTemplate.ActivePotions = {}
DataAPI.ProfileTemplate.Potions = {}

for Potion,_ in pairs(PotionsAPI.PotionProducts) do
	DataAPI.ProfileTemplate.Potions[Potion] = 0
end

for _,Potion in pairs(PotionsAPI.Potions) do
	DataAPI.ProfileTemplate.ActivePotions[Potion] = 0
end

-----< Products

local SelectedPotion = {}
local Blacklisted = {
	"Gold10Mins", "Gold30Mins", "Gold2Hrs"
}

Handler.productPurchaseFunctions["Potions"] = function(Player, Data, Product)
	if table.find(Blacklisted, Product) then return end
	if PotionsAPI.ProductTimes[Product] then
		Data.ActivePotions[SelectedPotion[Player] or PotionsAPI.Potions[1]] += PotionsAPI.ProductTimes[Product]
	end
	if PotionsAPI.PotionProducts[Product] then
		Data.Potions[Product] += 1
	end
	if PotionsAPI.PotionBundles[Product] then
		for Potion,Amount in pairs(PotionsAPI.PotionBundles[Product]) do
			Data.Potions[Potion] += Amount
		end
	end
end

Handler.playerRemovingFunction(function(Player)
	SelectedPotion[Player] = nil
end)

Remotes.SelectPotion.OnServerEvent:Connect(function(Player, Potion)
	SelectedPotion[Player] = Potion
end)

-----< Multipliers

Settings.MultiplierFunctions["Potions"] = function(Player, Data, Type)
	if Type == "Cash" then
		return Data.ActivePotions["Double Cash"] > 0 and 2 or 1
	elseif Type == "XP" then
		return Data.ActivePotions["Double XP"] > 0 and 2 or 1
	elseif Type == "NPCWalkSpeed" then
		return 16 * (Data.ActivePotions["Speed Up"] > 0 and 2 or 1)
	end
end

-----< Rewards

Settings.RewardStringFunctions["Potions"] = function(Player, Reward)
	if Reward.PotionDuration then
		return Handler.timer(Reward.PotionDuration,2).." "..Reward.Potion.." Potion"
	elseif Reward.Potion then
		return "x"..Reward.Amount.." "..Reward.Potion.." Potion"..(Reward.Amount == 1 and "" or "s")
	end
end

Settings.RewardPlayerFunctions["Potions"] = function(Player, Data, Reward)
	if Reward.PotionDuration then
		Data.ActivePotions[Reward.Potion] += Reward.PotionDuration
	elseif Reward.Potion then
		Data.Potions[Reward.Potion] += Reward.Amount
	end
end

-----< Use potion

Remotes.UsePotion.OnServerEvent:Connect(function(Player, Potion)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local Info = PotionsAPI.PotionProducts[Potion]
	if not Info or Data.Potions[Potion] < 1 then return end
	Data.Potions[Potion] -= 1
	Data.ActivePotions[Info.Potion] += Info.Duration
	DataAPI.UpdateData(Player)
end)

-----< 