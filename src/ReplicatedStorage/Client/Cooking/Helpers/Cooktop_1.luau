local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
    local CookTime = CookingProcessData.EndTime - CookingProcessData.StartTime

    local CookingMachine = GetCookingMachineFromId(MachineId)
    assert(CookingMachine, `No cooking machine`)

	local Snap = CookingMachine:QueryDescendants(`.Snap`)[1]
	
	local RawPatty = Snap:FindFirstChild(`Raw Patty`)
	if not RawPatty then return end
	
	local Patty = RawPatty:FindFirstChild(`Patty`)
	local Timer = RawPatty:FindFirstChild(`Timer`)
	
	RawPatty:SetAttribute(`Occupied`, true)
	Visible(RawPatty)
	
	local CooktopSound = Snap:FindFirstChild(`Cooktop`)
	if CooktopSound then CooktopSound:Play() end
	
	if Timer then
		Tween(Timer, {CookTime, `Linear`}, {Value = 100}):Play()
	end
	
	if Patty then
		Tween(Patty, {CookTime, `Linear`}, {Color = Color3.fromRGB(141, 65, 54)}):Play()
	end
end
