--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProductsConfig = require(ReplicatedStorage.Config.ProductsConfig)

export type InteractableStats = {
	Type: string,
	Name: string,
	Left: number?,
	Total: number?,
}

local GRILLABLE_FOODS = {
	["Patty"] = true,
	["Raw Patty"] = true,
}

local LID_CUP_FOODS = {
	["Empty Soda"] = true,
	["Milkshake Cup"] = true,
}

local function GetInteractableStats(Interactable: Instance, Target: any): InteractableStats
	if not Interactable then
		return { Type = "Generic", Name = "Unknown" }
	end
	
	local Name = Interactable.Name
	local Amount = Interactable:GetAttribute("Amount") :: number?
	local ItemName = Interactable:GetAttribute("ItemName") :: string?
	local EndTime = Interactable:GetAttribute("EndTime") :: number?
	
	if Interactable:HasTag("Snap") then
		return { Type = "Cooktop", Name = Name }
	end

	if Interactable.Name == "Furniture Box" then
		local DisplayName = ItemName or "Furniture"
		return {
			Type = "Furniture Package",
			Name = DisplayName,
			Left = 1,
			Total = 1,
		}
	end
	
	if Amount ~= nil then
		local ProductConfig = ProductsConfig.registry[Name]
		local Total = ProductConfig and ProductConfig.unitSize or Amount
		
		return {
			Type = "Food Package",
			Name = Name,
			Left = Amount,
			Total = Total,
		}
	end
	
	if EndTime then
		if GRILLABLE_FOODS[Name] then
			return { Type = "Grillable", Name = Name }
		end
		
		if LID_CUP_FOODS[Name] then
			return { Type = "Lid Cup", Name = Name }
		end
	end
	
	local IsPlacedFurniture = Interactable:FindFirstAncestor("Furniture") ~= nil
	if IsPlacedFurniture and Amount == nil then
		local HasMovementTag = Interactable:HasTag("Movement")
		if HasMovementTag then
			return { Type = "Openable", Name = Name }
		end
		
		return { Type = "Placed Furniture", Name = Name }
	end
	
	if Name == "Dirty Tray" or Interactable:HasTag("DirtyTray") then
		return { Type = "Dirty Tray", Name = "Dirty Tray" }
	end
	
	return { Type = "Generic", Name = Name }
end

return GetInteractableStats
