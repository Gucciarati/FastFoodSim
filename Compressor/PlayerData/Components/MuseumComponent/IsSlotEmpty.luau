-- Direct function: (Museum, Player, SlotId) -> boolean
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.MuseumComponent)

type MuseumComponent = SharedTypes.MuseumComponent

return function(Museum: MuseumComponent, Player: Player, SlotId: number): boolean
	local Slot = Museum:GetSlot(Player, SlotId)
	return Slot == nil or Slot.SnowmanName == nil
end
