local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Money Bag"] = {
		icon           = "rbxassetid://placeholder_moneybag",
		currency       = Global.Enums.CurrencyEnums.Robux,
		cashAmount     = 6900,
		price          = 159,
		productId      = nil, -- Set to actual DevProduct ID
		displayName    = "Money Bag",
		description    = "A large bag full of money",
		sortOrder      = 6,
	},
}
