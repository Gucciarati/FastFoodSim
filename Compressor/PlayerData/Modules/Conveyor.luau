local ServerScriptService = game:GetService("ServerScriptService")
local DataRegistry = require(ServerScriptService.PlayerData.Interfaces.DataRegistry)

return DataRegistry.register("Conveyor", {
	Luck = 1,
	Tier = 1,
	SpawnRateMultiplier = 1,
	LifetimeMultiplier = 1,
})
