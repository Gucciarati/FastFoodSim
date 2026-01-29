local GetCookingMachineFromId = require(script.Parent.Utils.GetCookingMachineFromId)
local Visible = require(script.Parent.Utils.Visible)

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
	
	local Cone = Snap:FindFirstChild(`Cone`)
	if not Cone then return end
	
	Cone:SetAttribute(`Occupied`, true)
	Visible(Cone)
end
