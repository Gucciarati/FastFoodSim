local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local APIs = ReplicatedStorage.APIs
local GameplayAPI = require(APIs.gameplay)
local Settings = require(APIs.settings)
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)

local Assets = ReplicatedStorage.Assets
local Remotes = ReplicatedStorage.Remotes.Gameplay

local module = {}

local function LastParentModel(Part)
	local CurrentModel, CurrentPart = nil, Part
	while true do
		CurrentPart = CurrentPart.Parent
		if CurrentPart == workspace then return CurrentModel end
		if CurrentPart and CurrentPart:IsA("Model") then CurrentModel = CurrentPart end
	end
end

function module.TakeIngredient(Player, Food, Employee)
	if not Food or not Food.Parent or not Food.Parent.Parent then return end
	local Restaurant = Food.Parent.Parent
	if Restaurant.Parent ~= workspace:WaitForChild("OwnedRestaurants") then return end
	local Data = DataAPI.Data(Players:FindFirstChild(Restaurant.Name))
	if not Data then return end
	if Food.Parent ~= Restaurant.Ingredients then return end
	if not Restaurant.Whitelist:FindFirstChild(Player.Name) then return end
	local Item = GameplayAPI.Items.Food[Data.Foods[Food.Name].Item].Food
	local Ingredient = Assets.Food[Item]:Clone()
	Ingredient:PivotTo(Food:GetPivot())
	Ingredient.Parent = Restaurant.Trash
	Data.Foods[Food.Name].Amount -= 1
	if not Employee then
		Remotes.Parent.Handler.Audio:FireClient(Player, Food:FindFirstChild("Bag") and "PickUpBag" or "PickUp2")
		if Data.Foods[Food.Name].Amount > 0 or Food:FindFirstChild("Bag") then
			Remotes.DragItem:FireClient(Player, Ingredient, Item)
		end
	end
	if Data.Foods[Food.Name].Amount <= 0 then
		Data.Foods[Food.Name] = nil
	elseif not Food:FindFirstChild("Bag") and Data.Foods[Food.Name].Amount == 1 then
		module.TakeIngredient(Player, Food, Employee)
	end
	DataAPI.UpdateData(Player)
	return Ingredient
end

