--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerComponent = require(ServerScriptService.Player.Components.PlayerComponents)

return function(Currencies: any, Player: Player)
	local Entity = PlayerComponent.playerInstanceToEntity(Player)
	return Currencies.get(Entity)
end
