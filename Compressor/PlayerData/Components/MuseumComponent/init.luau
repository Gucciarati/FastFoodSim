--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)

local GetFromPlayerHelper = require(script.GetFromPlayer)
local GetSlotHelper = require(script.GetSlot)
local IsSlotEmptyHelper = require(script.IsSlotEmpty)
local PlaceSnowmanHelper = require(script.PlaceSnowman)
local RemoveSnowmanHelper = require(script.RemoveSnowman)
local CalculateTotalIncomeHelper = require(script.CalculateTotalIncome)

local Museum = InjectLifeCycleSignal({})
Museum.Changed = Signal.new()

function Museum:add(entity, data)
	return TableValue.new(data, function(_table, key, new, old)
		if new == old then return end
		Museum.Changed:Fire(entity, key, new)
	end)
end

Museum.GetFromPlayer = GetFromPlayerHelper
Museum.GetSlot = GetSlotHelper
Museum.IsSlotEmpty = IsSlotEmptyHelper
Museum.PlaceSnowman = PlaceSnowmanHelper
Museum.RemoveSnowman = RemoveSnowmanHelper
Museum.CalculateTotalIncome = CalculateTotalIncomeHelper

return World.factory(Museum)
