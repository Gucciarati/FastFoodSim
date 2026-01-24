--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProductsConfig = require(ReplicatedStorage.Config.ProductsConfig)

local Assets = ReplicatedStorage.Assets

return function (DeliveryList: { any })
	local GeneratedPackages = {}
	
	for _, Item in DeliveryList do
		local ItemName = Item.Name
		local IsFood = ProductsConfig.registry[ItemName].category == "Food"
		
        local PackageName = if IsFood then ItemName else "Furniture Box"
		local PackageTemplate = Assets.Products:FindFirstChild(PackageName, true)
		assert(PackageTemplate, `Couldn´t find {PackageName} in Assets`)
		
		local Package = PackageTemplate:Clone()
		Package.Name = ItemName
		
		for _, Descendant in Package:GetDescendants() do
			if not (Descendant:IsA("TextLabel") and not IsFood) then continue end
			Descendant.Text = ItemName
		end
		
		table.insert(GeneratedPackages, Package)
	end
	
	return GeneratedPackages
end
