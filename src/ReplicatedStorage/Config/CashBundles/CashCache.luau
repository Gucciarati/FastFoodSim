local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Cash Cache"] = {
		icon           = "rbxassetid://placeholder_cashcache",
		currency       = Global.Enums.CurrencyEnums.Robux,
		cashAmount     = 3750,
		price          = 99,
		productId      = nil, -- Set to actual DevProduct ID
		displayName    = "Cash Cache",
		description    = "A nice cache of cash",
		sortOrder      = 5,
	},
}
