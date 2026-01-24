--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local Players             = game:GetService('Players')

local Shared                  = ReplicatedStorage:WaitForChild('SharedModules')
local Utils                   = ReplicatedStorage:WaitForChild('Utils')
local Vendor                  = ReplicatedFirst.Vendor

local GuiShared           = require(Shared.GuiShared)
local StateValue          = require(ReplicatedStorage.Packages.StateValue)

local LocalPlayer         = Players.LocalPlayer
local PlayerGui           = LocalPlayer.PlayerGui

local Tagged = require(Vendor.Tagged)
local RequireAttribute = require(Utils.RequireAttribute)

local OpenModalState          = ReplicatedStorage.GameState.OpenModal

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
		local CurrentComputerTab = StateValue.Peek("CurrentComputerTab")
		CurrentComputerTab:set(button.Opens.Value.Name)
	end)
	return
end)

local CurrentComputerTab = StateValue.Get("CurrentComputerTab")
CurrentComputerTab.Changed:Connect(function(newTab: string)
	local tabToOpen  = TabFrames:FindFirstChild(newTab) :: Frame?

	for _, frame in TabFrames:GetChildren() do
		if frame:IsA("Frame") and frame ~= tabToOpen then
			GuiShared.close(frame)
		end
	end

	if tabToOpen then
		GuiShared.open(tabToOpen, UDim2.fromScale(1,1))	
	end
end)


return true