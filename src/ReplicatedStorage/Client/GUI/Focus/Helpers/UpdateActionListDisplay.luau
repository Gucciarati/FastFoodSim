--!strict
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("main")
local Cursor = Main:WaitForChild("Cursor")
local Hovering = Cursor:WaitForChild("Hovering")

local Library = script.Parent.Library
local ACTION_LIST_PER_TYPE = require(Library.ActionListPerType)
local ACTION_DESCRIPTIONS = require(Library.ActionDescriptions)
local BIND_NAMES = require(Library.BindNames)
local ACTION_TO_MOBILE_BUTTON = require(Library.ActionToMobileButton)

local ActionSample = Hovering:FindFirstChild("Action")
local ActionTemplate = ActionSample and ActionSample:Clone()

local function UpdateActionListDisplay(ActionList: {any})
	local IsMobile = UserInputService.TouchEnabled

	if IsMobile then
		for _, Action in ActionList do
			local ActionName = Action.Action
			local MobileButton = ACTION_TO_MOBILE_BUTTON[ActionName]
			
			if MobileButton then
				MobileButton.Visible = true
			end
		end
	else
		-- Show keyboard hints for PC players
		for _, Action in ActionList do
			local ActionName = Action.Action
			local ActionDescription = ACTION_DESCRIPTIONS[ActionName] or ActionName

			local Label = ActionTemplate:Clone()
			Label.Text = `{BIND_NAMES[Action.Bind]} - {ActionDescription}`
			Label.Visible = true
			Label.Parent = Hovering
		end
	end
end

return UpdateActionListDisplay
