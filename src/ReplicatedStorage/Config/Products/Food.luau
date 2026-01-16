local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global            = require(ReplicatedStorage.Global)

return {
	["Burger Buns"] = {
		icon           = "rbxassetid://98622007693535",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 1,
		price          = 11.88,
		unitPrice      = 0.99,
		unitSize       = 12,
		model          = ReplicatedStorage.Assets.Products.Food["Burger Buns"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Papers"] = {
		icon           = "rbxassetid://110835322889680",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 1,
		price          = 9.80,
		unitPrice      = 0.49,
		unitSize       = 20,
		model          = ReplicatedStorage.Assets.Products.Food["Papers"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Patties"] = {
		icon           = "rbxassetid://98807802722364",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 1,
		price          = 14.90,
		unitPrice      = 1.49,
		unitSize       = 10,
		model          = ReplicatedStorage.Assets.Products.Food["Patties"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Cheese Slices"] = {
		icon           = "rbxassetid://73315551975803",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 2,
		price          = 19.90,
		unitPrice      = 1.99,
		unitSize       = 10,
		model          = ReplicatedStorage.Assets.Products.Food["Patties"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Tomatoes"] = {
		icon           = "rbxassetid://108784082084181",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 3,
		price          = 23.66,
		unitPrice      = 1.69,
		unitSize       = 14,
		model          = ReplicatedStorage.Assets.Products.Food["Tomatoes"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Drink Cups"] = {
		icon           = "rbxassetid://91706039271454",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 6,
		price          = 29.88,
		unitPrice      = 2.49,
		unitSize       = 12,
		model          = ReplicatedStorage.Assets.Products.Food["Drink Cups"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Fry-Pack"] = {
		icon           = "rbxassetid://88246435334985",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 9,
		price          = 13.14,
		unitPrice      = 2.19,
		unitSize       = 6,
		model          = ReplicatedStorage.Assets.Products.Food["Fry-Pack"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Fry-Box"] = {
		icon           = "rbxassetid://91793353222158",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 9,
		price          = 4.9,
		unitPrice      = 0.49,
		unitSize       = 10,
		model          = ReplicatedStorage.Assets.Products.Food["Fry-Box"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Lettuce"] = {
		icon           = "rbxassetid://82262041063051",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 12,
		price          = 19.90,
		unitPrice      = 1.99,
		unitSize       = 10,
		model          = ReplicatedStorage.Assets.Products.Food["Lettuce"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Onions"] = {
		icon           = "rbxassetid://89472041836109",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 15,
		price          = 27.86,
		unitPrice      = 1.99,
		unitSize       = 14,
		model          = ReplicatedStorage.Assets.Products.Food["Lettuce"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Nugget-Pack"] = {
		icon           = "rbxassetid://109150913014344",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 18,
		price          = 31.12,
		unitPrice      = 3.89,
		unitSize       = 8,
		model          = ReplicatedStorage.Assets.Products.Food["Nugget-Pack"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Nugget-Box"] = {
		icon           = "rbxassetid://111978284825256",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 18,
		price          = 14.90,
		unitPrice      = 1.49,
		unitSize       = 10,
		model          = ReplicatedStorage.Assets.Products.Food["Nugget-Box"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Pickles"] = {
		icon           = "rbxassetid://71467554615678",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 20,
		price          = 48.86,
		unitPrice      = 3.49,
		unitSize       = 14,
		model          = ReplicatedStorage.Assets.Products.Food["Pickles"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Milkshake Cups"] = {
		icon           = "rbxassetid://94415523906475",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 24,
		price          = 65.88,
		unitPrice      = 5.49,
		unitSize       = 12,
		model          = ReplicatedStorage.Assets.Products.Food["Milkshake Cups"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Ice Cream Cones"] = {
		icon           = "rbxassetid://111082952639307",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 26,
		price          = 32.94,
		unitPrice      = 5.49,
		unitSize       = 6,
		model          = ReplicatedStorage.Assets.Products.Food["Ice Cream Cones"],
		category       = Global.Enums.ProductCategories.Food,
	},
	
	["Onion Ring Pack"] = {
		icon           = "rbxassetid://79891334140078",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 30,
		price          = 64.74,
		unitPrice      = 10.79,
		unitSize       = 6,
		model          = ReplicatedStorage.Assets.Products.Food["Onion Ring Pack"],
		category       = Global.Enums.ProductCategories.Food,
	},

	["Onion Ring Tray"] = {
		icon           = "rbxassetid://79891334140078",
		currency       = Global.Enums.CurrencyEnums.Money,
		lvlRequirement = 1,
		price          = 38.90,
		unitPrice      = 3.89,
		unitSize       = 10,
		model          = ReplicatedStorage.Assets.Products.Food["Onion Ring Tray"],
		category       = Global.Enums.ProductCategories.Food,
	},
}
