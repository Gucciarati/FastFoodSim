-- Direct function: (Museum, Player, SlotId, SnowmanName) -> boolean
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.MuseumComponent)

type MuseumComponent = SharedTypes.MuseumComponent

return function(Museum: MuseumComponent, Player: Player, SlotId: number, SnowmanName: string): boolean
	local MuseumData = Museum:GetFromPlayer(Player)
	if not MuseumData then return false end

	if SlotId > MuseumData.MaxSlots then return false end
	if not Museum:IsSlotEmpty(Player, SlotId) then return false end
	MuseumData.Slots[SlotId] = {
		SnowmanName = SnowmanName,
		PlacedAt = DateTime.now().UnixTimestamp,
	}

	return true
end
