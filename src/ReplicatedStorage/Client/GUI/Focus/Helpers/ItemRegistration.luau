--!strict
local InteractionRegistry = require(script.Parent.InteractionRegistry)

local ItemRegistration = {}

function ItemRegistration.RegisterItem(Child: Instance)
	if not Child:IsA("Model") then return end
	
	local IsFoodPackage = Child:GetAttribute("Amount") ~= nil
	local IsFurnitureBox = Child.Name == "Furniture Box"
	local IsPacked = IsFoodPackage or IsFurnitureBox
	
	local DisplayName = Child.Name
	if IsFurnitureBox then
		DisplayName = (Child:GetAttribute("ItemName") :: string?) or "Furniture"
	end
	
	local Actions: { [string]: InteractionRegistry.ActionInfo } = {
		Grab = {
			Text = "Pick Up",
			Keybind = Enum.UserInputType.MouseButton1,
		},
	}
	
	if IsPacked then
		Actions.Open = {
			Text = "Open",
			Keybind = Enum.KeyCode.E,
		}
	end
	
	InteractionRegistry.Register(Child, {
		Title = DisplayName .. (if IsPacked then " Package" else ""),
		Actions = Actions,
	})
	
	Child.Destroying:Once(function()
		InteractionRegistry.Unregister(Child)
	end)
end

function ItemRegistration.RegisterFolder(Folder: Folder)
	local function OnChildAdded(Child: Instance)
		task.wait()
		ItemRegistration.RegisterItem(Child)
	end
	
	Folder.ChildAdded:Connect(OnChildAdded)
	
	for _, Child in Folder:GetChildren() do
		task.spawn(ItemRegistration.RegisterItem, Child)
	end
end

function ItemRegistration.RegisterAllPlots()
	local Plots = workspace:FindFirstChild("Plots")
	if not Plots then return end
	
	for _, PlotFolder in Plots:GetChildren() do
		local FoodFolder = PlotFolder:FindFirstChild("Food")
		local FurnitureFolder = PlotFolder:FindFirstChild("Furniture")
		
		if FoodFolder then
			ItemRegistration.RegisterFolder(FoodFolder)
		end
		
		if FurnitureFolder then
			ItemRegistration.RegisterFolder(FurnitureFolder)
		end
	end
end

return ItemRegistration
