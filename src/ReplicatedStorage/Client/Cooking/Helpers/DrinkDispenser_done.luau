local GetCookingMachineFromId = require(script.Parent.Utils.GetCookingMachineFromId)
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
	
	local Cup = Snap:FindFirstChild(`Cup`)
	if Cup then
		Invisible(Cup)
		Cup:SetAttribute(`Occupied`, false)
	end
end
