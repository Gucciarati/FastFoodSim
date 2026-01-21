--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.ProfileComponent)

type ProfileComponent = SharedTypes.ProfileComponent

return function(ProfileComponent: ProfileComponent, player: Player)
	local profile = ProfileComponent.ProfileStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return not player:IsDescendantOf(Players)
		end,
	})

	if not profile then
		player:Kick("Profile load fail - Please rejoin")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function()
		player:Kick(`Profile session end - Please rejoin`)
	end)

	-- Register the profile on Registry, Act as "cache" for reusability purposes.
	if not player:IsDescendantOf(Players) then profile:EndSession() end
	return profile
end
