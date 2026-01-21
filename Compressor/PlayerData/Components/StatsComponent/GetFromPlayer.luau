--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerComponents = require(ServerScriptService.Player.Components.PlayerComponents)

return function(Stats, Player: Player)
	local Entity = PlayerComponents.playerInstanceToEntity(Player)

	return Stats.get(Entity) or {
		Luck = 1,
		Levels = {
			BlueprintGacha = 1,
			EmployeeConveyor = 1,
		},
	}
end
