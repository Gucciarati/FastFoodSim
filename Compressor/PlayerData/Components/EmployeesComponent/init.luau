--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)

local GetFromPlayerHelper = require(script.GetFromPlayer)
local Generate = require(script.Generate)
local RemoveEmployeeHelper = require(script.RemoveEmployee)
local GetEmployeeHelper = require(script.GetEmployee)
local GetEmployeeCountHelper = require(script.GetEmployeeCount)

local Employees = InjectLifeCycleSignal({})
Employees.Changed = Signal.new()

function Employees:add(entity, data)
	return TableValue.new(data, function(_table, key, new, old)
		if new == old then return end
		Employees.Changed:Fire(entity, key, new)
	end)
end

Employees.GetFromPlayer = GetFromPlayerHelper
Employees.Generate = Generate
Employees.RemoveEmployee = RemoveEmployeeHelper
Employees.GetEmployee = GetEmployeeHelper
Employees.GetEmployeeCount = GetEmployeeCountHelper

return World.factory(Employees)
