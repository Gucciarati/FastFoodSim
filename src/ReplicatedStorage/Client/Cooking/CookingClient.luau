--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()
local Character = Player.Character or Player.CharacterAdded:Wait()

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(Packages.Net)

local TakeIngredientRemote = Net:RemoteEvent("TakeIngredient")
local SnapIngredientRemote = Net:RemoteEvent("SnapIngredient")
local PickUpItemRemote = Net:RemoteEvent("PickUpItem")
local PlaceItemRemote = Net:RemoteEvent("PlaceItem")
local DragItemRemote = Net:RemoteEvent("DragItem")

local OwnedRestaurants = workspace:WaitForChild("OwnedRestaurants")

local Dragging: Model? = nil
local DraggingClone: Model? = nil
local Snapping: BasePart? = nil
local HoldOffset: CFrame = CFrame.new(0, -1, -2)

local MouseParams = RaycastParams.new()
MouseParams.FilterType = Enum.RaycastFilterType.Exclude

local Interactions: {[Instance]: any} = {}

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

local function Hologram(model: Model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 0.6
			descendant.CanCollide = false
			descendant.CastShadow = false
			descendant.Material = Enum.Material.ForceField
		end
	end
end

local function StopDragging()
	if not Dragging then return end
	
	if DraggingClone then
		DraggingClone:Destroy()
		DraggingClone = nil
	end
	
	Dragging = nil
	Snapping = nil
end

local function DragItem(item: Model, name: string)
	if Dragging then return end
	
	local restaurant = GetRestaurant(item)
	if not restaurant then return end
	if not restaurant:FindFirstChild("Whitelist") then return end
	if not restaurant.Whitelist:FindFirstChild(Player.Name) then return end
	
	if item:GetAttribute("Placing") then return end
	
	PickUpItemRemote:FireServer(item)
	
	local size = item:GetExtentsSize()
	HoldOffset = CFrame.new(0, -1 - size.Y / 2, -2 - size.Z / 2)
	
	Dragging = item
	
	local drag = item:FindFirstChild("Drag") :: BasePart?
	if drag then
		drag.Anchored = true
	end
	
	local clone = item:Clone()
	Hologram(clone)
	if clone:FindFirstChild("Drag") then
		(clone.Drag :: BasePart).Anchored = true
	end
	clone.Parent = workspace
	DraggingClone = clone
	
	MouseParams.FilterDescendantsInstances = {Dragging, DraggingClone, Character}
end

local function DropItem()
	if not Dragging or not DraggingClone then return end
	
	if DraggingClone:GetAttribute("PlacementError") then return end
	
	if Snapping then
		local snap = Snapping.Parent :: BasePart
		local model = Dragging
		
		if snap.Parent and snap.Parent.Name == "Tray" then
			local tray = snap.Parent
			local found = tray:FindFirstChild("FoodsLeft") and tray.FoodsLeft:FindFirstChild(model.Name)
			if found then
				local ingredients = model:FindFirstChild("Ingredients") and model.Ingredients:GetChildren() or {}
				local ingredientsLeft = found:GetChildren()
				local ingredientsFound = 0
				for _, ingredientLeft in ingredientsLeft do
					for i, ingredient in ingredients do
						if ingredient.Name == ingredientLeft.Value then
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
		end
		
		local snappable = snap:FindFirstChild(model.Name)
		if not snappable or snappable:GetAttribute("Occupied") then return end
		
		local requirement = snappable:GetAttribute("Requirement")
		if requirement and snap.Parent then
			local ingredientsFolder = snap.Parent:FindFirstChild("Ingredients")
			if ingredientsFolder and not ingredientsFolder:FindFirstChild(requirement) then
				return
			end
		end
		
		Interactions[model] = nil
		SnapIngredientRemote:FireServer(model, snap)
	else
		local dragCF = DraggingClone:FindFirstChild("Drag") and (DraggingClone.Drag :: BasePart).CFrame
		if dragCF then
			PlaceItemRemote:FireServer(Dragging, dragCF)
			local drag = Dragging:FindFirstChild("Drag") :: BasePart?
			if drag then
				drag.CFrame = dragCF
				drag.AssemblyLinearVelocity = Vector3.zero
				drag.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end
	
	StopDragging()
end

local function UpdateDrag()
	if not Dragging or not DraggingClone then return end
	
	local targetCF = Camera.CFrame * HoldOffset
	local drag = DraggingClone:FindFirstChild("Drag") :: BasePart?
	if drag then
		drag.CFrame = targetCF
	end
	
	local mouseRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
	local result = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 100, MouseParams)
	
	Snapping = nil
	if result and result.Instance:HasTag("Snap") then
		Snapping = result.Instance
	end
