local module = {}

module.DailyRewards = {
	[1] = {
		Rewards = {
			{Type = "Cash", Amount = 100},
		}
	},
	[2] = {
		Rewards = {
			{Type = "XP", Amount = 100},
		}
	},
	[3] = {
		Rewards = {
			{Type = "Cash", Amount = 1000},
		}
	},
	[4] = {
		Rewards = {
			{Package = "Fryer", Category = "Appliances", Amount = 1},
		}
	},
	[5] = {
		Rewards = {
			{Type = "XP", Amount = 200},
		}
	},
	[6] = {
		Rewards = {
			{Package = "Drink Dispenser", Category = "Appliances", Amount = 1},
		}
	},
	[7] = {
		Rewards = {
			{Package = "Gold Cooktop", Category = "Appliances", Amount = 1},
		}
	},
}

return module