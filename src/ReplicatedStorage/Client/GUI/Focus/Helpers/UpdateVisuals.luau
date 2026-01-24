--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local GetKeybindString = require(script.Parent.GetKeybindString)
local GetInteractableStats = require(script.Parent.GetInteractableStats)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("main")
local Cursor = Main:WaitForChild("Cursor")
local Hovering = Cursor:WaitForChild("Hovering")
local ActionSample = Hovering:FindFirstChild("Action")
local ActionTemplate = ActionSample and ActionSample:Clone()

type HoverUIConfig = {
	Hovering: any,
	ActionTemplate: TextLabel?,
	Highlight: Highlight,
}

local ACTION_LIST_PER_TYPE = {
	["Generic"] = {
		{ Bind = "Primary", Action = "Grab" },
	},

	["Openable"] = {
		{ Bind = "Primary", Action = "Open" },
	},

	["Furniture Package"] = {
		{ Bind = "Primary", Action = "Pick Up" },
		{ Bind = "Secondary", Action = "Take 1x" },
		{ Bind = "Tertiary", Action = "Sell" },
	},

	["Food Package"] = {
		{ Bind = "Primary", Action = "Pick Up" },
		{ Bind = "Secondary", Action = "Take" },
	},

	["Placed Furniture"] = {
		{ Bind = "Secondary", Action = "Move" },
		{ Bind = "Tertiary", Action = "Sell" },
	},

	["Dirty Tray"] = {
		{ Bind = "Secondary", Action = "Collect" },
	},

	["Grillable"] = {
		{ Bind = "Primary", Action = "Flip" },
	},

	["Lid Cup"] = {
		{ Bind = "Primary", Action = "Add Lid" },
	},


}

local ACTION_DESCRIPTIONS = {
	["Sell"] = "Sell (50% refund)",
	["Take"] = "Take 1",
	["Pick Up"] = "Pick Up",
	["Add Lid"] = "Add Lid",
}

local TITLE_FORMATS = {
	["Food Package"] = "[Name] Pack ([Left]/[Total])",
	["Furniture Package"] = "[Name] Package",
}

local Highlight = Instance.new("Highlight")
Highlight.FillColor = Color3.fromRGB(255, 255, 255)
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.FillTransparency = 1
Highlight.OutlineTransparency = 0.5
Highlight.Parent = workspace

return function(Interactable: Instance?)
	for _, Child in Hovering:GetChildren() do
		if Child.Name ~= "Action" then continue end
		Child:Destroy()
	end

	Hovering.Visible = Interactable ~= nil

	if Interactable then
		local Stats = GetInteractableStats(Interactable)
		local InteractableType = Stats.Type
		local ActionList = ACTION_LIST_PER_TYPE[InteractableType] or ACTION_LIST_PER_TYPE["Generic"]

		local TitleTemplate = TITLE_FORMATS[InteractableType]
		if TitleTemplate then
			Hovering.Title.Text = TitleTemplate
				:gsub("%[Name%]", Stats.Name)
				:gsub("%[Left%]", tostring(Stats.Left or 0))
				:gsub("%[Total%]", tostring(Stats.Total or 0))
		else
			Hovering.Title.Text = Stats.Name
		end

		Highlight.Adornee = Interactable

		for _, Action in ActionList do
			local ActionName = Action.Action
			local ActionDescription = ACTION_DESCRIPTIONS[ActionName] or ActionName

			local Label = ActionTemplate:Clone()
			Label.Text = `{GetKeybindString(Action.Bind)} - {ActionDescription}`
			Label.Visible = true
			Label.Parent = Hovering
		end

		TweenService:Create(Highlight, TweenInfo.new(0.15), { FillTransparency = 0.9, OutlineTransparency = 0.1 }):Play()
	else
		TweenService:Create(Highlight, TweenInfo.new(0.15), { FillTransparency = 1, OutlineTransparency = 1 }):Play()
		Highlight.Adornee = nil
	end
end
