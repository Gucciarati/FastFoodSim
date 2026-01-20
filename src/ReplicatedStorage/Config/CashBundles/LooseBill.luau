local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Loose Bill"] = {
		icon           = "rbxassetid://placeholder_loosebill",
		currency       = Global.Enums.CurrencyEnums.Robux,
		cashAmount     = 100,
		price          = 9,
		productId      = nil, -- Set to actual DevProduct ID
		displayName    = "Loose Bill",
		description    = "A small boost to get started",
		sortOrder      = 1,
	},
}
