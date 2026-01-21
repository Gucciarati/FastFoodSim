--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.ConveyorComponent)

type ConveyorComponent = SharedTypes.ConveyorComponent

return function(Conveyor: ConveyorComponent, Player: Player): number
	local ConveyorData = Conveyor:GetFromPlayer(Player)
	return ConveyorData.SpawnRateMultiplier
end
