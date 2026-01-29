local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetCookingMachineFromId = require(script.Parent.Utils.GetCookingMachineFromId)
local Tween = require(script.Parent.Utils.Tween)
local SetTransparency = require(ReplicatedStorage.Utils.SetTransparency)
local AddProgressMeter = require(script.Parent.Utils.AddProgressMeter)
local StateValue = require(ReplicatedStorage.Packages.StateValue)

type CookingProcessData = {
	ProcessType: string,
	Keypoints: { [number]: number },
	MachineId: string,
	StartTime: number,
	EndTime: number,
	Id: string,
}

return function(CookingProcessData: CookingProcessData)
	
	local MachineId = CookingProcessData.MachineId
	local CookTime = CookingProcessData.Keypoints[1] - CookingProcessData.StartTime

print(
		`[GRILL] Grill_1 - Starting cook phase, Duration: {CookTime}s`
	)

	local CookingMachine = GetCookingMachineFromId(MachineId)
	assert(CookingMachine, `No cooking machine`)

	local Snap = CookingMachine:QueryDescendants(`.Snap`)[1]
	print(Snap)
	local RawPatty = Snap:FindFirstChild("Raw Patty")
	local FlippedRawPatty = Snap:FindFirstChild("Flipped Raw Patty")

    local RawPattyPart = RawPatty.Patty

	local ProgressMeter = AddProgressMeter(Snap)

	RawPatty:SetAttribute("Occupied", true)
	SetTransparency(RawPatty, 0)
    SetTransparency(FlippedRawPatty, 1)

	print(`[GRILL] Grill_1 - Raw patty shown and marked occupied`)

	local CooktopSound = Snap:FindFirstChild("Cooktop")
	if CooktopSound then
		CooktopSound:Play()
		print(`[GRILL] Grill_1 - Cooktop sound started`)
	end

	local MeterTween = Tween(ProgressMeter, { CookTime, "Linear" }, { Value = 100 })
	MeterTween:Play()

	Tween(RawPattyPart, { CookTime, "Linear" }, { Color = Color3.fromRGB(141, 65, 54) }):Play()

	-- Update CustomHoverData to show progress meter (no actions yet)
	local CustomHoverData = StateValue.Peek("CustomHoverData")
	CustomHoverData[Snap] = {
		ActionList = {},
		ProgressMeter = ProgressMeter,
		ProcessId = CookingProcessData.Id,
		KeypointIndex = 1,
	}
	StateValue.Set("CustomHoverData", CustomHoverData)

	MeterTween.Completed:Wait()

	local UpdatedHoverData = StateValue.Peek("CustomHoverData")
	if not UpdatedHoverData[Snap] then
		return
	end
	UpdatedHoverData[Snap].ActionList = {
		{ Action = "Flip", Bind = "Primary" },
	}
	print(`[GRILL] Grill_1 - Flip prompt now available`)
end
