-----< Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = ReplicatedStorage.Functions.Rewards
local APIs = ReplicatedStorage.APIs
local RewardsAPI = require(APIs.rewards)
local Settings = require(APIs.settings)
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)

-----< Daily rewards

Functions.ClaimDailyReward.OnServerInvoke = function(Player, Reward)
	local RewardInfo = RewardsAPI.DailyRewards[Reward]
	if not RewardInfo then return end
	local String = tostring(Reward)
	local Data = DataAPI.Data(Player)
	if not Data or Data.LoginStreak < Reward or Data.DailyRewards[String] then return end
	Data.DailyRewards[String] = true
	local Missing = false
	for Reward,Value in pairs(Data.DailyRewards) do
		Missing = Missing or not Value
	end
	if not Missing then
		Data.LoginStreak = 0
		for Reward,_ in pairs(Data.DailyRewards) do
			Data.DailyRewards[tostring(Reward)] = false
		end
	end
	DataAPI.UpdateData(Player)
	return Settings.RewardPlayer(Player, RewardInfo.Rewards)
end

DataAPI.ProfileTemplate.DailyRewards = {}
for Index,_ in pairs(RewardsAPI.DailyRewards) do
	DataAPI.ProfileTemplate.DailyRewards[tostring(Index)] = false
end

Handler.productPurchaseFunctions["Rewards"] = function(Player, Data, Product)
	if Product == "ClaimAllDailyRewards" then
		for Time,Reward in pairs(RewardsAPI.DailyRewards) do
			local Current = Data.LoginStreak
			Data.LoginStreak = Current < Time and Time or Current
		end
	end
end

-----< 