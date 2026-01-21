-- Direct function: (Museum, Player, SlotId) -> table?
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.MuseumComponent)

type MuseumComponent = SharedTypes.MuseumComponent

return function(Museum: MuseumComponent, Player: Player, SlotId: number)
	local MuseumData = Museum:GetFromPlayer(Player)
	if not MuseumData or not MuseumData.Slots then return nil end

	return MuseumData.Slots[SlotId]
end
