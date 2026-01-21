--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local DetermineNeededBlueprintMaterials = require(ReplicatedStorage.Util.Config.DetermineNeededBlueprintMaterials)
local SharedTypes = require(Components.Types.CurrentBlueprintComponent)

type CurrentBlueprintComponent = SharedTypes.CurrentBlueprintComponent

return function(CurrentBlueprint: CurrentBlueprintComponent, Player: Player, BlueprintName: string)
	local BlueprintData = CurrentBlueprint:GetFromPlayer(Player)

	local Goal = DetermineNeededBlueprintMaterials(BlueprintName)

	BlueprintData.CurrentSnowmanName = BlueprintName
	BlueprintData.Goal = Goal
	BlueprintData.SnowCollected = 0
end
