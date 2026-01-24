local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local GameState     = ReplicatedStorage.GameState
local AimTarget     = GameState.AimTarget
local AimPosition   = GameState.AimPosition

local LocalPlayer   = Players.LocalPlayer
local Camera        = workspace.CurrentCamera

print("dd")
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
    AimPosition.Value = Position or vector.zero
	return Target
end

Camera:GetPropertyChangedSignal("CFrame"):Connect(
    function()
       print "[AimTrackerClient] Camera CFrame changed, updating focus"
        UpdateFocus()
    end
)

game.RunService.Heartbeat:Connect(
    function()
        UpdateFocus()
    end
)

return true