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
	
	local RawNuggets = Snap:FindFirstChild(`Raw Nuggets`)
	if not RawNuggets then return end
	
	local FryerSound = Snap:FindFirstChild(`Fryer`)
	if FryerSound then FryerSound:Stop() end
	
	local Basket = RawNuggets:FindFirstChild(`Basket`)
	if Basket then
		Tween(Basket, {0.3, `Quad`, `InOut`}, {CFrame = RawNuggets:GetPivot() * CFrame.new(0, 0, 0)}):Play()
	end
	
	Invisible(RawNuggets)
	RawNuggets:SetAttribute(`Occupied`, false)
end
