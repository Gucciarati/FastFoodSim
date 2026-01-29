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
	local Descendants = Model:GetDescendants()
	table.insert(Descendants, Model)
	for _, Descendant in Descendants do
		if not SavedTransparencies[Descendant] then continue end
		for Class, Properties in TransparencyProperties do
			if not Descendant:IsA(Class) then continue end
			for Property, _ in Properties do
				if not SavedTransparencies[Descendant][Property] then continue end
				Descendant[Property] = SavedTransparencies[Descendant][Property]
				SavedTransparencies[Descendant][Property] = nil
			end
		end
		SavedTransparencies[Descendant] = nil
	end
end
