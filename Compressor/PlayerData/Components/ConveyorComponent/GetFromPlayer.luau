--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local PlayerComponents = require(ServerScriptService.Player.Components.PlayerComponents)
local SharedTypes = require(Components.Types.ConveyorComponent)

type ConveyorComponent = SharedTypes.ConveyorComponent
type ConveyorData = SharedTypes.ConveyorData

local DEFAULT_DATA: ConveyorData = {
	Tier = 1,
	Luck = 1,
	SpawnRateMultiplier = 1,
	LifetimeMultiplier = 1,
}

return function(Conveyor: ConveyorComponent, Player: Player): ConveyorData
	local Entity = PlayerComponents.playerInstanceToEntity(Player)
	if not Entity then
		return DEFAULT_DATA
	end
	return Conveyor.get(Entity) or DEFAULT_DATA
end
