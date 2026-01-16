local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils             = ReplicatedStorage:WaitForChild('Utils')
local Config            = ReplicatedStorage:WaitForChild('Config')

local CreateRegistry    = require(Utils.CreateRegistry)

local CategoriesFolder  = Config.Products

local FoodConfig        = require(CategoriesFolder.Food)
local AppliancesConfig  = require(CategoriesFolder.Appliances)
local DecorationConfig  = require(CategoriesFolder.Decoration)
local FurnitureConfig   = require(CategoriesFolder.Furniture)


local ProductRegistry = CreateRegistry.CreateDictRegistry()

local function addProductsToRegistry(products)
	for productName, productData in products do
		local displayName = productName
		
		if productData.unitSize and productData.unitSize > 1 then
			displayName = `{productData.unitSize}x {productName}`
		elseif productData.unitSize and productData.unitSize == 1 then
			displayName = `1x {productName}`
		end
		
		ProductRegistry.register(displayName, productData)
	end
end

addProductsToRegistry(FoodConfig)
addProductsToRegistry(AppliancesConfig)
addProductsToRegistry(DecorationConfig)
addProductsToRegistry(FurnitureConfig)

return ProductRegistry