end

RunService.RenderStepped:Connect(function()
	if Dragging then
		UpdateDrag()
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 and Dragging then
		DropItem()
	end
end)

DragItemRemote.OnClientEvent:Connect(function(item: Model, name: string)
	DragItem(item, name)
end)

PickUpItemRemote.OnClientEvent:Connect(function(holder: Player, item: Model)
	if holder == Player then return end
end)

PlaceItemRemote.OnClientEvent:Connect(function(holder: Player, item: Model)
	if holder == Player then return end
end)

CollectionService:GetInstanceAddedSignal("Snap"):Connect(function(snap: BasePart)
	if not snap:IsDescendantOf(OwnedRestaurants) then return end
	snap.CanCollide = false
	snap.CanQuery = true
	
	snap.ChildAdded:Connect(function(food: Instance)
		local timer = food:FindFirstChild("Timer") :: NumberValue?
		if not timer then return end
		
		Interactions[food] = {
			Title = food.Name .. " (0%)",
			Actions = {},
		}
		
		timer:GetPropertyChangedSignal("Value"):Connect(function()
			local value = timer.Value
			Interactions[food].Title = food.Name .. " (" .. tostring(value) .. "%)"
			
			if food.Name == "Raw Patty" then
				local flip = food:FindFirstChild("Flip") :: RemoteEvent?
				Interactions[food].Actions["Flip"] = value >= 100 and flip and {
					Text = "Flip",
					Keybinds = {Enum.UserInputType.MouseButton1},
					Pressed = function()
						flip:FireServer()
					end,
				} or nil
			elseif food.Name == "Empty Soda" or food.Name == "Milkshake Cup" then
				local finish = food:FindFirstChild("Finish") :: RemoteEvent?
				Interactions[food].Actions["Finish"] = value >= 100 and finish and {
					Text = "Add Lid",
					Keybinds = {Enum.UserInputType.MouseButton1},
					Pressed = function()
						finish:FireServer()
					end,
				} or nil
			end
		end)
		
		if food.Name == "Empty Soda" or food.Name == "Ice Cream Cone" then
			local selectingFlavor = food:FindFirstChild("SelectingFlavor") :: BoolValue?
			if selectingFlavor then
				selectingFlavor:GetPropertyChangedSignal("Value"):Connect(function()
					local snapParent = snap.Parent
					if not snapParent then return end
					local flavors = snapParent:FindFirstChild("Flavors")
					if not flavors then return end
					
					for _, flavor in flavors:GetChildren() do
						if not flavor:IsA("BasePart") then continue end
						local selectFlavor = food:FindFirstChild("SelectFlavor") :: RemoteEvent?
						Interactions[flavor] = selectingFlavor.Value and selectFlavor and {
							Title = "Select " .. flavor.Name,
							Actions = {
								["Select"] = {
									Text = "Select",
									Keybinds = {Enum.UserInputType.MouseButton1},
									Pressed = function()
										selectFlavor:FireServer(flavor.Name)
									end,
								},
							},
						} or nil
					end
				end)
			end
		elseif food.Name == "Milkshake Cup" then
			local canStart = food:FindFirstChild("CanStart") :: BoolValue?
			if canStart then
				canStart:GetPropertyChangedSignal("Value"):Connect(function()
					local start = food:FindFirstChild("Start") :: RemoteEvent?
					Interactions[food].Actions["Start"] = canStart.Value and start and {
						Text = "Start Machine",
						Keybinds = {Enum.UserInputType.MouseButton1},
						Pressed = function()
							start:FireServer()
						end,
					} or nil
				end)
			end
		end
		
		if food.Name == "Cooked Patty" then
			local finished = food:FindFirstChild("Finished") :: BoolValue?
			if finished then
				finished:GetPropertyChangedSignal("Value"):Connect(function()
					local snapParent = snap.Parent
					if not snapParent then return end
					local wrap = food:FindFirstChild("Wrap") :: RemoteEvent?
					Interactions[snapParent].Actions["Wrap"] = finished.Value and wrap and {
						Text = "Wrap Burger",
						Keybinds = {Enum.KeyCode.E},
						Pressed = function()
							wrap:FireServer()
						end,
					} or nil
				end)
			end
		end
	end)
end)

for _, snap in CollectionService:GetTagged("Snap") do
	if snap:IsDescendantOf(OwnedRestaurants) then
		task.spawn(function()
			snap.CanCollide = false
			snap.CanQuery = true
		end)
	end
end

Player.CharacterAdded:Connect(function(char)
	Character = char
end)

return {
	DragItem = DragItem,
	DropItem = DropItem,
	StopDragging = StopDragging,
	Interactions = Interactions,
}
