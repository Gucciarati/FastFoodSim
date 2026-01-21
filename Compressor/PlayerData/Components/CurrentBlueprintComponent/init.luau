--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)

local GetFromPlayerHelper = require(script.GetFromPlayer)
local SetHelper = require(script.Set)
local ClearHelper = require(script.Clear)
local AddSnowHelper = require(script.AddSnow)

local CurrentBlueprint = InjectLifeCycleSignal({})
CurrentBlueprint.Changed = Signal.new()

function CurrentBlueprint:add(entity: number, data)
	return TableValue.new(data, function(_, _, new, old)
		if old == new then return end
		CurrentBlueprint.Changed:Fire(entity, data)
	end)
end

CurrentBlueprint.GetFromPlayer = GetFromPlayerHelper
CurrentBlueprint.Set = SetHelper
CurrentBlueprint.Clear = ClearHelper
CurrentBlueprint.AddSnow = AddSnowHelper

return World.factory(CurrentBlueprint)
