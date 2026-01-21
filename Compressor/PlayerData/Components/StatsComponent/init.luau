--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)

local GetFromPlayerHelper = require(script.GetFromPlayer)
local GetStatHelper = require(script.GetStat)
local SetStatHelper = require(script.SetStat)

local Stats = InjectLifeCycleSignal({})
Stats.Changed = Signal.new()

function Stats:add(Entity, Data)
	return TableValue.new(Data, function(_Table, Key, New, Old)
		if New == Old then return end
		Stats.Changed:Fire(Entity, Key, New)
	end)
end

Stats.GetFromPlayer = GetFromPlayerHelper
Stats.GetStat = GetStatHelper
Stats.SetStat = SetStatHelper

return World.factory(Stats)
