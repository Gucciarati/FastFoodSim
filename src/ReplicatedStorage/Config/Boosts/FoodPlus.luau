local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Food Plus"] = {
		icon           = "rbxassetid://placeholder16",
		currency       = Global.Enums.CurrencyEnums.Robux,
		lvlRequirement = 10,
		multiplier     = 1.5,
		boostType      = "FoodPlus",
		description    = "Customers order 50% more food items",
		durations      = {
			["10 Minutes"] = {
				duration = 600,
				price    = 40,
			},
			["30 Minutes"] = {
				duration = 1800,
				price    = 80,
			},
			["2 Hours"] = {
				duration = 7200,
				price    = 225,
			},
		},
	},
}
