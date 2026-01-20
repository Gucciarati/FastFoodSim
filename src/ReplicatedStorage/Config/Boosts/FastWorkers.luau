local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Fast Workers"] = {
		icon           = "rbxassetid://placeholder10",
		currency       = Global.Enums.CurrencyEnums.Robux,
		lvlRequirement = 5,
		multiplier     = 2,
		boostType      = "FastWorkers",
		description    = "Workers cook and serve 2x faster",
		durations      = {
			["10 Minutes"] = {
				duration = 600,
				price    = 30,
			},
			["30 Minutes"] = {
				duration = 1800,
				price    = 60,
			},
			["2 Hours"] = {
				duration = 7200,
				price    = 175,
			},
		},
	},
}
