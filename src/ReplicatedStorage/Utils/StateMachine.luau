--!strict
local Vendor = require(game.ReplicatedFirst.Vendor)
local LemonSignal = require(game.ReplicatedFirst.Vendor.LemonSignal)
local StateMachine = {}


type BindableType<A...> = {
	Connect: (self: BindableType<A...>, fn: (A...) -> ()) -> RBXScriptConnection,
}
export type Fsm<C, V> = {
	context: C,
	bin: {[any]: any},
	changed: LemonSignal.Signal<any, V, V>,
	enterState: (state: V) -> (),
	getCurrentState: () -> V,
	destroy: () -> (),
}

export type StateFn<C, V> = (self: Fsm<C, V>, previousState: V) -> ()


export type ValueObject = BoolValue
| IntValue
| NumberValue
| StringValue
| ObjectValue
| BrickColorValue
| Color3Value
| CFrameValue
| Vector3Value

function StateMachine.wrapValue<C, V>(
	value: ValueObject,
	context: C,
	states: {[V]: StateFn<C, V>},
	enterStateNow: true?
): Fsm<C, V>

	local bin: {[any]: any} = {}
	local self = {
		context = context,
		bin = Vendor.connectUtil.nest(bin),
		changed = LemonSignal.new()
	} :: Fsm<C, V>

	local function getState(name: V): StateFn<C, V>?
		return states[name] --or error(`State "{name}" does not exist`)
	end

	table.insert(bin, Vendor.connectUtil.valueChanged(value, function(current, previous)
		if bin.task then
			task.cancel(bin.task :: thread)
		end
		Vendor.connectUtil.clean(self.bin)
		local state = getState(current)
		if state then
			self.changed:Fire(self, current, previous)
			bin.task = task.defer(function()
				state(self, previous)
			end)
		end
	end, not enterStateNow)) --> skip initialization

	function self.enterState(state: V)
		value.Value = state
	end		

	function self.destroy()
		Vendor.connectUtil.empty(bin)
	end


	function self.getCurrentState()
		return value.Value
	end

	value.Destroying:Connect(function()
		self.destroy()
	end)

	return self
end 

function StateMachine.wrapAttribute<C, V>(
	source: Instance, 
	attribute: string,
	context: C, 
	states:{[V]: StateFn<C, V>},
	enterStateNow: true?
): Fsm<C, V>
	local bin: {[any]: any} = {}

	local self = {
		context = context,
		bin = Vendor.connectUtil.nest(bin),
		changed = LemonSignal.new()
	} :: Fsm<C, V>

	local function getState(name: V): StateFn<C, V>?
		return states[name] --or error(`State "{name}" does not exist {source}`, 2)
	end

	table.insert(bin, Vendor.connectUtil.attributeChanged(source, attribute, function(current, previous)
		if bin.task then
			task.cancel(bin.task :: thread)
		end

		Vendor.connectUtil.clean(self.bin)
		local state = getState(current)
		if state then
			self.changed:Fire(self, current, previous)
			bin.task = task.defer(function()
				state(self, previous)
			end)
		end
	end, not enterStateNow)) --> skip initialization

	function self.enterState(state: V)
		source:SetAttribute(attribute, state)
	end		

	function self.destroy()
		Vendor.connectUtil.empty(bin)
	end

	function self.getCurrentState()
		return source:GetAttribute(attribute)
	end

	source.Destroying:Connect(function()
		self.destroy()
	end)	

	return self
end


return StateMachine