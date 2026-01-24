--!strict

return function (TransparencyMap: { [BasePart]: number })
	for Part, Transparency in TransparencyMap do
		if Part:IsA("BasePart") then
			Part.Transparency = Transparency
		end
	end
	
	for Part, _ in TransparencyMap do
		if Part:IsA("BasePart") then
			for _, Descendant in Part.Parent:GetDescendants() do
				if Descendant:IsA("SurfaceGui") then
					Descendant.Enabled = true
				end
			end
		end
	end
end
