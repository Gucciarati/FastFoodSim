--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages      = ReplicatedStorage:WaitForChild("Packages")
local Net           = require(Packages.Net)
local GameState     = ReplicatedStorage:WaitForChild("GameState")
local AimTarget     = GameState:WaitForChild("AimTarget")

local StartCookingProcessRF = Net:RemoteFunction("StartCookingProcess")

export type CookingProcessData = {
    ProcessType: string,
    MachineId: string,
    IngredientId: string,
}

local function RequestCookingStart(FoodModel: any, FoodId: string)

    local ProcessData = {
        MachineId = FoodModel:GetAttribute("MachineId"),
        FoodId = FoodId,
    }

    local EndTime = StartCookingProcessRF:InvokeServer(ProcessData)
    local TimeTillEnd = EndTime - workspace:GetServerTimeNow()
    --Play necessary twens and animations
end

local function RegisterCookingInteraction(FoodId: string)
     local EndTime = StartCookingProcessRF:InvokeServer(FoodId)
    local TimeTillEnd = EndTime - workspace:GetServerTimeNow()
    --Play necessary twens and animations
end



InteractPressed:Connect(function(InteractableId: string, InteractableType: string)
    local target = AimTarget.Value
    if not target then return end

    local IsCooking = target:GetAttribute("EndTime")
    local FoodId = target:GetAttribute("Id")
    assert(FoodId, `No FoodId for {target.Name}`) 

    if IsCooking then
        RegisterCookingInteraction(FoodId)
    else
        RequestCookingStart(AimTarget, FoodId)
    end
end)
