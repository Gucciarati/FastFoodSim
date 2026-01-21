--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local Utils         = ReplicatedStorage.Utils
local SetCollision  = require(Utils.SetCollision)

local Net                       = require(ReplicatedStorage.Packages.Net)
local RequestHoldFoodRE         = Net:RemoteEvent("HoldFood")
local RequestFoodPlacementRE    = Net:RemoteEvent("PlaceFood")

local GameState         = ReplicatedStorage.GameState
local AimTarget         = GameState.AimTarget
local AimPosition       = GameState.AimPosition
local RotationOffset    = GameState.RotationOffset

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local HoldPreview: any
local PositionPreview: any

local Highlight

local APPROVED_COLOR = Color3.fromRGB(0, 255, 0)
local DENIED_COLOR  = Color3.fromRGB(255, 0, 0)

local function AddHighlight(Model: any, Color: Color3?)
    
    if not Highlight then
        Highlight = Instance.new("Highlight")
        Highlight.Name = "PlacementHighlight"
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.Parent = workspace
    end

    if Color then
        Highlight.FillColor = Color
    else
        Highlight.FillTransparency = 1
    end

    Highlight.Adornee = Model
end

local function HoldFood()
    local FoodModel = AimTarget.Value
    if not FoodModel then return end
   
    RequestHoldFoodRE:FireServer(FoodModel)
    HoldPreview = FoodModel:Clone()
    HoldPreview.Parent = workspace

    PositionPreview = FoodModel:Clone()
    --Ghostify(PositionPreview)
    PositionPreview.Parent = workspace

    SetCollision(HoldPreview, false)
    SetCollision(PositionPreview, false)
end


local function PlaceFood()
    local IsValid = ValidatePlacement(PositionPreview)
    if not IsValid then return end
    --TODO: Notify in case of invalid placement


    RequestFoodPlacementRE:FireServer(PositionPreview:GetPivot())
end

local function UpdateLocalHoldVisual()
    if not HoldPreview then return end

    local Character = LocalPlayer.Character
    if not Character then return end

    local Size = HoldPreview:GetExtentsSize()
    local HoldOffset = CFrame.new(0, -1 - Size.Y / 2, -2 - Size.Z / 2)

    local TargetCFrame = Camera.CFrame * HoldOffset
    local DragPart = HoldPreview:FindFirstChild("Drag")
    if not DragPart then return end

    DragPart.CFrame = TargetCFrame
end

local function UpdatePreview()
   if not PositionPreview then return end

    local CurrentAimPosition = AimPosition.Value
    local CurrentRotationOffset = RotationOffset.Value
    local CurrentAimTarget = AimTarget.Value
    if not CurrentAimTarget then return end
    
    local UpdateCFrame = CFrame.new(CurrentAimPosition) * CurrentRotationOffset
    local SnapPrompt = CurrentAimTarget:GetAttribute("SnapPrompt")

    if SnapPrompt then
        UpdateCFrame = SnapPrompt.CFrame
    else
        UpdateCFrame = CFrame.new(CurrentAimPosition) * CurrentRotationOffset
    end

    PositionPreview:PivotTo(UpdateCFrame)

    local IsValid = ValidatePlacement(PositionPreview)
    local Color = IsValid and APPROVED_COLOR or DENIED_COLOR
    AddHighlight(PositionPreview, Color)
end

AimPosition.Changed:Connect(function()
    UpdatePreview()
    UpdateLocalHoldVisual()

end)

RotationOffset.Changed:Connect(function()
    UpdatePreview()
end)

InteractPressed:Connect(function(InteractableId: string, InteractableType: string)
    local CurrentAimTarget = AimTarget.Value
    if not CurrentAimTarget then return end

    local IsHoldingIngredient = LocalPlayer:GetAttribute("HeldFoodId")
    if IsHoldingIngredient then
        PlaceFood()
    else
        HoldFood()
    end
end)

return true