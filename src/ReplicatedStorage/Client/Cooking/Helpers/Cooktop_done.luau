local GetCookingMachineFromId = require(script.Parent.Utils.GetCookingMachineFromId)
local Tween = require(script.Parent.Utils.Tween)
local Invisible = require(script.Parent.Utils.Invisible)

type CookingProcessData = {
    ProcessType: string,
    Keypoints: { [number]: number },
    MachineId: string,
    StartTime: number,
    EndTime: number,
}

return function(CookingProcessData: CookingProcessData)
	local MachineId = CookingProcessData.MachineId
	
	local CookingMachine = GetCookingMachineFromId(MachineId)
	if not CookingMachine then return end
	
	local Snap = CookingMachine:QueryDescendants(`.Snap`)[1]
	if not Snap then return end
	
	local RawPatty = Snap:FindFirstChild(`Raw Patty`)
	if not RawPatty then return end
	
	local CooktopSound = Snap:FindFirstChild(`Cooktop`)
	if CooktopSound then CooktopSound:Stop() end
	
	if RawPatty then
		Invisible(RawPatty)
		RawPatty:SetAttribute(`Occupied`, false)
	end
end
