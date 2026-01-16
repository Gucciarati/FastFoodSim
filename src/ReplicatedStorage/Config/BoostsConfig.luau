local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Double Cash"] = {
		icon           = "rbxassetid://placeholder1",
		currency       = Global.Enums.CurrencyEnums.Robux,
		lvlRequirement = 1,
		multiplier     = 2,
		boostType      = "DoubleCash",
		description    = "Earn 2x cash from all customers",
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
