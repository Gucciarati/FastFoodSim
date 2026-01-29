--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateValue = require(ReplicatedStorage.Packages.StateValue)
local Events = require(ReplicatedStorage.SharedModules.Events)

local Helpers 		= script.Parent.Helpers
local FindAssembly 	= require(ReplicatedStorage.Utils.FindAssembly)
local UpdateVisuals = require(Helpers.UpdateVisuals)

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
	
	local Character = Player.Character
	if not Character then return end

	local HumanoidRootPart = Character.HumanoidRootPart
	if not HumanoidRootPart then return end
	
	local Distance = (HumanoidRootPart.Position - Position).Magnitude
	local IsWithinRange = Distance <= INTERACTION_DISTANCE

	local Assembly = FindAssembly(Target)
	DeterminedTarget = if IsWithinRange then (Assembly or Target) else nil
	
	--print("[FocusClient] Found interaction:", DeterminedTarget.Title)
	if CurrentTarget ~= DeterminedTarget then
		CurrentTarget = DeterminedTarget
		StateValue.Set("CurrentInteractable", DeterminedTarget)
		UpdateVisuals(Assembly)
	end
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

StateValue.Create("CurrentInteractable", nil)

AimTarget.Changed:Connect(UpdateFocus)
AimPosition.Changed:Connect(UpdateFocus)
UserInputService.InputBegan:Connect(OnInputBegan)

return true
