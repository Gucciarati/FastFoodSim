local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerComponents =
	require(ServerScriptService.Player.Components.PlayerComponents)
local ProfileComponent = require(script.Parent.Components.ProfileComponent)
local TimeIt = require(ReplicatedStorage.Util.Tools.TimeIt)
local World = require(ServerScriptService.World)

return function()
	-- On Player Added
	local function PlayerAdded(entity, player: Player)
		local profile = TimeIt(function()
			return ProfileComponent.add(entity, player)
		end)

		print(`{player.Name}({entity}) Profile Added`, profile.Data)
		-- Startup Data, For starters
	end

	PlayerComponents.onAdded:Connect(PlayerAdded)
	PlayerComponents.onRemoved:Connect(function(entity)
		-- Check if entity is a thing, If not then exit
		if not entity then return end

		-- Check if player has profile
		local profile = ProfileComponent.get(entity)
		if not profile then return end

		-- Remove the profile
		ProfileComponent.remove(entity)

		task.defer(function()
			World.kill(entity)
		end)
	end)
end
