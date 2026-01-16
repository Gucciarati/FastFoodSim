-----< Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Quests
local APIs = ReplicatedStorage.APIs
local GameplayAPI = require(APIs.gameplay)
local Settings = require(APIs.settings)
local QuestsAPI = require(APIs.quests)
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)

-----< Data

DataAPI.ProfileTemplate.Quests = {}

for Type,Information in pairs(QuestsAPI.Quests) do
	DataAPI.ProfileTemplate.Quests[Type] = {Session = Type == "Level" and 1 or 0, Version = 0, Quests = {}}
	
	if not Information.QuestCount then continue end
	for Index = 1,Information.QuestCount do
		DataAPI.ProfileTemplate.Quests[Type].Quests[tostring(Index)] = {
			Tracking = true,
			Claimed = false,
			Start = 0,
			Quest = 0,
		}
	end
end

-----< Level quests

Handler.playerAddedFunction(function(Player)
	local Data = DataAPI.WaitForData(Player)
	local Folder = Handler.waitForData(Player)
	if not Data or not Folder then return end
	Handler.changed(Folder.XP, function(New, Old)
		local NewLevel = GameplayAPI.XPToLevel(New)
		local OldLevel = Data.Quests.Level.LastLevel or 0
		Data.Quests.Level.LastLevel = NewLevel
		for _,Info in pairs(QuestsAPI.Quests.Level.Sessions) do
			for Index,Quest in pairs(Info) do
				if NewLevel >= Quest.Level and OldLevel < Quest.Level then
					Data.Quests.Level.Quests[tostring(Index)] = {
						Quest = Index,
						Start = select(3, Quest.Progress(Data)),
						Tracking = true,
						Claimed = false,
					}
				end
			end
		end
		DataAPI.UpdateData(Player)
	end)
end)

-----< Claim

Remotes.ClaimQuest.OnServerEvent:Connect(QuestsAPI.ClaimQuest)

-----< Track

Remotes.TrackQuest.OnServerEvent:Connect(function(Player, Type, Quest)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	Data.Quests[Type].Quests[tostring(Quest)].Tracking = not Data.Quests[Type].Quests[tostring(Quest)].Tracking
	DataAPI.UpdateData(Player)
end)

-----< Skip quest

local SkippingQuest = {}

Remotes.SkipQuest.OnServerEvent:Connect(function(Player, Type, Quest)
	SkippingQuest[Player] = {Type = Type, Quest = Quest}
end)

Handler.playerRemovingFunction(function(Player)
	SkippingQuest[Player] = nil
end)

Handler.productPurchaseFunctions["Quests"] = function(Player, Data, Product)
	local QuestSkipped = SkippingQuest[Player]
	if Product == "SkipQuest" and QuestSkipped then
		QuestsAPI.RewardQuest(Player, QuestSkipped.Type, QuestSkipped.Quest)
	end
end

-----< 