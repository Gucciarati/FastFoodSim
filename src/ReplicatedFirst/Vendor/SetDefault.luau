local function setDefaultAttribute(instance: Instance, key: string, default: any, forceDefaultValue: boolean?): any
	local current = instance:GetAttribute(key)
	-- override or initialize
	if current == nil or forceDefaultValue then
		instance:SetAttribute(key, default)
		if current == nil and not forceDefaultValue then
			--warn(`{instance.Name} missing attribute "{key}", defaulting to {default}. Located at: {instance:GetFullName()}`)
		end
		return default
	end

	return current
end


return {
	attribute = setDefaultAttribute,
}