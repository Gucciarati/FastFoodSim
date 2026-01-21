
return function(Model: any, State: boolean)
	for _, Descendant in Model:GetDescendants() do
		if not Descendant:IsA("BasePart") then continue end
		Descendant.CanCollide = State
	end
end