--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.CurrentBlueprintComponent)

type CurrentBlueprintComponent = SharedTypes.CurrentBlueprintComponent

return function(CurrentBlueprint: CurrentBlueprintComponent, Player: Player, Amount: number)
	local BlueprintData = CurrentBlueprint:GetFromPlayer(Player)
	if not BlueprintData.CurrentSnowmanName then return end

	local Sum = BlueprintData.SnowCollected + Amount
	local CappedSum = math.min(Sum, BlueprintData.Goal)

	BlueprintData.SnowCollected = math.max(CappedSum, 0)
end
