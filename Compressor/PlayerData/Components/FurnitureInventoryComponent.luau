local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)


local FurnitureInventory = {}
FurnitureInventory.Changed = Signal.new()

function FurnitureInventory:add(entity: number, data)
	return TableValue.new(data, function(_, _, new, old)
		FurnitureInventory.Changed:Fire(entity, data)
	end)
end

return World.factory(InjectLifeCycleSignal(FurnitureInventory))
