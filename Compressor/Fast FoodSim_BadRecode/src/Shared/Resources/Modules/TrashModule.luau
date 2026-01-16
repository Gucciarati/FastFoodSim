--[[
	Trash Module
	----------------
	Handles trashing items and inventory cleanup via Gameplay remotes.

	Created by: Guinogue — Modified on October 29, 2025
]]

-----< Services and dependencies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local APIs = ReplicatedStorage.APIs
local DataAPI = require(APIs.data)
local Handler = require(APIs.handler)

local Remotes = ReplicatedStorage.Remotes.Gameplay
local Helpers = require(ReplicatedStorage.Resources.Modules.HelpersModule)

-----< Module table
local M = {}

-----< Public API
function M.init(OwnedRestaurants)
	Remotes.TrashItem.OnServerEvent:Connect(function(Player, Item)
		if not Item then return end
		local Restaurant = Item.Parent and Item.Parent.Parent
		if not Restaurant or Restaurant.Parent ~= OwnedRestaurants then return end
		local Data = DataAPI.Data(Players:FindFirstChild(Restaurant.Name))
		if not Data then return end
		if not Restaurant.Whitelist:FindFirstChild(Player.Name) then return end
		if Item.Parent == Restaurant.Trash then
			Handler.destroy(Item)
			Helpers.playAudio(Player, "Trash")
		elseif Item.Parent == Restaurant.Ingredients then
			Data.Foods[Item and Item.Name or ""] = nil
			Handler.destroy(Item)
			DataAPI.UpdateData(Player)
			Helpers.playAudio(Player, "Trash")
		end
	end)
end

-----< Exports
return M


