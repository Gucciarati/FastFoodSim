--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.CurrentBlueprintComponent)

type CurrentBlueprintComponent = SharedTypes.CurrentBlueprintComponent

return function(CurrentBlueprint: CurrentBlueprintComponent, Player: Player)
	local BlueprintData = CurrentBlueprint:GetFromPlayer(Player)

	BlueprintData.CurrentSnowmanName = nil
	BlueprintData.Goal = 0
	BlueprintData.SnowCollected = 0
end
