local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Auto Collect"] = {
		icon           = "rbxassetid://placeholder13",
		currency       = Global.Enums.CurrencyEnums.Robux,
		lvlRequirement = 1,
		multiplier     = 1,
		boostType      = "AutoCollect",
		description    = "Automatically collect cash from customers",
		durations      = {
			["10 Minutes"] = {
				duration = 600,
				price    = 35,
			},
			["30 Minutes"] = {
				duration = 1800,
				price    = 70,
			},
			["2 Hours"] = {
				duration = 7200,
				price    = 200,
			},
		},
	},
}
