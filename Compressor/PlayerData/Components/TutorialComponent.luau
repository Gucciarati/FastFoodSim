local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)

local Tutorial = {}
Tutorial.Changed = Signal.new()

function Tutorial:add(entity: number, data)
	return TableValue.new(data, function(_, _, _new, _old)
		Tutorial.Changed:Fire(entity, data)
	end)
end

return World.factory(InjectLifeCycleSignal(Tutorial))
