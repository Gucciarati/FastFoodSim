--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(Packages.Net)

local OwnedRestaurants = workspace:WaitForChild("OwnedRestaurants")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local FoodAssets = Assets:WaitForChild("Food")

local TakeIngredientRemote = Net:RemoteEvent("TakeIngredient")
local SnapIngredientRemote = Net:RemoteEvent("SnapIngredient")
local PickUpItemRemote = Net:RemoteEvent("PickUpItem")
local PlaceItemRemote = Net:RemoteEvent("PlaceItem")
local DragItemRemote = Net:RemoteEvent("DragItem")

type PlayerData = {
	Foods: {[string]: {Item: string, Amount: number}},
}

local function GetPlayerData(player: Player): PlayerData?
	return nil
end

local function UpdateData(player: Player)
end

local function GetRestaurant(instance: Instance): Model?
	local current = instance
	while current and current ~= workspace do
		if current.Parent == OwnedRestaurants then
			return current :: Model
		end
		current = current.Parent :: Instance
	end
	return nil
end

local function IsWhitelisted(player: Player, restaurant: Model): boolean
	local whitelist = restaurant:FindFirstChild("Whitelist")
	return whitelist ~= nil and whitelist:FindFirstChild(player.Name) ~= nil
end

local function SetVisible(model: Instance)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			local saved = descendant:GetAttribute("SavedTransparency")
			if saved then
				descendant.Transparency = saved
				descendant:SetAttribute("SavedTransparency", nil)
			end
		end
	end
	if model:IsA("BasePart") then
		local saved = model:GetAttribute("SavedTransparency")
		if saved then
			model.Transparency = saved
			model:SetAttribute("SavedTransparency", nil)
		end
	end
end

local function SetInvisible(model: Instance)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Transparency < 1 then
			descendant:SetAttribute("SavedTransparency", descendant.Transparency)
			descendant.Transparency = 1
		end
	end
	if model:IsA("BasePart") and model.Transparency < 1 then
		model:SetAttribute("SavedTransparency", model.Transparency)
		model.Transparency = 1
	end
end

local function CreateTween(instance: Instance, tweenInfo: {number | string}, properties: {[string]: any}): Tween
	local info = TweenInfo.new(
		(tweenInfo[1] :: number?) or 1,
		Enum.EasingStyle[(tweenInfo[2] :: string?) or "Quad"],
		Enum.EasingDirection[(tweenInfo[3] :: string?) or "Out"],
		(tweenInfo[4] :: number?) or 0,
		(tweenInfo[5] :: boolean?) or false,
		(tweenInfo[6] :: number?) or 0
	)
	return TweenService:Create(instance, info, properties)
end

local function GetMultiplier(player: Player, multiplierType: string): number
	return 1.0
end

local function TakeIngredient(player: Player, foodStorage: BasePart, isEmployee: boolean?): Model?
	if not foodStorage or not foodStorage.Parent or not foodStorage.Parent.Parent then return nil end
	
	local restaurant = foodStorage.Parent.Parent :: Model
	if restaurant.Parent ~= OwnedRestaurants then return nil end
	
	local owner = Players:FindFirstChild(restaurant.Name)
	if not owner then return nil end
	
	local data = GetPlayerData(owner)
	if not data then return nil end
	
	local ingredients = restaurant:FindFirstChild("Ingredients")
	if not ingredients or foodStorage.Parent ~= ingredients then return nil end
	
	if not IsWhitelisted(player, restaurant) then return nil end
	
	local foodData = data.Foods[foodStorage.Name]
	if not foodData then return nil end
	
	local foodItem = FoodAssets:FindFirstChild(foodData.Item)
	if not foodItem then return nil end
	
	local ingredient = foodItem:Clone()
	ingredient:PivotTo(foodStorage:GetPivot())
	
	local trash = restaurant:FindFirstChild("Trash")
	if trash then
		ingredient.Parent = trash
	else
		ingredient.Parent = restaurant
	end
	
	foodData.Amount -= 1
	
	if not isEmployee then
		if foodData.Amount > 0 or foodStorage:FindFirstChild("Bag") then
			DragItemRemote:FireClient(player, ingredient, foodData.Item)
		end
	end
	
	if foodData.Amount <= 0 then
		data.Foods[foodStorage.Name] = nil
	elseif not foodStorage:FindFirstChild("Bag") and foodData.Amount == 1 then
		TakeIngredient(player, foodStorage, isEmployee)
	end
	
	UpdateData(owner)
	return ingredient
