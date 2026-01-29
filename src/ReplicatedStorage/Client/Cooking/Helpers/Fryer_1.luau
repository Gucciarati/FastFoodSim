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
	local FryTime = CookingProcessData.EndTime - CookingProcessData.StartTime
	
	local CookingMachine = GetCookingMachineFromId(MachineId)
	if not CookingMachine then return end
	
	local Snap = CookingMachine:QueryDescendants(`.Snap`)[1]
	if not Snap then return end
	
	local RawNuggets = Snap:FindFirstChild(`Raw Nuggets`)
	if not RawNuggets then return end
	
	RawNuggets:SetAttribute(`Occupied`, true)
	Visible(RawNuggets)
	
	local Basket = RawNuggets:FindFirstChild(`Basket`)
	local Timer = RawNuggets:FindFirstChild(`Timer`)
	
	local FryerSound = Snap:FindFirstChild(`Fryer`)
	if FryerSound then FryerSound:Play() end
	
	if Basket then
		Tween(Basket, {0.3, `Quad`, `InOut`}, {CFrame = RawNuggets:GetPivot() * CFrame.new(0, -2, 0)}):Play()
	end
	
	if Timer then
		Tween(Timer, {FryTime, `Linear`}, {Value = 100}):Play()
	end
end
