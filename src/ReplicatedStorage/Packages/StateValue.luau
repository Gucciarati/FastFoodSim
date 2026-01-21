--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Signal = require(ReplicatedFirst.Vendor.LemonSignal)

local StateValue = {}
local Registry: { [string]: { Value: any, Changed: any } } = {}

function StateValue.Create<T>(StateKey: string, InitialValue: T): T
	local AlreadyExists = Registry[StateKey] ~= nil
	assert(not AlreadyExists, `StateValue "{StateKey}" already exists`)
	
	Registry[StateKey] = {
		Value = InitialValue,
		Changed = Signal.new(),
	}
	
	return InitialValue
end

function StateValue.Get(StateKey: string): { Value: any, Changed: any }
	local StateObject = Registry[StateKey]
	assert(StateObject, `StateValue "{StateKey}" does not exist. Create it first with StateValue.Create()`)
	return StateObject
end

function StateValue.Set(StateKey: string, NewValue: any): nil
	local StateObject = StateValue.Get(StateKey)
	
	local IsValueDifferent = StateObject.Value ~= NewValue
	if not IsValueDifferent then return nil end
	
	StateObject.Value = NewValue
	StateObject.Changed:Fire(NewValue)
	
	return nil
end

function StateValue.Peek(StateKey: string): any
	return StateValue.Get(StateKey).Value
end

function StateValue.GetAll(): { [string]: { Value: any, Changed: any } }
	return Registry
end

return StateValue
