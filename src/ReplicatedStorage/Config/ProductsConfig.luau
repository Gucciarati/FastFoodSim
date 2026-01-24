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
		productData.name = productName
		ProductRegistry.register(productName, productData)
	end
end

addProductsToRegistry(FoodConfig)
addProductsToRegistry(AppliancesConfig)
addProductsToRegistry(DecorationConfig)
addProductsToRegistry(FurnitureConfig)

return ProductRegistry