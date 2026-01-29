local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetCookingMachineFromId = require(script.Parent.Utils.GetCookingMachineFromId)
local Tween = require(script.Parent.Utils.Tween)
local Invisible = require(script.Parent.Utils.Invisible)
local StateValue = require(ReplicatedStorage.Packages.StateValue)

type CookingProcessData = {
    ProcessType: string,
    Keypoints: { [number]: number },
    MachineId: string,
    StartTime: number,
    EndTime: number,
}

return function(CookingProcessData: CookingProcessData)
	print(`[GRILL] Grill_done - Starting cleanup phase`)
	local MachineId = CookingProcessData.MachineId
	
	local CookingMachine = GetCookingMachineFromId(MachineId)
	if not CookingMachine then 
		print(`[GRILL] Grill_done - ERROR: CookingMachine not found`)
		return 
	end
	
	local Snap = CookingMachine:QueryDescendants(`.Snap`)[1]
	if not Snap then return end
	
	local RawPatty = Snap:FindFirstChild(`Raw Patty`)
	local FlippedRawPatty = Snap:FindFirstChild(`Flipped Raw Patty`)
	
	local CooktopSound = Snap:FindFirstChild(`Cooktop`)
	if CooktopSound then 
		CooktopSound:Stop()
		print(`[GRILL] Grill_done - Cooktop sound stopped`)
	end
	
	if FlippedRawPatty then
		local FlippedPatty = FlippedRawPatty:FindFirstChild(`Patty`)
		local FlippedTimer = FlippedRawPatty:FindFirstChild(`Timer`)
		
		Invisible(FlippedRawPatty)
		
		if FlippedPatty then
			Tween(FlippedPatty, {0}, {CFrame = FlippedRawPatty:GetPivot()}):Play()
		end
		
		if FlippedTimer then
			Tween(FlippedTimer, {0}, {Value = 0}):Play()
		end
		
		FlippedRawPatty:SetAttribute(`Occupied`, false)
		print(`[GRILL] Grill_done - Flipped patty hidden`)
	end
	
	if RawPatty then
		local Patty = RawPatty:FindFirstChild(`Patty`)
		
		if Patty then
			Tween(Patty, {0}, {Color = Color3.fromRGB(141, 65, 54)}):Play()
		end
		
		RawPatty:SetAttribute(`Occupied`, false)
		print(`[GRILL] Grill_done - Raw patty color reset`)
	end

	local CustomHoverData = StateValue.Peek("CustomHoverData")
	CustomHoverData[Snap] = {
		ActionList = {
			{ Action = "Cook", Bind = "Primary" },
		},
		ProgressMeter = nil,
	}
	StateValue.Set("CustomHoverData", CustomHoverData)

	print(`[GRILL] Grill_done - Cleanup complete`)
end
