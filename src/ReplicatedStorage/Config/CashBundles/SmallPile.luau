local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Small Pile"] = {
		icon           = "rbxassetid://placeholder_smallpile",
		currency       = Global.Enums.CurrencyEnums.Robux,
		cashAmount     = 250,
		price          = 19,
		productId      = nil, -- Set to actual DevProduct ID
		displayName    = "Small Pile",
		description    = "A small pile of cash",
		sortOrder      = 2,
	},
}
