--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage.SharedModules.Events)

local Helpers 		= script.Parent.Helpers
local FindAssembly 	= require(Helpers.FindAssembly)
local UpdateVisuals = require(Helpers.UpdateVisuals)

local InteractionRegistry = require(Helpers.InteractionRegistry)
local ItemRegistration = require(Helpers.ItemRegistration)

local INTERACTION_DISTANCE = 16

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("main")
local Cursor = Main:WaitForChild("Cursor")


local GameState = ReplicatedStorage:WaitForChild("GameState")
local AimTarget = GameState:WaitForChild("AimTarget") :: ObjectValue
local AimPosition = GameState:WaitForChild("AimPosition") :: ObjectValue



local CurrentTarget: Instance? = nil


local function UpdateFocus()
	local Target = AimTarget.Value
	local Position = AimPosition.Value
	
	local DeterminedTarget
	print("[FocusClient] UpdateFocus called - Target:", Target, "Position:", Position)
	
	local Character = Player.Character
	if not Character then return end

	local HumanoidRootPart = Character.HumanoidRootPart
	if not HumanoidRootPart then return end
	
	local Distance = (HumanoidRootPart.Position - Position).Magnitude
	local IsWithinRange = Distance <= INTERACTION_DISTANCE
	if not IsWithinRange then return end
	
	local Assembly = FindAssembly(Target)

	DeterminedTarget = Assembly or Target
	
	--print("[FocusClient] Found interaction:", DeterminedTarget.Title)
	if CurrentTarget ~= DeterminedTarget then
		CurrentTarget = DeterminedTarget
		UpdateVisuals(DeterminedTarget)
	end
end

local function OnAimTargetChanged()
	print("[FocusClient] AimTarget changed to:", AimTarget.Value)
	UpdateFocus()
end

local function OnAimPositionChanged()
	UpdateFocus()
end

local function OnInputBegan(Input: InputObject, GameProcessed: boolean)
	if GameProcessed then return end
	
	local Target = CurrentTarget
	
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Events.InteractPressed:Fire(Target)
	elseif Input.KeyCode == Enum.KeyCode.E then
		Events.SecondaryInteractPressed:Fire(Target)
	end
end

Cursor.Visible = true

AimTarget.Changed:Connect(OnAimTargetChanged)
AimPosition.Changed:Connect(OnAimPositionChanged)
UserInputService.InputBegan:Connect(OnInputBegan)

ItemRegistration.RegisterAllPlots()

local FocusClient = {}

FocusClient.InteractPressedSignal = Events.InteractPressed
FocusClient.OpenPackagePressedSignal = Events.SecondaryInteractPressed
FocusClient.InteractionRegistry = InteractionRegistry

return FocusClient
