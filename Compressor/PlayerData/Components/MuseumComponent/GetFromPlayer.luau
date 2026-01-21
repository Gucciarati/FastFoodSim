-- Direct function: (Museum, Player) -> table
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local PlayerComponent = require(ServerScriptService.Player.Components.PlayerComponents)
local SharedTypes = require(Components.Types.MuseumComponent)

type MuseumComponent = SharedTypes.MuseumComponent

return function(Museum: MuseumComponent, Player: Player)
	local Entity = PlayerComponent.playerInstanceToEntity(Player)
	return Museum.get(Entity)
end
