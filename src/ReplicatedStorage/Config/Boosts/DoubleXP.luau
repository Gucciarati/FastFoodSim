local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Double XP"] = {
		icon           = "rbxassetid://placeholder4",
		currency       = Global.Enums.CurrencyEnums.Robux,
		lvlRequirement = 1,
		multiplier     = 2,
		boostType      = "DoubleXP",
		description    = "Earn 2x XP from all customers",
		durations      = {
			["10 Minutes"] = {
				duration = 600,
				price    = 25,
			},
			["30 Minutes"] = {
				duration = 1800,
				price    = 50,
			},
			["2 Hours"] = {
				duration = 7200,
				price    = 150,
			},
		},
	},
}
