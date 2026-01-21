local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local GameState     = ReplicatedStorage:WaitForChild("GameState")
local AimTarget     = GameState:WaitForChild("AimTarget")
local AimPosition   = GameState:WaitForChild("AimPosition")

local LocalPlayer   = Players.LocalPlayer
local Camera        = workspace.CurrentCamera


local function UpdateFocus()
    local Character = LocalPlayer.Character
    if not Character then return end

    local RaycastParameters = RaycastParams.new()
    RaycastParameters.FilterType = Enum.RaycastFilterType.Exclude
    RaycastParameters.FilterDescendantsInstances = {Camera, Character} --I dont like this
    --TODO: use inclusion list instead for better performance

	local RaycastResult = workspace:Raycast(
        Camera.CFrame.Position,
        Camera.CFrame.LookVector * 1000,
        RaycastParameters
    )

    local Target = RaycastResult and RaycastResult.Instance
    local Position = RaycastResult and RaycastResult.Position

    AimTarget.Value = Target
    AimPosition.Value = Position
	return Target
end

Camera:GetPropertyChangedSignal("CFrame"):Connect(UpdateFocus)