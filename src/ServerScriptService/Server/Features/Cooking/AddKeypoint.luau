--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateValue = require(ReplicatedStorage.Packages.StateValue)
local Net = require(ReplicatedStorage.Packages.Net)
local RegisterKeypointRE = Net:RemoteEvent("RegisterCookingKeypoint")
local UpdateCookingRE = Net:RemoteEvent("UpdateCookingProcess")

local CookingConfigs = require(ReplicatedStorage.Config.CookingConfigs)

local function RegisterKeypoint(Player: Player, ProcessId: string, KeypointIndex: number)
	print(`[COOKING] RegisterKeypoint - Player: {Player.Name}, ProcessId: {ProcessId}, KeypointIndex: {KeypointIndex}`)
	local UserId = Player.UserId
	local CurrentState = StateValue.Peek("ActiveCookingProcesses")
	local CookingProcess = CurrentState[UserId][ProcessId]

	if not CookingProcess then
		warn(`Couldn't find Cooking Process: {ProcessId} for player {Player.UserId}`)
		return
	end

	local TimeNow = DateTime.now().UnixTimestamp
	local ProcessConfig = CookingConfigs[CookingProcess.ProcessType]
	local NextKeypointDuration = ProcessConfig.Keypoints[KeypointIndex + 1].Duration
	local NextEndTime = TimeNow + NextKeypointDuration

	table.insert(CookingProcess.Keypoints, NextEndTime)

	StateValue.Set("ActiveCookingProcesses", CurrentState)
	print(`[COOKING] Advanced to keypoint {KeypointIndex + 1}, Duration: {NextKeypointDuration}s`)


	UpdateCookingRE:FireClient(Player, CookingProcess)
end

RegisterKeypointRE.OnServerEvent:Connect(RegisterKeypoint)
return RegisterKeypoint
