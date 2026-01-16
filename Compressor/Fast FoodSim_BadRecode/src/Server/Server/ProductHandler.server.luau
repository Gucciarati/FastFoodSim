--[[
    Product Handler
    ----------------
    This script manages product purchases related to Packs.
    It validates purchase conditions (delay, duration, start/end time)
    and rewards the player upon successful purchase.

    Created by: Guinogue — Modified on October 24, 2025
]]

-----< Services & Modules >

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local APIs = ReplicatedStorage.APIs

local Settings = require(APIs.settings)
local Handler = require(APIs.handler)
local PacksAPI = require(APIs.packs)
local DataAPI = require(APIs.data)

-----< Data Setup >

DataAPI.ProfileTemplate.Packs = {}

-----< Product Handling >

Handler.productPurchaseFunctions["Packs"] = function(Player, Data, Product)
	for Pack, Information in pairs(PacksAPI) do
		if Pack ~= Product then continue end

		local Delay = Information.Delay or 0
		if Information.Duration and os.time() - (Data.FirstJoin + Delay) > Information.Duration then continue end
		if Information.Delay and os.time() - Data.FirstJoin < Information.Delay then continue end
		if Information.Start and os.time() < Information.Start then continue end
		if Information.End and os.time() > Information.End then continue end

		local Found = Data.Packs[Pack]
		if Found and Information.Purchases and Found >= Information.Purchases then return end

		Data.Packs[Pack] = (Found or 0) + 1
		Remotes.Handler.Notify:FireClient(Player, Settings.RewardPlayer(Player, Information.Rewards), "Green")
	end
end
