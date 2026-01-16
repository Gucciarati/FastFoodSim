--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local Players             = game:GetService('Players')

local Shared              = ReplicatedStorage:WaitForChild('SharedModules')
local Utils               = ReplicatedStorage:WaitForChild('Utils')
local Vendor              = ReplicatedFirst.Vendor
local OpenModalState      = ReplicatedStorage.GameState.OpenModal

local GuiShared           = require(Shared.GuiShared)

local LocalPlayer         = Players.LocalPlayer
local PlayerGui           = LocalPlayer.PlayerGui

local Tagged = require(Vendor.Tagged)
local Connect = require(Vendor.ConnectUtil)
local RequireAttribute = require(Utils.RequireAttribute)

local MainScreenGui = PlayerGui:WaitForChild('main')
local SideButtons = MainScreenGui.Left
local ModalsFolder = MainScreenGui.Modals
local Modals = ModalsFolder:GetChildren()

type LeftSidebarButtonAssembly = typeof(SideButtons.Computer)
type Modal = Frame & {
	Buttons : InputContext & {
		Actions : InputAction & {
			Key : InputBinding?
		}
	},
	Modal : ObjectValue?,

}

GuiShared.toggleVisibility(Modals, false)


Tagged.observe(GuiShared.Tags.LeftSidebarButton, function(button: LeftSidebarButtonAssembly)	
	button.Buttons.Actions.Pressed:Connect(function()
		OpenModalState.Value = button.Opens.Value.Name
	end)
	return
end)



Connect.valueChanged(OpenModalState,function(curr,prev)
	local modalToOpen  = ModalsFolder:FindFirstChild(curr) :: Frame?
	local modalToClose = ModalsFolder:FindFirstChild(prev) :: Frame?
	if modalToClose then
		GuiShared.close(modalToClose)
	end

	if modalToOpen then
		local openSize = modalToOpen:GetAttribute(GuiShared.Attribues.OpenSize) :: UDim2
		GuiShared.open(modalToOpen, openSize)	
	end
	
end, false)


return true