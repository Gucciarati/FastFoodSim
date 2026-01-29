--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Events = require(ReplicatedStorage.SharedModules.Events)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("main")
local MobileEnabled = Main:FindFirstChild("MobileEnabled")

local StateValue = require(ReplicatedStorage.Packages.StateValue)


local BUTTON_SIGNAL_MAP: any = {
	Click = Events.InteractPressed,
	Take = Events.SecondaryInteractPressed,
	OpenBox = Events.InteractPressed,
	SellPackage = Events.SecondaryInteractPressed,
	RotateLeft = Events.SecondaryInteractPressed,
	RotateRight = Events.QuaternaryInteractPressed,
	CollectTray = Events.SecondaryInteractPressed,
	MoveFurniture = Events.SecondaryInteractPressed,
	DeleteFurniture = Events.SecondaryInteractPressed,
}


return function()
	if not UserInputService.TouchEnabled then return end
	for ButtonName, Signal in BUTTON_SIGNAL_MAP do
		local Button = MobileEnabled:FindFirstChild(ButtonName)
	
		Button.Activated:Connect(function()
			local CurrentInteractable = StateValue.Peek("CurrentInteractable")
			Signal:Fire(CurrentInteractable)
		end)
	end
end