function module.SnapIngredient(Player, Ingredient, Snap, Employee)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local Restaurant = LastParentModel(Snap)
	if not Restaurant then return end
	if Restaurant.Name ~= Player.Name then
		if not Restaurant.Whitelist:FindFirstChild(Player.Name) then
			Remotes.Parent.Handler.Notify:FireClient(Player, "Not whitelisted!", "Red")
		end
	end
	if not Ingredient or not Ingredient:IsDescendantOf(Restaurant) then return end
	if not Snap or not Snap:HasTag("Snap") or not Snap:IsDescendantOf(Restaurant) then return end
	local Snappable = Snap:FindFirstChild(Ingredient.Name)
	if not Snappable or Snappable:GetAttribute("Occupied") then return end
	local Requirement = Snappable:GetAttribute("Requirement")
	if Requirement and not Snap.Parent.Ingredients:FindFirstChild(Requirement) then return end
	if Snap.Parent.Name == "Tray" then
		local Found = Snap.Parent.FoodsLeft:FindFirstChild(Ingredient.Name)
		if Found then
			local Ingredients = Ingredient.Ingredients:GetChildren()
			local IngredientsLeft = Snap.Parent.FoodsLeft[Ingredient.Name]:GetChildren()
			local IngredientsFound = 0
			for _,IngredientLeft in pairs(IngredientsLeft) do
				for _,Ingredient in pairs(Ingredients) do
					if Ingredient.Name ~= IngredientLeft.Value then continue end
					IngredientsFound += 1
					table.remove(Ingredients, table.find(Ingredients, Ingredient))
					break
				end
			end
			if #Ingredients > 0 or IngredientsFound < #IngredientsLeft then return end
		else
			return
		end
		Found:Destroy()
	end
	local Ingredients = Ingredient.Ingredients:GetChildren()
	Snappable:SetAttribute("Occupied", true)
	Handler.visible(Snappable)
	Ingredient:Destroy()
	local Time = Snappable:GetAttribute("Time")
	if Time then
		Time *= Settings.Multiplier(Player, "WorkerSpeed")
		if Snappable.Name == "Raw Patty" then
			Snap.Cooktop:Play()
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play()
			Handler.tween(Snappable.Patty, {Time, "Linear"}, {Color = Color3.fromRGB(141, 65, 54)}):Play()
			task.wait(Time)
			if not Employee then Snappable.Flip.OnServerEvent:Wait() end
			Handler.tween(Snappable.Timer, {0}, {Value = 0}):Play()
			Handler.tween(Snappable.Patty, {0}, {Color = Color3.fromRGB(255, 89, 89)}):Play()
			local Flipped = Snap["Flipped Raw Patty"]
			local FlipTime = Flipped:GetAttribute("Time") * Settings.Multiplier(Player, "WorkerSpeed")
			Flipped:SetAttribute("Occupied", true)
			Handler.visible(Flipped)
			Handler.invisible(Snappable)
			Handler.tween(Flipped.Patty, {0.1, "Linear"}, {CFrame = Flipped:GetPivot()*CFrame.Angles(math.rad(90),0,0)}):Play()
			Handler.tween(Flipped.Timer, {FlipTime, "Linear"}, {Value = 100}):Play()
			Handler.tween(Flipped.Patty, {Time, "Linear"}, {Color = Color3.fromRGB(80, 42, 7)}):Play()
			task.wait(FlipTime)
			Snap.Cooktop:Stop()
			Handler.invisible(Flipped)
			Handler.tween(Flipped.Patty, {0}, {CFrame = Flipped:GetPivot()}):Play()
			Handler.tween(Flipped.Timer, {0}, {Value = 0}):Play()
			Handler.tween(Snappable.Patty, {0}, {Color = Color3.fromRGB(141, 65, 54)}):Play()
			local Ingredient = Assets.Food["Cooked Patty"]:Clone()
			Ingredient:PivotTo(CFrame.new(Flipped:GetPivot().Position))
			Ingredient.Parent = Restaurant.Trash
			Snappable:SetAttribute("Occupied", false)
			Flipped:SetAttribute("Occupied", false)
			if Employee then return Ingredient end
		elseif Snappable.Name == "Empty Soda" then
			Snappable.SelectingFlavor.Value = true
			local EventPlayer,Flavor = Snappable.SelectFlavor.OnServerEvent:Wait()
			Snappable.SelectingFlavor.Value = false
			Flavor = Snap.Parent.Flavors:FindFirstChild(Flavor or "") or Snap.Parent.Flavors.Water
			local Original = Assets.Furniture["Drink Dispenser"]
			local DrinkCF = Flavor:GetPivot():ToWorldSpace(Original.Flavors.Water:GetPivot():ToObjectSpace(Original.Part.CFrame))
			for _,Descendant in pairs(Snap:GetDescendants()) do
				if not Descendant:IsA("BasePart") then continue end
				local Offset = Original.Part.CFrame:ToObjectSpace(Original.Part:FindFirstChild(Descendant.Name, true).CFrame)
				Handler.tween(Descendant, {0.2, "Linear"}, {CFrame = DrinkCF * Offset}):Play()
			end
			task.wait(0.25)
			local Color = Flavor:GetAttribute("DrinkColor")
			Snappable.PouringStart.Color = Color
			Snappable.FillStart.Color = Color
			local FillClone = Snappable.FillStart:Clone(); FillClone.Parent = Snappable; FillClone.Transparency = 0
			local PourClone = Snappable.PouringStart:Clone(); PourClone.Parent = Snappable; PourClone.Transparency = 0
			Snap.DrinkFill:Play()
			Handler.tween(PourClone, {0.1, "Linear"}, {Size = Snappable.PouringEnd.Size, CFrame = Snappable.PouringEnd.CFrame}):Play()
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play()
			Handler.tween(FillClone, {Time, "Linear"}, {Size = Snappable.FillEnd.Size, CFrame = Snappable.FillEnd.CFrame}):Play()
			task.wait(Time)
			Snap.DrinkFill:Stop()
			Handler.tween(PourClone, {0.1, "Linear"}, {Size = Snappable.PouringStart.Size, CFrame = Snappable.PouringStart.CFrame}):Play()
			task.delay(0.1, function() PourClone.Transparency = 1 end)
			if not Employee then Snappable.Finish.OnServerEvent:Wait() end
			Handler.tween(Snappable.Timer, {0}, {Value = 0}):Play()
			local Ingredient = Assets.Food["Large Soda"]:Clone()
			Ingredient:PivotTo(Snappable.Base:GetPivot())
			Ingredient.Name = "Large "..Flavor.Name
			Ingredient.DrinkColor.Color = Color
			Ingredient.Ingredients["Large Soda"].Name = "Large "..Flavor.Name
			Ingredient.Parent = Restaurant.Trash
			FillClone:Destroy(); PourClone:Destroy(); Handler.invisible(Snappable)
			Snappable:SetAttribute("Occupied", false)
		elseif Snappable.Name == "Ice Cream Cone" then
			Snappable.SelectingFlavor.Value = true
			local Player,Flavor = Snappable.SelectFlavor.OnServerEvent:Wait()
			Snappable.SelectingFlavor.Value = false
			Flavor = Snap.Parent.Flavors:FindFirstChild(Flavor or "") or Snap.Parent.Flavors.Vanilla
			local Original = Assets.Furniture["Icecream & Milkshake Maker"]
			local DrinkCF = Flavor:GetPivot():ToWorldSpace(Original.Flavors.Vanilla:GetPivot():ToObjectSpace(Original.IceCream.CFrame))
			for _,Descendant in pairs(Snap:GetDescendants()) do
				if not Descendant:IsA("BasePart") then continue end
				local Offset = Original.IceCream.CFrame:ToObjectSpace(Original.IceCream:FindFirstChild(Descendant.Name, true).CFrame)
				Handler.tween(Descendant, {0.2, "Linear"}, {CFrame = DrinkCF * Offset}):Play()
			end
			task.wait(0.25)
			local Color = Flavor:GetAttribute("IceCreamColor")
			Snappable.FillStart.Color = Color
			local FillClone = Snappable.FillStart:Clone(); FillClone.Parent = Snappable; FillClone.Transparency = 0
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play()
			Handler.tween(FillClone, {Time, "Linear"}, {Size = Snappable.FillEnd.Size, CFrame = Snappable.FillEnd.CFrame}):Play()
			task.wait(Time)
			Handler.tween(Snappable.Timer, {0}, {Value = 0}):Play()
			local Ingredient = Assets.Food["Ice Cream"]:Clone()
			Ingredient:PivotTo(Snappable.Base:GetPivot())
			Ingredient.Name = Flavor.Name.." Ice Cream"
			Ingredient.IceCreamColor.Color = Color
			Ingredient.Ingredients["Ice Cream"].Name = Flavor.Name.." Ice Cream"
			Ingredient.Parent = Restaurant.Trash
			FillClone:Destroy(); Handler.invisible(Snappable)
			Snappable:SetAttribute("Occupied", false)
		elseif Snappable.Name == "Milkshake Cup" then
			Snappable.CanStart.Value = true; if not Employee then Snappable.Start.OnServerEvent:Wait() end; Snappable.CanStart.Value = false
			local Flavor = "Vanilla"; local Color = Color3.fromRGB(255,255,255)
			Snappable.FillStart.Color = Color
			local FillClone = Snappable.FillStart:Clone(); FillClone.Parent = Snappable; FillClone.Transparency = 0
			local Mixer = Snap.Parent.Mixer
			Snap.Milkshake:Play()
			Handler.tween(Mixer, {0.5, "Linear"}, {CFrame = Snap.Parent.MixerEnd.CFrame}):Play()
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play()
			Handler.tween(FillClone, {Time, "Linear"}, {Size = Snappable.FillEnd.Size, CFrame = Snappable.FillEnd.CFrame}):Play()
			task.wait(Time)
			Handler.tween(Mixer, {0.5, "Linear"}, {CFrame = Snap.Parent.MixerStart.CFrame}):Play()
			if not Employee then Snappable.Finish.OnServerEvent:Wait() end
			Snap.Milkshake:Stop()
			Handler.tween(Snappable.Timer, {0}, {Value = 0}):Play()
			local Ingredient = Assets.Food["Milkshake"]:Clone()
			Ingredient:PivotTo(Snappable.Base:GetPivot())
			Ingredient.Name = Flavor.." Milkshake"
			Ingredient.MilkColor.Color = Color
			Ingredient.Ingredients["Milkshake"].Name = Flavor.." Milkshake"
			Ingredient.Parent = Restaurant.Trash
			FillClone:Destroy(); Handler.invisible(Snappable)
			Snappable:SetAttribute("Occupied", false)
		elseif Snappable.Name == "Raw Nuggets" or Snappable.Name == "Raw Onion Rings" or Snappable.Name == "Raw Fries" then
			Snap.Frying:Play(); Handler.invisible(Snap.Parent.Model)
			local Original = Assets.Furniture["Fryer"]
			local Parent = Original[Snap.Parent.Name]
			for _,Descendant in pairs(Snap:GetDescendants()) do if not Descendant:IsA("BasePart") then continue end Handler.tween(Descendant, {0.4, "Linear"}, {CFrame = Descendant.CFrame - Vector3.new(0,0.9,0)}):Play() end
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play(); task.wait(Time)
			for _,Descendant in pairs(Snap:GetDescendants()) do if not Descendant:IsA("BasePart") then continue end local Offset = Parent.Part.CFrame:ToObjectSpace(Parent.Part:FindFirstChild(Descendant.Name, true).CFrame) Handler.tween(Descendant, {0.4, "Linear"}, {CFrame = Descendant.CFrame + Vector3.new(0,0.9,0)}):Play() end
			Snap.Frying:Stop(); task.wait(0.5); Handler.tween(Snappable.Timer, {0}, {Value = 0}):Play()
			local Ingredient = Assets.Food[Snappable.Name:gsub("Raw ", "Cooked ")]:Clone()
			Ingredient:PivotTo(Snappable:GetPivot()); Ingredient.Parent = Restaurant.Trash
			Handler.invisible(Snappable); Handler.visible(Snap.Parent.Model); Snappable:SetAttribute("Occupied", false)
			if Employee then return Ingredient end
		else
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play(); task.wait(Time)
			Handler.invisible(Snappable); Snappable:SetAttribute("Occupied", false)
		end
	else
		for _,Ingredient in pairs(Ingredients) do Handler.create("StringValue", Snap.Parent.Ingredients, Ingredient.Name, "") end
		if Snap.Parent.Name == "Tray" then Handler.destroy(Snap.Parent.Ingredients:FindFirstChild("Tray"))
		elseif Snappable.Name == "Cooked Patty" then
			Snappable.Finished.Value = true
			task.spawn(function()
				if Employee then Snappable.EmployeeWrap.Event:Wait() else Snappable.Wrap.OnServerEvent:Wait() end
				if not Snap or not Snap.Parent then return end
				Snap.Parent:SetAttribute("Wrapped", true)
				for _,Food in pairs(Snap:GetChildren()) do Handler.invisible(Food) end
				Handler.invisible(Snap.Parent.Paper); Handler.visible(Snap["Wrapped Burger"])
				Snappable.Finished.Value = false
			end)
		elseif Snappable.Name == "Burger Bun" then
			Snap.Parent.Ingredients["Paper"]:Destroy(); Snap.Parent.Name = "Burger"
		elseif Snappable.Name == "Cooked Nuggets" then
			Snappable.Closeable.Value = false; Handler.invisible(Snap.Parent["Nugget Box"]); Handler.visible(Snap["Closed Nugget Box"]) 
			Snap.Parent.Ingredients["Cooked Nuggets"]:Destroy(); Snap.Parent.Name = "Nuggets"
		elseif Snappable.Name == "Cooked Fries" then
			Snap.Parent.Ingredients["Cooked Fries"]:Destroy(); Snap.Parent.Name = "Fries"
		elseif Snappable.Name == "Cooked Onion Rings" then
			Snap.Parent.Ingredients["Cooked Onion Rings"]:Destroy(); Snap.Parent.Name = "Onion Rings"
		end
	end
end

return module


