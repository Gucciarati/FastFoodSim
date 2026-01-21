-- Direct function: (Museum, Player, SlotId) -> string?
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.MuseumComponent)

type MuseumComponent = SharedTypes.MuseumComponent

return function(Museum: MuseumComponent, Player: Player, SlotId: number): string?
	local Slot = Museum:GetSlot(Player, SlotId)
	if not Slot then return nil end

	local SnowmanName = Slot.SnowmanName
	local MuseumData = Museum:GetFromPlayer(Player)
	MuseumData.Slots[SlotId] = nil

	return SnowmanName
end
