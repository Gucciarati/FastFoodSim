local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Money Stash"] = {
		icon           = "rbxassetid://placeholder_moneystash",
		currency       = Global.Enums.CurrencyEnums.Robux,
		cashAmount     = 1250,
		price          = 39,
		productId      = nil, -- Set to actual DevProduct ID
		displayName    = "Money Stash",
		description    = "A decent stash of money",
		sortOrder      = 3,
	},
}
