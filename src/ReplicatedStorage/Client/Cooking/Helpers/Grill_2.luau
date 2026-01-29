local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetCookingMachineFromId = require(script.Parent.Utils.GetCookingMachineFromId)
local Tween = require(script.Parent.Utils.Tween)
local SetTransparency = require(ReplicatedStorage.Utils.SetTransparency)
local StateValue = require(ReplicatedStorage.Packages.StateValue)

type CookingProcessData = {
    ProcessType: string,
    Keypoints: { [number]: number },
    MachineId: string,
    StartTime: number,
    EndTime: number,
}

return function(CookingProcessData: CookingProcessData)
	print(`[GRILL] Grill_2 - Starting flip phase`)
    local CookingMachine = GetCookingMachineFromId(CookingProcessData.MachineId)
	local Snap = CookingMachine:QueryDescendants(`.Snap`)[1]
	if not Snap then return end
	
	local RawPatty = Snap:FindFirstChild("Raw Patty")
	local FlippedRawPatty = Snap:FindFirstChild("Flipped Raw Patty")
	if not RawPatty or not FlippedRawPatty then return end
	
	local RawPattyPart = RawPatty.Patty
	local FlippedPatty = FlippedRawPatty.Patty

	local CustomHoverData = StateValue.Peek("CustomHoverData")[Snap]
    local ProgressMeter = CustomHoverData.ProgressMeter
	
	ProgressMeter.Value = 0

	if RawPattyPart then
		Tween(RawPattyPart, {0}, {Color = Color3.fromRGB(255, 89, 89)}):Play()
	end
	
	SetTransparency(FlippedRawPatty, 0)
    SetTransparency(RawPatty, 1)
	print(`[GRILL] Grill_2 - Patty flipped and visible`)
	
	if FlippedPatty then
		Tween(FlippedPatty, {0.1, "Linear"}, {CFrame = FlippedRawPatty:GetPivot() * CFrame.Angles(math.rad(90), 0, 0)}):Play()
		Tween(FlippedPatty, {.1, "Linear"}, {Color = Color3.fromRGB(80, 42, 7)}):Play()
	end
	
    local CookTime = CookingProcessData.Keypoints[2] - CookingProcessData.Keypoints[1]

	Tween(ProgressMeter, {CookTime, "Linear"}, {Value = 100}):Play()


	-- Update CustomHoverData to use flipped timer for progress
	

end
