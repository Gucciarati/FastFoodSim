--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages      = ReplicatedStorage.Packages

local GameState     = ReplicatedStorage.GameState
local AimTarget     = GameState.AimTarget

local Net                   = require(Packages.Net)
local StartCookingProcessRF = Net:RemoteFunction("StartCookingProcess")

local Events = require(ReplicatedStorage.SharedModules.Events)


export type CookingProcessData = {
    ProcessType: string,
    MachineId: string,
    IngredientId: string,
}

local function RequestCookingStart(MachineId: any, FoodId: string)

    local ProcessData = {
        MachineId = MachineId,
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



Events.InteractPressed:Connect(function(InteractableId: string, InteractableType: string)
    local CurrentAimTarget = AimTarget.Value
    if not CurrentAimTarget then return end

    local IsCooking = CurrentAimTarget:GetAttribute("EndTime")
    local FoodId = CurrentAimTarget:GetAttribute("Id")
    assert(FoodId, `No FoodId for {CurrentAimTarget.Name}`) 

    if IsCooking then
        RegisterCookingInteraction(FoodId)
    else
        RequestCookingStart(CurrentAimTarget, FoodId)
    end
end)


Events.SnappedToKeySpot:Connect(RequestCookingStart)
