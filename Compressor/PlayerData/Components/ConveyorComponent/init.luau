--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)

local GetFromPlayerHelper = require(script.GetFromPlayer)
local GetTierHelper = require(script.GetTier)
local SetTierHelper = require(script.SetTier)
local GetLuckHelper = require(script.GetLuck)
local SetLuckHelper = require(script.SetLuck)
local GetSpawnRateMultiplierHelper = require(script.GetSpawnRateMultiplier)
local SetSpawnRateMultiplierHelper = require(script.SetSpawnRateMultiplier)
local GetLifetimeMultiplierHelper = require(script.GetLifetimeMultiplier)
local SetLifetimeMultiplierHelper = require(script.SetLifetimeMultiplier)

local Conveyor = InjectLifeCycleSignal({})
Conveyor.Changed = Signal.new()

function Conveyor:add(entity, data)
	return TableValue.new(data, function(_table, key, new, old)
		if new == old then return end
		Conveyor.Changed:Fire(entity, key, new)
	end)
end

Conveyor.GetFromPlayer = GetFromPlayerHelper
Conveyor.GetTier = GetTierHelper
Conveyor.SetTier = SetTierHelper
Conveyor.GetLuck = GetLuckHelper
Conveyor.SetLuck = SetLuckHelper
Conveyor.GetSpawnRateMultiplier = GetSpawnRateMultiplierHelper
Conveyor.SetSpawnRateMultiplier = SetSpawnRateMultiplierHelper
Conveyor.GetLifetimeMultiplier = GetLifetimeMultiplierHelper
Conveyor.SetLifetimeMultiplier = SetLifetimeMultiplierHelper

return World.factory(Conveyor)
