--[[
	Reset Module
	----------------
	Handles player data reset via Gameplay remotes. Resets profile data
	to template and prompts rejoin.

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
	Remotes.Reset.OnServerEvent:Connect(function(Player)
		local Data = DataAPI.Data(Player)
		if not Data then return end
		for Name,_ in pairs(Data) do Data[Name] = DataAPI.ProfileTemplate[Name] end
		for Name,Value in pairs(DataAPI.ProfileTemplate) do Data[Name] = Value end
		Player:Kick("Please rejoin!")
	end)
end

-----< Exports
return M


