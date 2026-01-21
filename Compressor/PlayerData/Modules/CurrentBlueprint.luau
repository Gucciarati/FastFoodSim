local ServerScriptService = game:GetService("ServerScriptService")
local DataRegistry = require(ServerScriptService.PlayerData.Interfaces.DataRegistry)


return DataRegistry.register("CurrentBlueprint", { Id = 1 })
