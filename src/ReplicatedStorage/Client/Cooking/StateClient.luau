--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages      = ReplicatedStorage.Packages

local GameState     = ReplicatedStorage.GameState
local AimTarget     = GameState.AimTarget

local Net                   = require(Packages.Net)
local StartCookingProcessRF = Net:RemoteEvent("StartCookingProcess")

local Events = require(ReplicatedStorage.SharedModules.Events)
local Helpers = script.Parent.Helpers
local GrillingVisuals = require(Helpers.GrillingVisuals)
local FryerVisuals = require(Helpers.FryerVisuals)

export type CookingProcessData = {
    ProcessType: string,
    MachineId: string,
    IngredientId: string,
}

local function RequestCookingStart(MachineId: any, FoodId: string, SpotId: string)

    local ProcessData = {
        MachineId = MachineId,
        FoodId = FoodId,
        SpotId = SpotId,
    }

    StartCookingProcessRF:FireServer(ProcessData)
    --Play necessary twens and animations

local function RegisterCookingInteraction(FoodId: string)
     StartCookingProcessRF:FireServer(FoodId)
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
