local GetCookingMachineFromId = require(script.Parent.Utils.GetCookingMachineFromId)
local Tween = require(script.Parent.Utils.Tween)
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
	local FillTime = CookingProcessData.EndTime - CookingProcessData.StartTime
	
	local CookingMachine = GetCookingMachineFromId(MachineId)
	if not CookingMachine then return end
	
	local Snap = CookingMachine:QueryDescendants(`.Snap`)[1]
	if not Snap then return end
	
	local Cone = Snap:FindFirstChild(`Cone`)
	if not Cone then return end
	
	local IceCream = Cone:FindFirstChild(`IceCream`)
	
	if IceCream then
		Tween(IceCream, {0.5, `Quad`, `InOut`}, {CFrame = Snap:GetPivot()}):Play()
		Tween(IceCream, {FillTime, `Linear`}, {Size = Vector3.new(0.3, 1, 0.3)}):Play()
	end
end
