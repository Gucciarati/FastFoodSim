--!strict
local ReplicatedFirst = game:GetService('ReplicatedFirst')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Utils            = ReplicatedStorage:WaitForChild('Utils')
local Vendor           = ReplicatedFirst.Vendor
local RequireAttribute = require(Utils.RequireAttribute)



export type PlayerProfile = {
	XP       : number,
	Tutorial : number,
	Cash     : number,
	-- these sub tables may be ported to a specialized module...
	TemporaryGamePasses : {
		AutoCollect : number,
		DoubleCash  : number,
		DoubleXP    : number,
		FastWorkers : number,
		FoodPlus    : number,
		Sprint      : number,
	}	
}

local module = {
	Attributes = {
		XP       = "XP",
		Tutorial = "Tutorial",
		Cash     = "Cash",
		-- temporary gamepasses
		AutoCollect = "AutoCollect",
		DoubleCash  = "DoubleCash",
		DoubleXP    = "DoubleXP",
		FastWorkers = "FastWorkers",
		FoodPlus    = "FoodPlus",
		Sprint      = "Sprint",
	}
}

-- TODO: add a second argument to pass the data of the player from the database
function module.setPlayerProfile(player:Player) : PlayerProfile
	local playerProfile = {
		XP   = RequireAttribute.requireAttribute(player, module.Attributes.XP, 0),
		Cash = RequireAttribute.requireAttribute(player, module.Attributes.Cash, 200),
		Tutorial = RequireAttribute.requireAttribute(player, module.Attributes.Tutorial, 1),
		BoughtStarterPack = false, -- One time purchase
		
		TemporaryGamePasses = {
			AutoCollect = RequireAttribute.requireAttribute(player, module.Attributes.AutoCollect, false),
			DoubleCash = RequireAttribute.requireAttribute(player, module.Attributes.DoubleCash, false),
			DoubleXP = RequireAttribute.requireAttribute(player, module.Attributes.DoubleXP, false),
			FastWorkers = RequireAttribute.requireAttribute(player, module.Attributes.FastWorkers, false),
			FoodPlus = RequireAttribute.requireAttribute(player, module.Attributes.FoodPlus, false),
			Sprint = RequireAttribute.requireAttribute(player, module.Attributes.Sprint, false),
		}
	} :: PlayerProfile
	return playerProfile
end

return module
