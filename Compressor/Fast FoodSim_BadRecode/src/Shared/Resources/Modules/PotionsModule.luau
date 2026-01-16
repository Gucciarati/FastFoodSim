--[[
	Potions Module
	----------------
	Manages all potion-related functionality including product purchases,
	potion usage, effect multipliers, reward systems, and potion selection.

	Created by: Guinogue — Modified on October 24, 2025
]]

local PotionsModule = {}

-----< Module Setup >

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local APIs = ReplicatedStorage.APIs; local Remotes = ReplicatedStorage.Remotes.Potions
local PotionsAPI, Settings, Handler, DataAPI = require(APIs.potions), require(APIs.settings), require(APIs.handler), require(APIs.data)
local SelectedPotion = {}; local Blacklisted = {"Gold10Mins","Gold30Mins","Gold2Hrs"}

-----< Data Setup >

function PotionsModule.Initialize()
	DataAPI.ProfileTemplate.ActivePotions = {}; DataAPI.ProfileTemplate.Potions = {}
	for p,_ in pairs(PotionsAPI.PotionProducts) do DataAPI.ProfileTemplate.Potions[p] = 0 end
	for _,p in pairs(PotionsAPI.Potions) do DataAPI.ProfileTemplate.ActivePotions[p] = 0 end
	Handler.productPurchaseFunctions["Potions"] = PotionsModule.HandleProductPurchase
	Handler.playerRemovingFunction(PotionsModule.OnPlayerRemoving)
	Settings.MultiplierFunctions["Potions"] = PotionsModule.GetMultiplier
	Settings.RewardStringFunctions["Potions"] = PotionsModule.GetRewardString
	Settings.RewardPlayerFunctions["Potions"] = PotionsModule.GiveReward
	Remotes.SelectPotion.OnServerEvent:Connect(PotionsModule.OnSelectPotion)
	Remotes.UsePotion.OnServerEvent:Connect(PotionsModule.OnUsePotion)
	return true
end

-----< Products >

function PotionsModule.HandleProductPurchase(Player, Data, Product)
	if not Player or not Data or not Product or table.find(Blacklisted, Product) then return false end
	local ok = false
	if PotionsAPI.ProductTimes[Product] then local s = SelectedPotion[Player] or PotionsAPI.Potions[1]; if s and Data.ActivePotions[s] then Data.ActivePotions[s] += PotionsAPI.ProductTimes[Product]; ok = true end end
	if PotionsAPI.PotionProducts[Product] and Data.Potions[Product] then Data.Potions[Product] += 1; ok = true end
	if PotionsAPI.PotionBundles[Product] then for p,a in pairs(PotionsAPI.PotionBundles[Product]) do if Data.Potions[p] and a > 0 then Data.Potions[p] += a; ok = true end end end
	return ok
end
function PotionsModule.OnPlayerRemoving(Player) if Player then SelectedPotion[Player] = nil end end
function PotionsModule.OnSelectPotion(Player, Potion) if not Player or not Potion then return false end; if table.find(PotionsAPI.Potions, Potion) then SelectedPotion[Player] = Potion return true end return false end

-----< Multipliers >

function PotionsModule.GetMultiplier(Player, Data, Type)
	if not Player or not Data or not Type then return Type == "NPCWalkSpeed" and 16 or 1 end
	if Type == "Cash" then return Data.ActivePotions["Double Cash"] > 0 and 2 or 1
	elseif Type == "XP" then return Data.ActivePotions["Double XP"] > 0 and 2 or 1
	elseif Type == "NPCWalkSpeed" then return 16 * (Data.ActivePotions["Speed Up"] > 0 and 2 or 1) end
	return 1
end

-----< Rewards >

function PotionsModule.GetRewardString(Player, Reward)
	if not Reward then return "" end
	if Reward.PotionDuration and Reward.Potion then return Handler.timer(Reward.PotionDuration, 2).." "..Reward.Potion.." Potion"
	elseif Reward.Potion and Reward.Amount then return "x"..Reward.Amount.." "..Reward.Potion.." Potion"..(Reward.Amount == 1 and "" or "s") end
	return ""
end
function PotionsModule.GiveReward(Player, Data, Reward)
	if not Player or not Data or not Reward then return false end
	if Reward.PotionDuration and Reward.Potion and Data.ActivePotions[Reward.Potion] then Data.ActivePotions[Reward.Potion] += Reward.PotionDuration return true
	elseif Reward.Potion and Reward.Amount and Data.Potions[Reward.Potion] then Data.Potions[Reward.Potion] += Reward.Amount return true end
	return false
end

-----< Use Potion >

function PotionsModule.OnUsePotion(Player, Potion)
	if not Player or not Potion then return false end
	local Data = DataAPI.Data(Player); if not Data then return false end
	local Info = PotionsAPI.PotionProducts[Potion]; if not Info or not Data.Potions[Potion] or Data.Potions[Potion] < 1 then return false end
	Data.Potions[Potion] -= 1; if Data.ActivePotions[Info.Potion] then Data.ActivePotions[Info.Potion] += Info.Duration; DataAPI.UpdateData(Player); return true end
	return false
end

-----< Utility Functions >

function PotionsModule.GetSelectedPotion(Player) return Player and SelectedPotion[Player] or nil end
function PotionsModule.SetSelectedPotion(Player, Potion) if Player and Potion then SelectedPotion[Player] = Potion return true end return false end
function PotionsModule.IsBlacklisted(Product) return Product and table.find(Blacklisted, Product) ~= nil end

return PotionsModule
