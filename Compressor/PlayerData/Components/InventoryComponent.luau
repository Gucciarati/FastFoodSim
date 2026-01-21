local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)


local Inventory = {}
Inventory.Changed = Signal.new()

function Inventory:add(entity: number, data)
	return TableValue.new(data, function(_, _, _new, _old)
		Inventory.Changed:Fire(entity, data)
	end)
end

return World.factory(InjectLifeCycleSignal(Inventory))
