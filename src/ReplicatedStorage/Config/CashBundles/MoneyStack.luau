local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Money Stack"] = {
		icon           = "rbxassetid://placeholder_moneystack",
		currency       = Global.Enums.CurrencyEnums.Robux,
		cashAmount     = 2500,
		price          = 79,
		productId      = nil, -- Set to actual DevProduct ID
		displayName    = "Money Stack",
		description    = "A solid stack of cash",
		sortOrder      = 4,
	},
}
