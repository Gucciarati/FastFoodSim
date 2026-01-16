--[[
	Group Reward Module
	----------------
	Handles the group reward claim remote by validating state, granting
	cash, and persisting data.

	Created by: Guinogue — Modified on October 29, 2025
]]

-----< Services and dependencies

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local APIs = ReplicatedStorage.APIs
local DataAPI = require(APIs.data)

local Remotes = ReplicatedStorage.Remotes.Gameplay

-----< Module table
local M = {}

-----< Public API
function M.init()
	Remotes.ClaimGroup.OnServerEvent:Connect(function(Player)
		local Data = DataAPI.Data(Player)
		if not Data or Data.ClaimedGroupReward then return end
		Data.ClaimedGroupReward = true
		Data.Cash += 1000
		DataAPI.UpdateData(Player)
	end)
end

-----< Exports
return M


