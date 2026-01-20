local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils             = ReplicatedStorage:WaitForChild('Utils')
local Config            = ReplicatedStorage:WaitForChild('Config')

local CreateRegistry    = require(Utils.CreateRegistry)

local BoostsFolder      = Config.Boosts

local DoubleCash        = require(BoostsFolder.DoubleCash)
local DoubleXP          = require(BoostsFolder.DoubleXP)
local AutoCollect       = require(BoostsFolder.AutoCollect)
local Sprint            = require(BoostsFolder.Sprint)
local FastWorkers       = require(BoostsFolder.FastWorkers)
local FoodPlus          = require(BoostsFolder.FoodPlus)


local BoostRegistry = CreateRegistry.CreateDictRegistry()

local function addBoostsToRegistry(boosts)
	for boostName, boostData in boosts do
		BoostRegistry.register(boostName, boostData)
	end
end

addBoostsToRegistry(DoubleCash)
addBoostsToRegistry(DoubleXP)
addBoostsToRegistry(AutoCollect)
addBoostsToRegistry(Sprint)
addBoostsToRegistry(FastWorkers)
addBoostsToRegistry(FoodPlus)

return BoostRegistry
