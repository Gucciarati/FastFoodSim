
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerEvents = require(ServerScriptService.Server.ServerEvents)
local SetAnchored = require(ReplicatedStorage.Utils.SetAnchored)

local Net           = require(ReplicatedStorage.Packages.Net)
local HoldFoodRE    = Net:RemoteEvent("HoldFood")
local PlaceFoodRE   = Net:RemoteEvent("PlaceFood")
local ReleaseFoodRE = Net:RemoteEvent("ReleaseFood")


local function DisplayGrabVisuals(Player: Player, ItemModel: Model)
	local Character = Player.Character
	--if Character then return end

	--SetAnchored(ItemModel, false)

	local HeldFoodId = ItemModel:GetAttribute("Id")
	Player:SetAttribute("GrabId", HeldFoodId)

	if false then
	local RootPart = ItemModel:FindFirstChild("Root")
	if not RootPart then 
		RootPart = Instance.new("Part")
		RootPart.Name = "Root"
		RootPart.Size = Vector3.new(.1,.1,.1)
		RootPart.Transparency = 1
		RootPart.CanCollide = false
		RootPart.Parent = ItemModel
	end

	local Hand = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm")
	if Hand then
		local Weld = Instance.new("WeldConstraint")
		Weld.Name = "GrabWeld"
		Weld.Part0 = Hand
		Weld.Part1 = RootPart
		Weld.Parent = Hand
		RootPart.CFrame = Hand.CFrame * CFrame.new(0, -0.5, -0.5)
	end
end

	HoldFoodRE:FireClient(Player, ItemModel)
end

local function ClearGrabVisuals(Player: Player, DropCFrame: CFrame)
	local Character = Player.Character
	if not Character then return end

	local HeldFoodId = Player:GetAttribute("GrabId")
	if not HeldFoodId then return end

	Player:SetAttribute("GrabId", nil)

	local Hand = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm")
	if Hand then
		local Weld = Hand:FindFirstChild("GrabWeld")
		if Weld then
			Weld:Destroy()
		end
	end

	local Plots = workspace.Plots
	local PlotFolder = Plots:QueryDescendants(`[$OwnerId = {Player.UserId}]`)[1]
	if not PlotFolder then return end

	local FoodModel = PlotFolder:QueryDescendants(`[$Id = {HeldFoodId}]`)[1]
	if FoodModel and DropCFrame then
		local FoodModelSize = FoodModel:GetExtentsSize()
		DropCFrame *= CFrame.new(0, FoodModelSize.Y / 2, 0)
		
		FoodModel:PivotTo(DropCFrame)
		SetAnchored(FoodModel, true)
	elseif FoodModel then
		FoodModel:Destroy()
	end

	ReleaseFoodRE:FireClient(Player)
end

ServerEvents.Grab:Connect(function(Player: Player, ItemModel: Model)
	DisplayGrabVisuals(Player, ItemModel)
end)

ServerEvents.Release:Connect(function(Player: Player, DropCFrame: CFrame)
	ClearGrabVisuals(Player, DropCFrame)
end)

HoldFoodRE.OnServerEvent:Connect(function(Player: Player, ItemModel: Model)
	DisplayGrabVisuals(Player, ItemModel)
end)

PlaceFoodRE.OnServerEvent:Connect(function(Player: Player, DropCFrame: CFrame)
	ClearGrabVisuals(Player, DropCFrame)
end)

return true