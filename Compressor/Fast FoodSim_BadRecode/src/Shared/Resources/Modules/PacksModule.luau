--[[
    Packs Module
    ----------------
    Contains configuration and data for all Packs in the game.
    Each Pack can define its delay, duration, availability period, 
    and rewards for the player upon purchase.

    Created by: Guinogue — Modified on October 24, 2025
]]

-----< Module Setup >

local PacksModule = {}

-----< Example Pack Configuration >

PacksModule["StarterPack"] = {
	Delay = 0, -- Time (in seconds) before player can buy it
	Duration = nil, -- Expiration time since FirstJoin (if any)
	Start = nil, -- Optional start time (Unix)
	End = nil, -- Optional end time (Unix)
	Purchases = 1, -- Limit number of purchases
	Rewards = {
		Coins = 500,
		Gems = 50,
	},
}

PacksModule["VIPPack"] = {
	Delay = 3600, -- Available after 1 hour
	Duration = 86400 * 7, -- 7 days availability
	Purchases = 3,
	Rewards = {
		Coins = 2000,
		Gems = 200,
	},
}

-----< Return Module >

return PacksModule
