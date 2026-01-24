--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net                   = ReplicatedStorage.Packages.Net
local RegisterCookingRE     = Net:RemoteFunction("RegisterCookingProcess")
local RegisterKeypointRE    = Net:RemoteFunction("RegisterCookingKeypoint")

local ActiveCookingProcesses : {[number]: {[string]: any}} = {}

local CookingConfigs = require(ReplicatedStorage.Config.CookingConfigs)
local GenerateUniqueId = require(ReplicatedStorage.Utils.GenerateUniqueId)


type CookingProcessData = {
    ProcessType: string,
    Keypoints: {[number]: {Duration: number}},
}


local function RegisterCookingProcess(Player: Player, ProcessData: CookingProcessData)
    
    local UserId = Player.UserId
    ActiveCookingProcesses[UserId] = ActiveCookingProcesses[UserId] or {}

    local TimeNow = DateTime.now().UnixTimestamp
    local Id = GenerateUniqueId(ActiveCookingProcesses[UserId])
    local Registration = {
        Keypoints = {},
    }

    local ProcessConfig = CookingConfigs.registry[ProcessData.ProcessType]
    local EndTime = TimeNow + ProcessConfig.Keypoints[1].Duration
    Registration.Keypoints[1] = EndTime

    ActiveCookingProcesses[UserId][Id] = {
        ProcessData = ProcessData,
        Keypoints = Registration.Keypoints,
    }

    return Id, EndTime
end

local function FinishCookingProcess(Player: Player, ProcessId: string)
    local UserId = Player.UserId
    local CookingProcess = ActiveCookingProcesses[UserId][ProcessId]

    if not CookingProcess then 
        warn(`Couldn´t find Cooking Process: {ProcessId} for player {Player.UserId}`)
        return
    end

    ActiveCookingProcesses[UserId][ProcessId] = nil
end

local function RegisterCookingKeypoint(Player: Player, ProcessId: string)
    local UserId = Player.UserId
    local CookingProcess = ActiveCookingProcesses[UserId][ProcessId]
    if not CookingProcess then 
        warn(`Couldn´t find Cooking Process: {ProcessId} for player {Player.UserId}`)
        return
    end

    local KeypointIndex = #CookingProcess.Keypoints

    local TimeNow = DateTime.now().UnixTimestamp
    local CurrentKeypointEndTime = CookingProcess.Keypoints[KeypointIndex]

    if CurrentKeypointEndTime > TimeNow then
        warn(`Player {Player.UserId} tried to complete keypoint {KeypointIndex} too early for process {ProcessId}`)
        return
    end

    local ProcessData = CookingProcess.ProcessData
    local NextKeypointData = ProcessData.Keypoints[KeypointIndex + 1]

    if not NextKeypointData then
        FinishCookingProcess(Player, ProcessId)
        return
    end

    local EndTime = TimeNow + NextKeypointData.Duration
    CookingProcess.Keypoints[KeypointIndex + 1] = EndTime

    return EndTime
end


RegisterCookingRE.OnServerInvoke = RegisterCookingProcess
RegisterKeypointRE.OnServerInvoke = RegisterCookingKeypoint