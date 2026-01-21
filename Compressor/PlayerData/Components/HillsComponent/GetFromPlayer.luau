-- Direct function: (Hills, Player) -> table
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local PlayerComponent = require(ServerScriptService.Player.Components.PlayerComponents)
local SharedTypes = require(Components.Types.HillsComponent)

type HillsComponent = SharedTypes.HillsComponent

return function(Hills: HillsComponent, Player: Player)
	local Entity = PlayerComponent.playerInstanceToEntity(Player)
	return Hills.get(Entity)
end
 