--!strict
local module = {}

type AttributeName = number | string | boolean | NumberRange | ColorSequence | NumberSequence | CFrame | Vector3 | Vector2 | UDim2 | UDim | Font | Rect | BrickColor | Color3

function module.requireAttribute(
	instance: Instance,
	key: string,
	defaultValueIfNotFound: AttributeName,
	forceDefaultValueIfFound: true?,
	resolveTypeMissMatch: boolean?,
	throwWarning: true?
): any
	local currentValue = instance:GetAttribute(key)
	local attributeType = typeof(currentValue)

	if currentValue == nil or forceDefaultValueIfFound then
		instance:SetAttribute(key, defaultValueIfNotFound)
		if throwWarning and not forceDefaultValueIfFound then
			warn(`{instance.Name} missing attribute "{key}", defaulting to {defaultValueIfNotFound}. Located at: {instance:GetFullName()}`)
		end
		return defaultValueIfNotFound
	end

	if resolveTypeMissMatch then
		if attributeType ~= typeof(defaultValueIfNotFound) then
			instance:SetAttribute(key, defaultValueIfNotFound)
			if throwWarning then
				warn(`Attribute type mismatch! {instance.Name} attribute "{key}" is of type {attributeType}, expected {typeof(defaultValueIfNotFound)}. Defaulting to {defaultValueIfNotFound}`)
			end
			return defaultValueIfNotFound
		end
	end

	return currentValue
end

return module
