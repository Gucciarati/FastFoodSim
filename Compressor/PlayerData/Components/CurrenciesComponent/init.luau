--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)

local GetFromPlayerHelper = require(script.GetFromPlayer)
local GetCurrencyHelper = require(script.GetCurrency)
local IncrementCurrencyHelper = require(script.IncrementCurrency)
local SetCurrencyHelper = require(script.SetCurrency)

local Currencies = InjectLifeCycleSignal({})
Currencies.Changed = Signal.new()

function Currencies:add(Entity, Data)
	return TableValue.new(Data, function(_Table, Key, New, Old)
		if New == Old then return end
		Currencies.Changed:Fire(Entity, Key, New)
	end)
end

Currencies.GetFromPlayer = GetFromPlayerHelper
Currencies.GetCurrency = GetCurrencyHelper
Currencies.IncrementCurrency = IncrementCurrencyHelper
Currencies.SetCurrency = SetCurrencyHelper

return World.factory(Currencies)
