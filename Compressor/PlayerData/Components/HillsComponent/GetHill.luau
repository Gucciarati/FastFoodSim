-- Direct function: (Hills, Player, HillId) -> table?
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.HillsComponent)

type HillsComponent = SharedTypes.HillsComponent

return function(Hills: HillsComponent, Player: Player, HillId: number)
	local HillsData = Hills:GetFromPlayer(Player)
	if not HillsData then return nil end

	for _, Hill in HillsData do
		if Hill.HillId == HillId then
			return Hill
		end
	end

	return nil
end
