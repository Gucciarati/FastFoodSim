--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local Utils         = ReplicatedStorage.Utils
local Food = require(ReplicatedStorage.Config.Products.Food)
local SetCollision  = require(Utils.SetCollision)
local FindAssembly  = require(Utils.FindAssembly)

local StateValue = require(ReplicatedStorage.Packages.StateValue)

local Net                       = require(ReplicatedStorage.Packages.Net)
local HoldFoodRE                = Net:RemoteEvent("HoldFood")
local ReleaseFoodRE             = Net:RemoteEvent("ReleaseFood")
local PlaceFoodRE               = Net:RemoteEvent("PlaceFood")
local OpenPackageRE             = Net:RemoteEvent("OpenPackage")
local StartCookingRE            = Net:RemoteEvent("RegisterCookingProcess")

local Events = require(ReplicatedStorage.SharedModules.Events)
local SetAnchored = require(ReplicatedStorage.Utils.SetAnchored)

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



local function Ghostify(Model: Model)
    for _, Descendant in Model:GetDescendants() do
        if Descendant:IsA("BasePart") then
            Descendant.Transparency = 0.5
        end
    end
end

local function AddHighlight(Model: any, Color: Color3?)
    if not Highlight then
        Highlight = Instance.new("Highlight")
        Highlight.Name = "PlacementHighlight"
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.Parent = workspace
    end

    if Color then
        Highlight.FillColor = Color
        Highlight.FillTransparency = 0.5
    else
        Highlight.FillTransparency = 1
    end

    Highlight.Enabled = true
    Highlight.Adornee = Model
end

local function RemoveHighlight()
    if Highlight then
        Highlight.Adornee = nil
        Highlight.Enabled = false
    end
end

local function SetupHoldVisuals(FoodModel: Model)
    
    local NewModel = Instance.new("Model")
    NewModel.Name = FoodModel.Name
    FoodModel:Clone().Parent = NewModel

    SetAnchored(NewModel, true)

    HoldPreview =  NewModel
    HoldPreview.Name = "HoldPreview"
    HoldPreview.Parent = Camera
    SetCollision(HoldPreview, false)

    PositionPreview = NewModel:Clone()
    PositionPreview.Name = "PositionPreview"
    Ghostify(PositionPreview)
    PositionPreview.Parent = Camera
    SetCollision(PositionPreview, false)
end

local function ClearHoldVisuals()
    if HoldPreview then
        HoldPreview:Destroy()
        HoldPreview = nil
    end

    if PositionPreview then
        PositionPreview:Destroy()
        PositionPreview = nil
    end

    RemoveHighlight()
end

local function RequestHoldFood()
     local CurrentInteractable = StateValue.Peek("CurrentInteractable")
    if not CurrentInteractable then return end
   
    local Id = CurrentInteractable:GetAttribute("Id")
    if not Id then return end
    HoldFoodRE:FireServer(CurrentInteractable)
end

local function ValidatePlacement(Preview: Model?): boolean
    if not Preview then return false end
    return true
end

local function RequestPlaceFood()
    if not PositionPreview then return end

    local CurrentAimTarget = AimTarget.Value
    local CurrentInteractable = StateValue.Peek("CurrentInteractable")
    local IsCookingPrompt = CurrentInteractable:HasTag("Snap") or CurrentAimTarget:HasTag("CookingMachine")

    if IsCookingPrompt then
        local CookingMachine = CurrentInteractable.Parent
        local Id = CookingMachine:GetAttribute("Id")
        StartCookingRE:FireServer(Id)
        return
    end

    local IsValid = ValidatePlacement(PositionPreview)
    if not IsValid then return end

    PlaceFoodRE:FireServer(PositionPreview:GetPivot())
end

local function UpdateLocalHoldVisual()
    if not HoldPreview then return end

    local Size = HoldPreview:GetExtentsSize()
    local HoldOffset = CFrame.new(0, -1 - Size.Y / 2, -2 - Size.Z / 2)

    local TargetCFrame = Camera.CFrame * HoldOffset
    HoldPreview:PivotTo(TargetCFrame)
end

local function UpdatePreview()
    if not PositionPreview then return end

    local CurrentAimPosition = AimPosition.Value
    local CurrentRotationOffset = RotationOffset.Value
    local CurrentAimTarget = AimTarget.Value
    
    local UpdateCFrame = CFrame.new(CurrentAimPosition) * CurrentRotationOffset

    -- if CurrentAimTarget then
    --     local SnapPrompt = CurrentAimTarget:FindFirstChild("SnapPrompt")
    --     if SnapPrompt and SnapPrompt:IsA("BasePart") then
    --         local MachineId = SnapPrompt.Parent:GetAttribute("KeySpotId")
    --         local FoodId = PositionPreview:GetAttribute("Id")
    --         Events.SnappedToKeySpot:Fire(MachineId, FoodId, SnapPrompt)
    --         UpdateCFrame = SnapPrompt.CFrame * CurrentRotationOffset
    --     end
    -- end

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

Events.InteractPressed:Connect(function(InteractableModel: any)
    local CurrentAimTarget = AimTarget.Value
    if not CurrentAimTarget then return end

    local IsHoldingIngredient = LocalPlayer:GetAttribute("GrabId")
    if IsHoldingIngredient then
        RequestPlaceFood()
    else
        RequestHoldFood()
    end
end)

Events.SecondaryInteractPressed:Connect(function(InteractableModel: any)
    print("Fired")
    local CurrentInteractable = StateValue.Peek("CurrentInteractable")
    if not CurrentInteractable then return end

    local IsPackage = CurrentInteractable:GetAttribute("Amount") ~= nil
    if not IsPackage then return end

    OpenPackageRE:FireServer(CurrentInteractable)
end)

HoldFoodRE.OnClientEvent:Connect(function(ItemModel: Model)
    SetupHoldVisuals(ItemModel)
end)


ReleaseFoodRE.OnClientEvent:Connect(function()
    ClearHoldVisuals()
end)

return true