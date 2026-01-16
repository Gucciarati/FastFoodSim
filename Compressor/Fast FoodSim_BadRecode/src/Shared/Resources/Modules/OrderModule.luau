local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local APIs = ReplicatedStorage.APIs
local GameplayAPI = require(APIs.gameplay)
local Handler = require(APIs.handler)

local Assets = ReplicatedStorage.Assets

local Order = {}

local OrderSample = Handler.sample(Assets.NPCOrder.Container.Requirements.Sample)
local IngredientSample = Handler.sample(OrderSample.Ingredients.Sample)
local OrderScreenSample = Handler.sample(Assets.CustomerOrder.Order.Sample)
local IngredientScreenSample = Handler.sample(OrderScreenSample.Ingredients.Sample)

local function formatNumber(n)
	return string.format("%s.%02d", Handler.abbreviate(n), n%1*100)
end

function Order.build(playerData, npcType, increment)
	local orderScreen = Assets.CustomerOrder:Clone()
	local orderFrame = Assets.NPCOrder:Clone()
	local orderItems, orderIngredients = {}, {}
	local total = 0
	for category, items in pairs(GameplayAPI.Orders) do
		local itemName = Handler.chance(items)
		local itemInfo = items[itemName]
		if itemName == "Nothing" or GameplayAPI.XPToLevel(playerData.XP) < itemInfo.Lvl then continue end
		local foodLeft = Instance.new("StringValue")
		foodLeft.Name = itemName
		foodLeft.Parent = orderFrame.Container.Requirements.Parent.Parent.Tray and orderFrame.Container.Requirements.Parent.Parent.Tray.FoodsLeft or Instance.new("Folder")
		for i = 1, Handler.randomInt(itemInfo.Amount) do
			local itemFrame = OrderSample:Clone()
			local itemScreenFrame = OrderScreenSample:Clone()
			local price = itemInfo.Price
			for _, ingredientInfo in pairs(itemInfo.Ingredients) do
				if GameplayAPI.XPToLevel(playerData.XP) < ingredientInfo.Lvl then continue end
				if Handler.random(0,100) > ingredientInfo.Chance then continue end
				local ingredientLeft = Instance.new("StringValue")
				ingredientLeft.Name = ingredientInfo.Item
				ingredientLeft.Value = ingredientInfo.Item
				ingredientLeft.Parent = foodLeft
				local ingredientFrame = IngredientSample:Clone()
				local ingredientScreenFrame = IngredientScreenSample:Clone()
				if GameplayAPI.Ingredients[ingredientInfo.Item] then
					ingredientFrame.Icon.Image = GameplayAPI.Ingredients[ingredientInfo.Item].Icon
					ingredientScreenFrame.Icon.Image = GameplayAPI.Ingredients[ingredientInfo.Item].Icon
				end
				ingredientFrame.Parent = itemFrame.Ingredients
				ingredientScreenFrame.Parent = itemScreenFrame.Ingredients
				price += ingredientInfo.Price
				table.insert(orderIngredients, ingredientInfo.Item)
			end
			table.insert(orderItems, itemName)
			itemScreenFrame.Item.Text = itemName.." - "
			itemScreenFrame.Parent = orderScreen.Order
			local rows = math.ceil((#itemFrame.Ingredients:GetChildren()-3)/6)
			itemFrame.Ingredients.UIAspectRatioConstraint.AspectRatio /= rows
			itemFrame.Ingredients.UIGridLayout.CellSize = UDim2.new(0.166,0,1/rows,0)
			itemFrame.Ingredients.UICorner.CornerRadius = UDim.new(0.5/rows,0)
			itemFrame.Item.Text = string.format("%s - <font color=\"rgb(0,172,0)\">$%s</font>", itemName, formatNumber(price))
			itemFrame.Parent = orderFrame.Container.Requirements
			total += price
		end
	end
	local mult = GameplayAPI.NPCs[npcType].CashMultiplier
	local totalXP = total * 0.5 * (increment or 1)
	orderFrame.Container.TotalPriceContainer.TotalPrice.Text = "Total: $"..formatNumber(total*mult).." ("..mult.."x)"
	orderScreen.Top.OrderGain.Text = "$"..formatNumber(total*mult).." ("..mult.."x)"; orderScreen.Top.Time.Text = GameplayAPI.ClockTime()
	return orderFrame, orderScreen, orderItems, orderIngredients, total*mult, totalXP
end

return Order


