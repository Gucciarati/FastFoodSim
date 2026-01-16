export type Observable<T> = {
	Value: T,
	Changed: (new: any, old: any) -> (),
	FireIfSameValue: boolean
}

-- works identically to an observable
local observable = {}

local function nop(key: any, new: any, old: any) end

local meta = {}

function meta.__newindex(t, k, v)
	local self = rawget(t, "_self")
	if k == 'Changed' then
		self.Changed = v
	else
		local old = self.Value
		if old == v and not self.FireIfSameValue then
			return
		end
		self.Value = v
		self.Changed(v, old)		
	end
end

function meta.__index(t, k)
	local self = rawget(t, "_self")
	return self[k]
end

function meta.__tostring(t:  {_store: Observable})
	local self = rawget(t, "_self")
	local msg = "Value: " .. tostring(self.Value) 
	return msg
end

function meta.__call(t, v)
	local self = rawget(t, "_self")
	self.Value = v
end


function observable.new<T>(value: T, changed: (new: any, old: any?) -> ()?, skip: true?): Observable
	local self = {} :: T & { Value: T, Changed: typeof(nop) }
	self.Value = value
	self.Changed = changed or nop
	self.FireIfSameValue = false

	if not skip then
		self.Changed(value)
	end
	return setmetatable({_self = self}, meta)
end

return observable
