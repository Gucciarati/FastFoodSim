--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local PlayerComponent = require(ServerScriptService.Player.Components.PlayerComponents)
local SharedTypes = require(Components.Types.CurrentBlueprintComponent)

type CurrentBlueprintComponent = SharedTypes.CurrentBlueprintComponent

return function(CurrentBlueprint: CurrentBlueprintComponent, Player: Player)
	local Entity = PlayerComponent.playerInstanceToEntity(Player)
	return CurrentBlueprint.get(Entity)
end
