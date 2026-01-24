--!strict

return function (Packages: { Model }): { [Model]: number }
	local TransparencyMap = {}
	
	for _, Package in pairs(Packages) do
		for _, Descendant in pairs(Package:GetDescendants()) do
			if (Descendant:IsA("BasePart") or Descendant:IsA("MeshPart")) and Descendant.Transparency < 1 then
				TransparencyMap[Descendant] = Descendant.Transparency
				Descendant.Transparency = 1
			elseif Descendant:IsA("SurfaceGui") then
				Descendant.Enabled = false
			end
		end
	end
	
	return TransparencyMap
end
