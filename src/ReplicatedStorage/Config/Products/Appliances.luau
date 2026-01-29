local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Cooktop"] = {
		icon           = "rbxassetid://127391397037625",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 30,
		price          = 89.59,
		unitPrice      = 89.59,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Cooktop"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Shelf"] = {
		icon           = "rbxassetid://102091454529584",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 1,
		price          = 78.29,
		unitPrice      = 78.29,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Shelf"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Fridge"] = {
		icon           = "rbxassetid://114093024168225",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 1,
		price          = 147.99,
		unitPrice      = 147.99,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Fridge"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Table"] = {
		icon           = "rbxassetid://73759223211872",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 1,
		price          = 65.48,
		unitPrice      = 65.48,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Furniture["Table"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Trashbin"] = {
		icon           = "rbxassetid://122524814491883",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 1,
		price          = 79.98,
		unitPrice      = 79.98,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Trashbin"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Gold Cooktop"] = {
		icon           = "rbxassetid://112935640057306",
		currency       = Global.Enums.CurrencyEnums.Robux,
		lvlRequirement = 1,
		price          = 0,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Gold Cooktop"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Gold Fryer"] = {
		icon           = "rbxassetid://102496397422915",
		currency       = Global.Enums.CurrencyEnums.Robux,
		lvlRequirement = 1,
		price          = 0,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Gold Fryer"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Counter"] = {
		icon           = "rbxassetid://126357665437065",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 2,
		price          = 124.89,
		unitPrice      = 124.89,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Counter"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Order Screen"] = {
		icon           = "rbxassetid://96847452412180",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 3,
		price          = 159.99,
		unitPrice      = 159.99,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Order Screen"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Register"] = {
		icon           = "rbxassetid://107749202914590",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 6,
		price          = 219.79,
		unitPrice      = 219.79,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Register"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Drink Dispenser"] = {
		icon           = "rbxassetid://118285890779171",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 6,
		price          = 119.39,
		unitPrice      = 119.39,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Drink Dispenser"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Fryer"] = {
		icon           = "rbxassetid://125770077270823",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 1,
		price          = 249.79,
		unitPrice      = 249.79,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Fryer"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Food Warmer"] = {
		icon           = "rbxassetid://93246964345628",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 15,
		price          = 99.99,
		unitPrice      = 99.99,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Food Warmer"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
	
	["Icecream & Milkshake Maker"] = {
		icon           = "rbxassetid://103921609235459",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 24,
		price          = 499.59,
		unitPrice      = 499.59,
		unitSize       = 1,
		model          = ReplicatedStorage.Assets.Products.Appliances["Icecream & Milkshake Maker"],
		category       = Global.Enums.ProductCategories.Appliances,
	},
}
