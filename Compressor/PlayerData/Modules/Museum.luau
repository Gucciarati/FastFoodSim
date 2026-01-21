local ServerScriptService = game:GetService("ServerScriptService")
local DataRegistry = require(ServerScriptService.PlayerData.Interfaces.DataRegistry)

return DataRegistry.register("Museum", {
	Slots = {},
	MaxSlots = 5,
	IncomeMultiplier = 1.0,
	TotalIncomeGenerated = 0,
})
