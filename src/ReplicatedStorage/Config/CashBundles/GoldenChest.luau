local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Golden Chest"] = {
		icon           = "rbxassetid://placeholder_goldenchest",
		currency       = Global.Enums.CurrencyEnums.Robux,
		cashAmount     = 25000,
		price          = 349,
		productId      = nil, -- Set to actual DevProduct ID
		displayName    = "Golden Chest",
		description    = "A massive fortune in gold",
		sortOrder      = 7,
	},
}
