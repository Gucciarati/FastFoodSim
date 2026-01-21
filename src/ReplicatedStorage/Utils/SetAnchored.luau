
return function(Model: any, State: boolean)
	if Model:IsA("BasePart") then
		Model.Anchored = State
		return
	end
	
	for _, Descendant in Model:GetDescendants() do
		if not Descendant:IsA("BasePart") then continue end
		Descendant.Anchored = State
	end
end