end

local function SnapIngredient(player: Player, ingredient: Model, snap: BasePart, isEmployee: boolean?)
	local data = GetPlayerData(player)
	if not data then return end
	
	local restaurant = GetRestaurant(snap)
	if not restaurant then return end
	
	if restaurant.Name ~= player.Name then
		if not IsWhitelisted(player, restaurant) then
			return
		end
	end
	
	if not ingredient or not ingredient:IsDescendantOf(restaurant) then return end
	if not snap or not snap:HasTag("Snap") or not snap:IsDescendantOf(restaurant) then return end
	
	local snappable = snap:FindFirstChild(ingredient.Name)
	if not snappable or snappable:GetAttribute("Occupied") then return end
	
	local requirement = snappable:GetAttribute("Requirement")
	if requirement then
		local snapParent = snap.Parent
		if snapParent then
			local ingredientsFolder = snapParent:FindFirstChild("Ingredients")
			if ingredientsFolder and not ingredientsFolder:FindFirstChild(requirement) then
				return
			end
		end
	end
	
	local snapParent = snap.Parent
	if snapParent and snapParent.Name == "Tray" then
		local foodsLeft = snapParent:FindFirstChild("FoodsLeft")
		if not foodsLeft then return end
		
		local found = foodsLeft:FindFirstChild(ingredient.Name)
		if found then
			local ingredientsFolder = ingredient:FindFirstChild("Ingredients")
			local ingredients = ingredientsFolder and ingredientsFolder:GetChildren() or {}
			local ingredientsLeft = found:GetChildren()
			local ingredientsFound = 0
			
			for _, ingredientLeft in ingredientsLeft do
				for i, ing in ingredients do
					if ing.Name == (ingredientLeft :: StringValue).Value then
						ingredientsFound += 1
						table.remove(ingredients, i)
						break
					end
				end
			end
			
			if #ingredients > 0 or ingredientsFound < #ingredientsLeft then
				return
			end
		else
			return
		end
		found:Destroy()
	end
	
	local ingredientsFolder = ingredient:FindFirstChild("Ingredients")
	local ingredientsList = ingredientsFolder and ingredientsFolder:GetChildren() or {}
	
	snappable:SetAttribute("Occupied", true)
	SetVisible(snappable)
	ingredient:Destroy()
	
	local cookTime = snappable:GetAttribute("Time") :: number?
	if cookTime then
		cookTime *= GetMultiplier(player, "WorkerSpeed")
		
		if snappable.Name == "Raw Patty" then
			local cooktop = snap:FindFirstChild("Cooktop") :: Sound?
			local timer = snappable:FindFirstChild("Timer") :: NumberValue?
			local patty = snappable:FindFirstChild("Patty") :: BasePart?
			
			if cooktop then cooktop:Play() end
			if timer then CreateTween(timer, {cookTime, "Linear"}, {Value = 100}):Play() end
			if patty then CreateTween(patty, {cookTime, "Linear"}, {Color = Color3.fromRGB(141, 65, 54)}):Play() end
			
			task.wait(cookTime)
			
			if not isEmployee then
				local flip = snappable:FindFirstChild("Flip") :: RemoteEvent?
				if flip then flip.OnServerEvent:Wait() end
			end
			
			if timer then CreateTween(timer, {0}, {Value = 0}):Play() end
			if patty then CreateTween(patty, {0}, {Color = Color3.fromRGB(255, 89, 89)}):Play() end
			
			local flipped = snap:FindFirstChild("Flipped Raw Patty")
			if flipped then
				local flipTime = (flipped:GetAttribute("Time") :: number? or 1) * GetMultiplier(player, "WorkerSpeed")
				flipped:SetAttribute("Occupied", true)
				SetVisible(flipped)
				SetInvisible(snappable)
				
				local flippedPatty = flipped:FindFirstChild("Patty") :: BasePart?
				local flippedTimer = flipped:FindFirstChild("Timer") :: NumberValue?
				
				if flippedPatty then
					CreateTween(flippedPatty, {0.1, "Linear"}, {CFrame = flipped:GetPivot() * CFrame.Angles(math.rad(90), 0, 0)}):Play()
				end
				if flippedTimer then CreateTween(flippedTimer, {flipTime, "Linear"}, {Value = 100}):Play() end
				if flippedPatty then CreateTween(flippedPatty, {cookTime, "Linear"}, {Color = Color3.fromRGB(80, 42, 7)}):Play() end
				
				task.wait(flipTime)
				
				if cooktop then cooktop:Stop() end
				SetInvisible(flipped)
				
				if flippedPatty then CreateTween(flippedPatty, {0}, {CFrame = flipped:GetPivot()}):Play() end
				if flippedTimer then CreateTween(flippedTimer, {0}, {Value = 0}):Play() end
				if patty then CreateTween(patty, {0}, {Color = Color3.fromRGB(141, 65, 54)}):Play() end
				
				local cookedPatty = FoodAssets:FindFirstChild("Cooked Patty")
				if cookedPatty then
					local newIngredient = cookedPatty:Clone()
					newIngredient:PivotTo(CFrame.new(flipped:GetPivot().Position))
					local trash = restaurant:FindFirstChild("Trash")
					newIngredient.Parent = trash or restaurant
					
					snappable:SetAttribute("Occupied", false)
					flipped:SetAttribute("Occupied", false)
					
					if isEmployee then return newIngredient end
				end
			end
			
		elseif snappable.Name == "Empty Soda" then
			local selectingFlavor = snappable:FindFirstChild("SelectingFlavor") :: BoolValue?
			if selectingFlavor then selectingFlavor.Value = true end
			
			local selectFlavor = snappable:FindFirstChild("SelectFlavor") :: RemoteEvent?
			local flavor: string = "Water"
			if selectFlavor then
				local _, flavorName = selectFlavor.OnServerEvent:Wait()
				flavor = flavorName or "Water"
			end
			
			if selectingFlavor then selectingFlavor.Value = false end
			
			local snapParentFlavors = snapParent and snapParent:FindFirstChild("Flavors")
			local flavorPart = snapParentFlavors and snapParentFlavors:FindFirstChild(flavor) :: BasePart?
			if not flavorPart then
				flavorPart = snapParentFlavors and snapParentFlavors:FindFirstChild("Water") :: BasePart?
			end
			
			local timer = snappable:FindFirstChild("Timer") :: NumberValue?
			local fillStart = snappable:FindFirstChild("FillStart") :: BasePart?
			local fillEnd = snappable:FindFirstChild("FillEnd") :: BasePart?
			local pouringStart = snappable:FindFirstChild("PouringStart") :: BasePart?
			local pouringEnd = snappable:FindFirstChild("PouringEnd") :: BasePart?
			local drinkFill = snap:FindFirstChild("DrinkFill") :: Sound?
			
			local color = flavorPart and flavorPart:GetAttribute("DrinkColor") :: Color3? or Color3.fromRGB(255, 255, 255)
			
			if pouringStart then pouringStart.Color = color end
			if fillStart then fillStart.Color = color end
			
			local fillClone: BasePart? = nil
			local pourClone: BasePart? = nil
			
			if fillStart then
				fillClone = fillStart:Clone()
				fillClone.Parent = snappable
				fillClone.Transparency = 0
			end
			
			if pouringStart then
				pourClone = pouringStart:Clone()
				pourClone.Parent = snappable
				pourClone.Transparency = 0
			end
			
			if drinkFill then drinkFill:Play() end
			
			if pourClone and pouringEnd then
				CreateTween(pourClone, {0.1, "Linear"}, {Size = pouringEnd.Size, CFrame = pouringEnd.CFrame}):Play()
			end
			if timer then CreateTween(timer, {cookTime, "Linear"}, {Value = 100}):Play() end
			if fillClone and fillEnd then
				CreateTween(fillClone, {cookTime, "Linear"}, {Size = fillEnd.Size, CFrame = fillEnd.CFrame}):Play()
			end
			
			task.wait(cookTime)
			
			if drinkFill then drinkFill:Stop() end
			
			if pourClone and pouringStart then
				CreateTween(pourClone, {0.1, "Linear"}, {Size = pouringStart.Size, CFrame = pouringStart.CFrame}):Play()
				task.delay(0.1, function()
					if pourClone then pourClone.Transparency = 1 end
				end)
			end
			
			if not isEmployee then
				local finish = snappable:FindFirstChild("Finish") :: RemoteEvent?
				if finish then finish.OnServerEvent:Wait() end
			end
			
			if timer then CreateTween(timer, {0}, {Value = 0}):Play() end
			
			local largeSoda = FoodAssets:FindFirstChild("Large Soda")
			if largeSoda then
				local base = snappable:FindFirstChild("Base") :: BasePart?
				local newIngredient = largeSoda:Clone()
				if base then newIngredient:PivotTo(base:GetPivot()) end
				newIngredient.Name = "Large " .. flavor
				local drinkColor = newIngredient:FindFirstChild("DrinkColor") :: BasePart?
				if drinkColor then drinkColor.Color = color end
				local ingredientsChild = newIngredient:FindFirstChild("Ingredients")
				local sodaIngredient = ingredientsChild and ingredientsChild:FindFirstChild("Large Soda")
				if sodaIngredient then sodaIngredient.Name = "Large " .. flavor end
				local trash = restaurant:FindFirstChild("Trash")
				newIngredient.Parent = trash or restaurant
			end
			
			if fillClone then fillClone:Destroy() end
			if pourClone then pourClone:Destroy() end
			SetInvisible(snappable)
			snappable:SetAttribute("Occupied", false)
			
		elseif snappable.Name == "Ice Cream Cone" then
			local selectingFlavor = snappable:FindFirstChild("SelectingFlavor") :: BoolValue?
			if selectingFlavor then selectingFlavor.Value = true end
			
			local selectFlavor = snappable:FindFirstChild("SelectFlavor") :: RemoteEvent?
			local flavor: string = "Vanilla"
			if selectFlavor then
				local _, flavorName = selectFlavor.OnServerEvent:Wait()
				flavor = flavorName or "Vanilla"
			end
			
			if selectingFlavor then selectingFlavor.Value = false end
			
			local snapParentFlavors = snapParent and snapParent:FindFirstChild("Flavors")
			local flavorPart = snapParentFlavors and snapParentFlavors:FindFirstChild(flavor) :: BasePart?
			if not flavorPart then
				flavorPart = snapParentFlavors and snapParentFlavors:FindFirstChild("Vanilla") :: BasePart?
			end
			
			local timer = snappable:FindFirstChild("Timer") :: NumberValue?
			local fillStart = snappable:FindFirstChild("FillStart") :: BasePart?
			local fillEnd = snappable:FindFirstChild("FillEnd") :: BasePart?
			
			local color = flavorPart and flavorPart:GetAttribute("IceCreamColor") :: Color3? or Color3.fromRGB(255, 255, 255)
			
			if fillStart then fillStart.Color = color end
			
			local fillClone: BasePart? = nil
			if fillStart then
				fillClone = fillStart:Clone()
				fillClone.Parent = snappable
				fillClone.Transparency = 0
			end
			
			if timer then CreateTween(timer, {cookTime, "Linear"}, {Value = 100}):Play() end
			if fillClone and fillEnd then
				CreateTween(fillClone, {cookTime, "Linear"}, {Size = fillEnd.Size, CFrame = fillEnd.CFrame}):Play()
			end
			
			task.wait(cookTime)
			
			if timer then CreateTween(timer, {0}, {Value = 0}):Play() end
			
			local iceCream = FoodAssets:FindFirstChild("Ice Cream")
			if iceCream then
				local base = snappable:FindFirstChild("Base") :: BasePart?
				local newIngredient = iceCream:Clone()
				if base then newIngredient:PivotTo(base:GetPivot()) end
				newIngredient.Name = flavor .. " Ice Cream"
				local iceCreamColor = newIngredient:FindFirstChild("IceCreamColor") :: BasePart?
				if iceCreamColor then iceCreamColor.Color = color end
				local ingredientsChild = newIngredient:FindFirstChild("Ingredients")
				local iceCreamIngredient = ingredientsChild and ingredientsChild:FindFirstChild("Ice Cream")
				if iceCreamIngredient then iceCreamIngredient.Name = flavor .. " Ice Cream" end
				local trash = restaurant:FindFirstChild("Trash")
				newIngredient.Parent = trash or restaurant
			end
			
			if fillClone then fillClone:Destroy() end
			SetInvisible(snappable)
			snappable:SetAttribute("Occupied", false)
			
		elseif snappable.Name == "Milkshake Cup" then
			local canStart = snappable:FindFirstChild("CanStart") :: BoolValue?
			if canStart then canStart.Value = true end
			
			if not isEmployee then
				local start = snappable:FindFirstChild("Start") :: RemoteEvent?
				if start then start.OnServerEvent:Wait() end
			end
			
			if canStart then canStart.Value = false end
			
			local flavor = "Vanilla"
			local color = Color3.fromRGB(255, 255, 255)
			
			local timer = snappable:FindFirstChild("Timer") :: NumberValue?
			local fillStart = snappable:FindFirstChild("FillStart") :: BasePart?
			local fillEnd = snappable:FindFirstChild("FillEnd") :: BasePart?
			local mixer = snapParent and snapParent:FindFirstChild("Mixer") :: BasePart?
			local mixerEnd = snapParent and snapParent:FindFirstChild("MixerEnd") :: BasePart?
			local mixerStart = snapParent and snapParent:FindFirstChild("MixerStart") :: BasePart?
			local milkshakeSound = snap:FindFirstChild("Milkshake") :: Sound?
			
			if fillStart then fillStart.Color = color end
			
			local fillClone: BasePart? = nil
			if fillStart then
				fillClone = fillStart:Clone()
				fillClone.Parent = snappable
				fillClone.Transparency = 0
			end
			
			if milkshakeSound then milkshakeSound:Play() end
			
			if mixer and mixerEnd then
				CreateTween(mixer, {0.5, "Linear"}, {CFrame = mixerEnd.CFrame}):Play()
			end
			if timer then CreateTween(timer, {cookTime, "Linear"}, {Value = 100}):Play() end
			if fillClone and fillEnd then
				CreateTween(fillClone, {cookTime, "Linear"}, {Size = fillEnd.Size, CFrame = fillEnd.CFrame}):Play()
			end
			
			task.wait(cookTime)
			
			if mixer and mixerStart then
				CreateTween(mixer, {0.5, "Linear"}, {CFrame = mixerStart.CFrame}):Play()
			end
			
			if not isEmployee then
				local finish = snappable:FindFirstChild("Finish") :: RemoteEvent?
				if finish then finish.OnServerEvent:Wait() end
			end
			
			if milkshakeSound then milkshakeSound:Stop() end
			if timer then CreateTween(timer, {0}, {Value = 0}):Play() end
			
			local milkshake = FoodAssets:FindFirstChild("Milkshake")
			if milkshake then
				local base = snappable:FindFirstChild("Base") :: BasePart?
				local newIngredient = milkshake:Clone()
				if base then newIngredient:PivotTo(base:GetPivot()) end
				newIngredient.Name = flavor .. " Milkshake"
				local milkColor = newIngredient:FindFirstChild("MilkColor") :: BasePart?
				if milkColor then milkColor.Color = color end
				local ingredientsChild = newIngredient:FindFirstChild("Ingredients")
				local milkshakeIngredient = ingredientsChild and ingredientsChild:FindFirstChild("Milkshake")
				if milkshakeIngredient then milkshakeIngredient.Name = flavor .. " Milkshake" end
				local trash = restaurant:FindFirstChild("Trash")
				newIngredient.Parent = trash or restaurant
			end
			
			if fillClone then fillClone:Destroy() end
			SetInvisible(snappable)
			snappable:SetAttribute("Occupied", false)
			
		elseif snappable.Name == "Raw Nuggets" or snappable.Name == "Raw Onion Rings" or snappable.Name == "Raw Fries" then
			local fryingSound = snap:FindFirstChild("Frying") :: Sound?
			local model = snapParent and snapParent:FindFirstChild("Model")
			local timer = snappable:FindFirstChild("Timer") :: NumberValue?
			
			if fryingSound then fryingSound:Play() end
			if model then SetInvisible(model) end
			
			for _, descendant in snap:GetDescendants() do
				if not descendant:IsA("BasePart") then continue end
				CreateTween(descendant, {0.4, "Linear"}, {CFrame = descendant.CFrame - Vector3.new(0, 0.9, 0)}):Play()
			end
			
			if timer then CreateTween(timer, {cookTime, "Linear"}, {Value = 100}):Play() end
			
			task.wait(cookTime)
			
			for _, descendant in snap:GetDescendants() do
				if not descendant:IsA("BasePart") then continue end
				CreateTween(descendant, {0.4, "Linear"}, {CFrame = descendant.CFrame + Vector3.new(0, 0.9, 0)}):Play()
			end
			
			if fryingSound then fryingSound:Stop() end
			task.wait(0.5)
			if timer then CreateTween(timer, {0}, {Value = 0}):Play() end
			
			local cookedName = snappable.Name:gsub("Raw ", "Cooked ")
			local cookedFood = FoodAssets:FindFirstChild(cookedName)
			if cookedFood then
				local newIngredient = cookedFood:Clone()
				newIngredient:PivotTo(snappable:GetPivot())
				local trash = restaurant:FindFirstChild("Trash")
				newIngredient.Parent = trash or restaurant
				
				SetInvisible(snappable)
				if model then SetVisible(model) end
				snappable:SetAttribute("Occupied", false)
				
				if isEmployee then return newIngredient end
			end
		else
			local timer = snappable:FindFirstChild("Timer") :: NumberValue?
			if timer then CreateTween(timer, {cookTime, "Linear"}, {Value = 100}):Play() end
			task.wait(cookTime)
			SetInvisible(snappable)
			snappable:SetAttribute("Occupied", false)
		end
	else
		for _, ing in ingredientsList do
			local ingredientsFolder = snapParent and snapParent:FindFirstChild("Ingredients")
			if ingredientsFolder then
				local stringValue = Instance.new("StringValue")
				stringValue.Name = ing.Name
				stringValue.Parent = ingredientsFolder
			end
		end
		
		if snapParent and snapParent.Name == "Tray" then
			local ingredientsFolder = snapParent:FindFirstChild("Ingredients")
			local trayIngredient = ingredientsFolder and ingredientsFolder:FindFirstChild("Tray")
			if trayIngredient then trayIngredient:Destroy() end
			
		elseif snappable.Name == "Cooked Patty" then
			local finished = snappable:FindFirstChild("Finished") :: BoolValue?
			if finished then finished.Value = true end
			
			task.spawn(function()
				local employeeWrap = snappable:FindFirstChild("EmployeeWrap") :: BindableEvent?
				local wrap = snappable:FindFirstChild("Wrap") :: RemoteEvent?
				
				if isEmployee and employeeWrap then
					employeeWrap.Event:Wait()
				elseif wrap then
					wrap.OnServerEvent:Wait()
				end
				
				if not snap or not snap.Parent then return end
				
				snapParent:SetAttribute("Wrapped", true)
				
				for _, food in snap:GetChildren() do
					SetInvisible(food)
				end
				
				local paper = snapParent:FindFirstChild("Paper")
				if paper then SetInvisible(paper) end
				
				local wrappedBurger = snap:FindFirstChild("Wrapped Burger")
				if wrappedBurger then SetVisible(wrappedBurger) end
				
				if finished then finished.Value = false end
			end)
			
		elseif snappable.Name == "Burger Bun" then
			local ingredientsFolder = snapParent and snapParent:FindFirstChild("Ingredients")
			local paperIngredient = ingredientsFolder and ingredientsFolder:FindFirstChild("Paper")
			if paperIngredient then paperIngredient:Destroy() end
			if snapParent then snapParent.Name = "Burger" end
			
		elseif snappable.Name == "Cooked Nuggets" then
			local closeable = snappable:FindFirstChild("Closeable") :: BoolValue?
			if closeable then closeable.Value = false end
			
			local nuggetBox = snapParent and snapParent:FindFirstChild("Nugget Box")
			if nuggetBox then SetInvisible(nuggetBox) end
			
			local closedNuggetBox = snap:FindFirstChild("Closed Nugget Box")
			if closedNuggetBox then SetVisible(closedNuggetBox) end
			
			local ingredientsFolder = snapParent and snapParent:FindFirstChild("Ingredients")
			local nuggetIngredient = ingredientsFolder and ingredientsFolder:FindFirstChild("Cooked Nuggets")
			if nuggetIngredient then nuggetIngredient:Destroy() end
			if snapParent then snapParent.Name = "Nuggets" end
			
		elseif snappable.Name == "Cooked Fries" then
			local ingredientsFolder = snapParent and snapParent:FindFirstChild("Ingredients")
			local friesIngredient = ingredientsFolder and ingredientsFolder:FindFirstChild("Cooked Fries")
			if friesIngredient then friesIngredient:Destroy() end
			if snapParent then snapParent.Name = "Fries" end
			
		elseif snappable.Name == "Cooked Onion Rings" then
			local ingredientsFolder = snapParent and snapParent:FindFirstChild("Ingredients")
			local onionRingsIngredient = ingredientsFolder and ingredientsFolder:FindFirstChild("Cooked Onion Rings")
			if onionRingsIngredient then onionRingsIngredient:Destroy() end
			if snapParent then snapParent.Name = "Onion Rings" end
		end
	end
