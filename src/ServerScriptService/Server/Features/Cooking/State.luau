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




local 


RegisterCookingRE.OnServerInvoke = RegisterCookingProcess
RegisterKeypointRE.OnServerInvoke = RegisterCookingKeypoint