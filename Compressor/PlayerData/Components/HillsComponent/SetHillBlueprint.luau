-- Direct function: (Hills, Player, HillId, BlueprintName, Goal)
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local PlayerComponents = ServerScriptService.Player.Components
local SharedTypes = require(Components.Types.HillsComponent)

type HillsComponent = SharedTypes.HillsComponent

return function(Hills: HillsComponent, Player: Player, HillId: number, BlueprintName: string, Goal: number)
	local Hill = Hills:GetHill(Player, HillId)
	if not Hill then return end

	if not Hill.Blueprint then
		Hill.Blueprint = {
			CurrentSnowmanName = nil,
			Goal = 0,
			SnowCollected = 0,
		}
	end

	Hill.Blueprint.CurrentSnowmanName = BlueprintName
	Hill.Blueprint.Goal = Goal
	Hill.Blueprint.SnowCollected = 0

	local Entity = PlayerComponents.PlayerComponents.playerInstanceToEntity(Player)
	Hills.Changed:Fire(Entity, "Blueprint", Hill) 
end
