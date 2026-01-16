local function CreateDictRegistry()
	local r = {}
	r.registry = {}
	
	function r.register(k, v)
		r.registry[k] = v
		return v	
	end
	
	return r
end

local function CreateArrayRegistry()
	local r = {}
	r.registry = {}

	function r.register(v)
		table.insert(r.registry, v)
		return v	
	end

	return r
end

return {
	CreateDictRegistry = CreateDictRegistry,
	CreateArrayRegistry = CreateArrayRegistry
}