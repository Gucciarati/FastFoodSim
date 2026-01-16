--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local Players             = game:GetService('Players')

local Shared                  = ReplicatedStorage:WaitForChild('SharedModules')
local Utils                   = ReplicatedStorage:WaitForChild('Utils')
local Vendor                  = ReplicatedFirst.Vendor

local GuiShared           = require(Shared.GuiShared)

local LocalPlayer         = Players.LocalPlayer
local PlayerGui           = LocalPlayer.PlayerGui

local Tagged = require(Vendor.Tagged)
local Connect = require(Vendor.ConnectUtil)
local RequireAttribute = require(Utils.RequireAttribute)

local OpenModalState          = ReplicatedStorage.GameState.OpenModal
local CurrentComputerTabState = ReplicatedStorage.GameState.CurrentComputerTab

local MainScreenGui = PlayerGui:WaitForChild('main')
local SideButtons = MainScreenGui.Left
local ModalsFolder = MainScreenGui.Modals
local ComputerFrame  = ModalsFolder.Computer
local TabFrames      = ComputerFrame.Frames
type SidebarButtonAssembly = typeof(ComputerFrame.Sidebar.Boosts)

local ComputerSections = {}

GuiShared.toggleVisibilityExcept(ComputerFrame.Frames:GetChildren(),'Market', false)

ComputerFrame.Top.CloseButton.Activated:Connect(function()
	OpenModalState.Value = ""
end)

Tagged.observe(GuiShared.Tags.ComputerSideButtons, function(button: SidebarButtonAssembly)
	button.Activated:Connect(function()
		CurrentComputerTabState.Value = button.Opens.Value.Name
	end)
	return
end)

Connect.valueChanged(CurrentComputerTabState, function(curr,prev)
	local tabToOpen  = TabFrames:FindFirstChild(curr) :: Frame?
	local tabToClose = TabFrames:FindFirstChild(prev) :: Frame?

	if tabToClose and tabToClose ~= tabToOpen then
		GuiShared.close(tabToClose)
	end

	if tabToOpen then
		GuiShared.open(tabToOpen, UDim2.fromScale(1,1))	
	end
	
end, false)


return true