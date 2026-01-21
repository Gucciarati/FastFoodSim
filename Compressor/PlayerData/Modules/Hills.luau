local ServerScriptService = game:GetService("ServerScriptService")
local DataRegistry = require(ServerScriptService.PlayerData.Interfaces.DataRegistry)

return DataRegistry.register("Hills", {
	{
		HillId = 1,
		Level = 1,
		Lanes = {
			{
				LaneId = 1,
				EmployeeId = nil,
				IsOccupied = false,
				Multipliers = {
					Speed = 1,
					Snow = 1,
				},
			},
		},
	
	},
})
