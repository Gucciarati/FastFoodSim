--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)

local GetFromPlayerHelper = require(script.GetFromPlayer)
local GetHillHelper = require(script.GetHill)
local AddSnowToHillHelper = require(script.AddSnowToHill)
local SetHillBlueprintHelper = require(script.SetHillBlueprint)
local GetHillBlueprintHelper = require(script.GetHillBlueprint)
local BuyNewHillHelper = require(script.BuyNewHill)
local UpgradeHillHelper = require(script.UpgradeHill)
local AssignEmployeeToLaneHelper = require(script.AssignEmployeeToLane)
local AddLaneToHillHelper = require(script.AddLaneToHill)


local Hills = InjectLifeCycleSignal({})
Hills.Changed = Signal.new()

function Hills:add(entity, data)
	return TableValue.new(data, function(_table, key, new, old)
		if new == old then return end
		Hills.Changed:Fire(entity, key, new)
	end)
end

Hills.GetFromPlayer = GetFromPlayerHelper
Hills.GetHill = GetHillHelper
Hills.AddSnowToHill = AddSnowToHillHelper
Hills.SetHillBlueprint = SetHillBlueprintHelper
Hills.GetHillBlueprint = GetHillBlueprintHelper
Hills.BuyNewHill = BuyNewHillHelper
Hills.UpgradeHill = UpgradeHillHelper
Hills.AssignEmployeeToLane = AssignEmployeeToLaneHelper
Hills.AddLaneToHill = AddLaneToHillHelper

return World.factory(Hills)
