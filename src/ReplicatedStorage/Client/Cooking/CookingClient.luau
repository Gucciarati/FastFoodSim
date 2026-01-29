--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net               = require(ReplicatedStorage.Packages.Net)
local CookingUpdateRE   = Net:RemoteEvent("UpdateCookingProcess")
local Cleanup           = require(ReplicatedStorage.Utils.Cleanup)

local Helpers = script.Parent.Helpers


type CookingProcessData = {
    ProcessType: string,
    Keypoints: {[number]: {Duration: number}},
    FoodId: string,
    MachineId: string,
    SpotId: string,
    Id: string,
}

local function Cook(CookingProcessData: CookingProcessData)
    local PhaseNumber = #CookingProcessData.Keypoints
    
    local PhaseMethod = Helpers[`{CookingProcessData.ProcessType}_{PhaseNumber}`]
    local PhaseResidue = require(PhaseMethod)(CookingProcessData) or {}

   Cleanup(PhaseResidue) 
end

CookingUpdateRE.OnClientEvent:Connect(Cook)

return true
