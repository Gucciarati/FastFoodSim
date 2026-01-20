local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Bank Vault"] = {
		icon           = "rbxassetid://placeholder_bankvault",
		currency       = Global.Enums.CurrencyEnums.Robux,
		cashAmount     = 50000,
		price          = 599,
		productId      = nil, -- Set to actual DevProduct ID
		displayName    = "Bank Vault",
		description    = "The ultimate cash bundle",
		sortOrder      = 8,
	},
}