end

local function PickUpItem(player: Player, item: Model)
	if not item or not item.Parent then return end
	
	local restaurant = GetRestaurant(item)
	if not restaurant then return end
	
	if not IsWhitelisted(player, restaurant) then return end
	
	item:SetAttribute("HeldBy", player.UserId)
	PickUpItemRemote:FireAllClients(player, item)
end

local function PlaceItem(player: Player, item: Model, position: CFrame)
	if not item or not item.Parent then return end
	
	local restaurant = GetRestaurant(item)
	if not restaurant then return end
	
	if item:GetAttribute("HeldBy") ~= player.UserId then return end
	
	item:SetAttribute("HeldBy", nil)
	
	local drag = item:FindFirstChild("Drag") :: BasePart?
	if drag then
		drag.CFrame = position
		drag.AssemblyLinearVelocity = Vector3.zero
		drag.AssemblyAngularVelocity = Vector3.zero
	end
	
	PlaceItemRemote:FireAllClients(player, item)
end

TakeIngredientRemote.OnServerEvent:Connect(function(player: Player, foodStorage: BasePart)
	TakeIngredient(player, foodStorage)
end)

SnapIngredientRemote.OnServerEvent:Connect(function(player: Player, ingredient: Model, snap: BasePart)
	SnapIngredient(player, ingredient, snap)
end)

PickUpItemRemote.OnServerEvent:Connect(function(player: Player, item: Model)
	PickUpItem(player, item)
end)

PlaceItemRemote.OnServerEvent:Connect(function(player: Player, item: Model, position: CFrame)
	PlaceItem(player, item, position)
end)

return {
	TakeIngredient = TakeIngredient,
	SnapIngredient = SnapIngredient,
	PickUpItem = PickUpItem,
	PlaceItem = PlaceItem,
}
