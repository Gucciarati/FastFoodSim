--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FurnitureComponent = require(script.Parent.Components.FurnitureComponent)
local InventoryComponent = require(script.Parent.Components.InventoryComponent)

local DefaultFurnitureService = {}

local DEFAULT_FURNITURE: {[string]: any} = {
	Chair = {
		Item = "Basic Chair",
		Type = "Furniture",
		CF = CFrame.new(-38.5, 1, 27.9999695),
	},
	Cooktop = {
		Item = "Cooktop",
		Type = "Appliances",
		CF = CFrame.new(-38.5, 1, -7) * CFrame.Angles(0, math.pi / 2, 0),
	},
	Counter = {
		Item = "Table",
		Type = "Appliances",
		CF = CFrame.new(-38.5, 1, 1) * CFrame.Angles(0, math.pi, 0),
	},
	Register = {
		Item = "Register",
		Type = "Appliances",
		CF = CFrame.new(-28.5, 1, 6.99996948),
	},
	Table = {
		Item = "Dirty Table",
		Type = "Furniture",
		CF = CFrame.new(-38.5, 1, 23.9999695) * CFrame.Angles(0, math.pi / 2, 0),
	},
	Light1 = {
		Item = "Rectangle Light",
		Type = "Decoration",
		CF = CFrame.new(-11.5, 1.00000012, -14),
	},
	Light2 = {
		Item = "Rectangle Light",
		Type = "Decoration",
		CF = CFrame.new(-10.5, 1.00000012, 30),
	},
}

function DefaultFurnitureService.InjectDefaults(Player: Player, PlayerData: any): boolean
	if not PlayerData then return false end
	
	local HasFurniture = PlayerData.Furniture and next(PlayerData.Furniture) ~= nil
	--if HasFurniture then return false end
	
	for furnitureId, TemplateData in DEFAULT_FURNITURE do
        local FurnitureData = InventoryComponent.Add(
            PlayerData,
            {
                Name = TemplateData.Item,
                Cframe = TemplateData.CF,
                Id = furnitureId,
                Packed = false,
            }
        )
	    FurnitureComponent.Place(Player, FurnitureData)
	end
	
	return true
end

return DefaultFurnitureService
