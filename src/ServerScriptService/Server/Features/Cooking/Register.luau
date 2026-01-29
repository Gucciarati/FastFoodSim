--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StateValue = require(ReplicatedStorage.Packages.StateValue)
local Net = require(ReplicatedStorage.Packages.Net)
local RegisterCookingRE = Net:RemoteEvent("RegisterCookingProcess")
local UpdateCookingRE = Net:RemoteEvent("UpdateCookingProcess")

local CookingConfigs = require(ReplicatedStorage.Config.CookingConfigs)
local GenerateUniqueId = require(ReplicatedStorage.Utils.GenerateUniqueId)

local ServerEvents = require(ServerScriptService.Server.ServerEvents)


local Plots = workspace.Plots

local COOKING_MACHINES_PER_PROCESSTYPE = {
	["Cooktop"] = "Grill",
	["Fryer"] = "Fryer",
	["Drink Dispenser"] = "DrinkDispenser",
	["Icecream & Milkshake Maker"] = "IceCreamMaker",
}

type CookingProcessData = {
	ProcessType: string,
	Keypoints: { [number]: { Duration: number } },
}

local function RegisterCookingProcess(Player: Player, MachineId: string)
	print(`[COOKING] RegisterCookingProcess - Player: {Player.Name}, MachineId: {MachineId}`)
	local UserId = Player.UserId
	local CurrentState = StateValue.Peek("ActiveCookingProcesses")
	local PlotFolder = Plots:QueryDescendants(`[$OwnerId = {UserId}]`)[1]

	local CookingMachine = PlotFolder.Furniture:QueryDescendants(`[$Id = {MachineId}]`)[1]
	local ProcessType = COOKING_MACHINES_PER_PROCESSTYPE[CookingMachine.Name]
	print(`[COOKING] ProcessType: {ProcessType}, Machine Name: {CookingMachine.Name}`)

	local ProcessConfig = CookingConfigs[ProcessType]

	ServerEvents.Release:Fire(Player)

	CurrentState[UserId] = CurrentState[UserId] or {}

	local TimeNow = DateTime.now().UnixTimestamp
	local Id = GenerateUniqueId(CurrentState[UserId])
	local FirstEndTime = TimeNow + ProcessConfig.Keypoints[1].Duration

	local Registration = {
		Id = Id,
		ProcessType = ProcessType,
		StartTime = TimeNow,
		MachineId = MachineId,
		Keypoints = {FirstEndTime},
	}

	CurrentState[UserId][Id] = Registration

	StateValue.Set("ActiveCookingProcesses", CurrentState)
	print(`[COOKING] Registered cooking process - Id: {Id}, ProcessType: {ProcessType}, Duration: {ProcessConfig.Keypoints[1].Duration}s`)

	UpdateCookingRE:FireClient(Player, Registration)
end

RegisterCookingRE.OnServerEvent:Connect(RegisterCookingProcess)
return RegisterCookingProcess
