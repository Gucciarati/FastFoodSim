local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Sprint"] = {
		icon           = "rbxassetid://placeholder7",
		currency       = Global.Enums.CurrencyEnums.Robux,
		lvlRequirement = 1,
		multiplier     = 1.5,
		boostType      = "Sprint",
		description    = "Run 50% faster",
		durations      = {
			["10 Minutes"] = {
				duration = 600,
				price    = 20,
			},
			["30 Minutes"] = {
				duration = 1800,
				price    = 40,
			},
			["2 Hours"] = {
				duration = 7200,
				price    = 100,
			},
		},
	},
}
