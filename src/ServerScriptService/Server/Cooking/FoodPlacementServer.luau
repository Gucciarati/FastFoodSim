
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net           = require(ReplicatedStorage.Packages.Net)
local HoldFoodRE    = Net:RemoteEvent("HoldFood")
local PlaceFoodRE   = Net:RemoteEvent("PlaceFood")

local FoodHolder = workspace.Holders.Food


local function DisplayGrabFoodVisuals(Player: Player, FoodModel: Model)
    local Character = Player.Character
    if not Character then return end

    local HeldFoodId = FoodModel:GetAttribute("Id")
    Player:SetAttribute("HeldFoodId", HeldFoodId)

    local RootPart = FoodModel:FindFirstChild("Root")
    if not RootPart then 
        RootPart = Instance.new("Part")
        RootPart.Name = "Root"
        RootPart.Size = vector.create(.1,.1,.1)
        RootPart.Transparency = 1
        RootPart.Parent = FoodModel
    end

    local Hand = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm")
    if not Hand then return end

    local Weld = Hand:FindFirstChild("FoodWeld") or Instance.new("WeldConstraint")
    Weld.Name = "FoodWeld"
    Weld.Part0 = Hand
    Weld.Part1 = RootPart
    Weld.Parent = Hand
end

local function ClearGrabFoodVisuals(Player: Player, Cframe: CFrame)
    local Character = Player.Character
    if not Character then return end

    local HeldFoodId = Player:GetAttribute("HeldFood")
    if not HeldFoodId then return end

    Player:SetAttribute("HeldFoodId", nil)

    local Hand = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm")
    if not Hand then return end

    local Weld = Hand:FindFirstChild("FoodWeld")
    if Weld then
        Weld:Destroy()
    end


    local FoodModel = FoodHolder:FindFirstChild(HeldFoodId)
    FoodModel:PivotTo(Cframe)
end

HoldFoodRE.OnServerEvent:Connect(DisplayGrabFoodVisuals)
PlaceFoodRE.OnServerEvent:Connect(ClearGrabFoodVisuals)