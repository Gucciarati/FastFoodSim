--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.ConveyorComponent)

type ConveyorComponent = SharedTypes.ConveyorComponent

return function(Conveyor: ConveyorComponent, Player: Player, Value: number): ()
	local ConveyorData = Conveyor:GetFromPlayer(Player)
	ConveyorData.SpawnRateMultiplier = Value
end
