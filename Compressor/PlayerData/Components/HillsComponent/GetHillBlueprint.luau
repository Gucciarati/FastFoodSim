-- Direct function: (Hills, Player, HillId) -> table
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.HillsComponent)

type HillsComponent = SharedTypes.HillsComponent

return function(Hills: HillsComponent, Player: Player, HillId: number)
	local Hill = Hills:GetHill(Player, HillId)
	if not Hill then return nil end

	if not Hill.Blueprint then
		Hill.Blueprint = {
			CurrentSnowmanName = nil,
			Goal = 0,
			SnowCollected = 0,
		}
	end

	return Hill.Blueprint
end
