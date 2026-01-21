-- Direct function: (Hills, Player, HillId, Amount)
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.HillsComponent)

type HillsComponent = SharedTypes.HillsComponent

return function(Hills: HillsComponent, Player: Player, HillId: number, Amount: number)
	local Hill = Hills:GetHill(Player, HillId)
	if not Hill or not Hill.Blueprint then return end
	if not Hill.Blueprint.CurrentSnowmanName then return end

	local Sum = Hill.Blueprint.SnowCollected + Amount
	local CappedSum = math.min(Sum, Hill.Blueprint.Goal)

	Hill.Blueprint.SnowCollected = math.max(CappedSum, 0)
end
