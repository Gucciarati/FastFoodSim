local ServerScriptService = game:GetService("ServerScriptService")
local DataRegistry = require(ServerScriptService.PlayerData.Interfaces.DataRegistry)

return DataRegistry.register("Stats", {
	Luck = 1,
	Levels = {
		BlueprintGacha = 1,
		EmployeeConveyor = 1,
	},
})
