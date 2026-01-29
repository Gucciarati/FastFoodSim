--!strict

return {
	["Generic"] = {
		{ Bind = "Primary", Action = "Grab" },
	},

	["Cooktop"] = {
		{ Bind = "Primary", Action = "Grill" },
	},

	["Openable"] = {
		{ Bind = "Primary", Action = "Open" },
	},

	["Furniture Package"] = {
		{ Bind = "Primary", Action = "Pick Up" },
		{ Bind = "Secondary", Action = "Take 1x" },
		{ Bind = "Tertiary", Action = "Sell" },
	},

	["Food Package"] = {
		{ Bind = "Primary", Action = "Pick Up" },
		{ Bind = "Secondary", Action = "Take" },
	},

	["Placed Furniture"] = {
		{ Bind = "Secondary", Action = "Move" },
		{ Bind = "Tertiary", Action = "Sell" },
	},

	["Dirty Tray"] = {
		{ Bind = "Secondary", Action = "Collect" },
	},

	["Grillable"] = {
		{ Bind = "Primary", Action = "Flip" },
	},

	["Lid Cup"] = {
		{ Bind = "Primary", Action = "Add Lid" },
	},
}
