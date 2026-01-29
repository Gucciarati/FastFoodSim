local SavedTransparencies = require(script.Parent.SavedTransparencies)

local TransparencyProperties = {
	["BasePart"] = {["Transparency"] = 1},
	["Decal"] = {["Transparency"] = 1},
	["Texture"] = {["Transparency"] = 1},
	["SurfaceGui"] = {["Enabled"] = false},
	["BillboardGui"] = {["Enabled"] = false},
	["Light"] = {["Enabled"] = false},
	["Fire"] = {["Enabled"] = false},
	["Smoke"] = {["Enabled"] = false},
	["Sparkles"] = {["Enabled"] = false},
	["ParticleEmitter"] = {["Transparency"] = NumberSequence.new(1)},
	["Trail"] = {["Transparency"] = NumberSequence.new(1)},
	["Beam"] = {["Enabled"] = false},
}

return function(Model: Instance)
	if not Model then return end
	local Descendants = Model:GetDescendants()
	table.insert(Descendants, Model)
	for _, Descendant in Descendants do
		if not SavedTransparencies[Descendant] then
			SavedTransparencies[Descendant] = {}
		end
		for Class, Properties in TransparencyProperties do
			if not Descendant:IsA(Class) then continue end
			for Property, Value in Properties do
				if SavedTransparencies[Descendant][Property] then continue end
				SavedTransparencies[Descendant][Property] = Descendant[Property]
				Descendant[Property] = Value
			end
		end
	end
end
