local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)

local Money = {}
Money.Changed = Signal.new()

function Money:add(entity, value)
	-- Update the Money Component
	-- Register it under the player component
	return TableValue.new(value, function(_, _, new, old)
		-- Changed
		if new == old then return end
		Money.Changed:Fire(entity, value)
	end)
end

return World.factory(Money)
