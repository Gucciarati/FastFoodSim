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
	
	local Cup = Snap:FindFirstChild(`Cup`)
	if not Cup then return end
	
	local Drink = Cup:FindFirstChild(`Drink`)
	local Liquid = Cup:FindFirstChild(`Liquid`)
	
	if Drink then
		Tween(Drink, {0.5, `Quad`, `InOut`}, {CFrame = Snap:GetPivot()}):Play()
	end
	
	if Liquid then
		Tween(Liquid, {FillTime, `Linear`}, {Size = Vector3.new(0.3, 1, 0.3)}):Play()
	end
end
