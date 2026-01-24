--!strict


local SavedProperties: { [Instance]: { [string]: any } } = {}

local TRANSPARENCY_PROPERTIES: { [string]: { [string]: any } } = {
	TextButton = { TextTransparency = 1, TextStrokeTransparency = 1 },
	TextLabel = { TextTransparency = 1, TextStrokeTransparency = 1 },
	TextBox = { TextTransparency = 1, TextStrokeTransparency = 1 },
	ScrollingFrame = { ScrollBarImageTransparency = 1 },
	GuiObject = { BackgroundTransparency = 1 },
	ImageButton = { ImageTransparency = 1 },
	ImageLabel = { ImageTransparency = 1 },
	UIStroke = { Transparency = 1 },

	ProximityPrompt = { Enabled = false },
	ForceField = { Visible = false },
	BasePart = {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
		Material = Enum.Material.SmoothPlastic,
	},
	Texture = { Transparency = 1 },
	Decal = { Transparency = 1 },

	ParticleEmitter = { Transparency = NumberSequence.new(1) },
	Trail = { Transparency = NumberSequence.new(1) },
	Beam = { Enabled = false },
}

local Visibility = {}

function Visibility.Hide(Model: Instance)
	if not Model then return end

	local Descendants = Model:GetDescendants()
	table.insert(Descendants, Model)

	for _, Descendant in Descendants do
		if not SavedProperties[Descendant] then
			SavedProperties[Descendant] = {}
		end

		for ClassName, Properties in TRANSPARENCY_PROPERTIES do
			if not Descendant:IsA(ClassName) then continue end

			for Property, HiddenValue in Properties do
				if SavedProperties[Descendant][Property] then continue end

				SavedProperties[Descendant][Property] = (Descendant :: any)[Property]
				;(Descendant :: any)[Property] = HiddenValue
			end
		end
	end
end

function Visibility.Show(Model: Instance)
	if not Model then return end

	local Descendants = Model:GetDescendants()
	table.insert(Descendants, Model)

	for _, Descendant in Descendants do
		if not SavedProperties[Descendant] then continue end

		for ClassName, Properties in TRANSPARENCY_PROPERTIES do
			if not Descendant:IsA(ClassName) then continue end

			for Property, _ in Properties do
				if not SavedProperties[Descendant][Property] then continue end

				;(Descendant :: any)[Property] = SavedProperties[Descendant][Property]
				SavedProperties[Descendant][Property] = nil
			end
		end

		SavedProperties[Descendant] = nil
	end
end

function Visibility.HideChildren(Parent: Instance)
	for _, Child in Parent:GetChildren() do
		Visibility.Hide(Child)
	end
end

function Visibility.ShowChildren(Parent: Instance)
	for _, Child in Parent:GetChildren() do
		Visibility.Show(Child)
	end
end

return Visibility
