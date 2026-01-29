local GetFoodModelFromId = require(script.Parent.GetFoodModelFromId)

return function(FoodId: string)
	local FoodModel = GetFoodModelFromId(FoodId)
	if not FoodModel then return nil end
	
	local Parent = FoodModel.Parent
	if Parent and Parent:HasTag("Snap") then
		return Parent
	end
	return nil
end
