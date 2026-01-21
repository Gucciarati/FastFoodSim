local ServerScriptService = game:GetService("ServerScriptService")
local DataRegistry = require(ServerScriptService.PlayerData.Interfaces.DataRegistry)

-- Tutorial data template: track current stage and completion flags
-- stage: numeric progression marker
-- flags: dictionary for optional granular achievements
return DataRegistry.register("Tutorial", {
	Stage = 0, -- 0 = not started, 1 = buy 5 brainrots, 2 = destroy structure, 3 = place artifact, 4 = finished
	Active = false,
	PurchasedCount = 0,
	HitCount = 0,
	ArtifactPlaced = false,
})
