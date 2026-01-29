--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateValue = require(ReplicatedStorage.Packages.StateValue)
local GetInteractableStats = require(script.Parent.GetInteractableStats)
local Cleanup = require(ReplicatedStorage.Utils.Cleanup)
local UpdateActionListDisplay = require(script.Parent.UpdateActionListDisplay)

local Library = script.Parent.Library
local ACTION_LIST_PER_TYPE = require(Library.ActionListPerType)
local TITLE_FORMATS = require(Library.TitleFormats)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("main")
local Cursor = Main:WaitForChild("Cursor")
local Hovering = Cursor:WaitForChild("Hovering")

local MobileEnabled = Main:FindFirstChild("MobileEnabled")

local Residue = {}


type HoverUIConfig = {
	Hovering: any,
	ActionTemplate: TextLabel?,
	Highlight: Highlight,
}


local Highlight = Instance.new("Highlight")
Highlight.FillColor = Color3.fromRGB(255, 255, 255)
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.FillTransparency = 1
Highlight.OutlineTransparency = 0.5
Highlight.Parent = workspace


return function(Interactable: Instance?, Target: any)
	

	-- Hide all mobile buttons first
	if MobileEnabled then
		for _, Button in MobileEnabled:GetChildren() do
			if Button:IsA("GuiObject") then
				Button.Visible = false
			end
		end
	end

	for _, Child in Hovering:GetChildren() do
		if Child.Name ~= "Action" then continue end
		Child:Destroy()
	end

	Cleanup(Residue)

	Hovering.Visible = Interactable ~= nil
	Highlight.Enabled = Interactable ~= nil

	

	if Interactable then
		local Stats = GetInteractableStats(Interactable)
		local InteractableType = Stats.Type
		local ActionList = ACTION_LIST_PER_TYPE[InteractableType] or ACTION_LIST_PER_TYPE["Generic"]


		local CustomHoverData = StateValue.Peek("CustomHoverData")[Interactable]
		ActionList = if CustomHoverData then CustomHoverData.ActionList else ActionList

		local TitleTemplate = TITLE_FORMATS[InteractableType]
		local TitleText
		if TitleTemplate then
			TitleText = TitleTemplate
				:gsub("%[Name%]", Stats.Name)
				:gsub("%[Left%]", tostring(Stats.Left or 0))
				:gsub("%[Total%]", tostring(Stats.Total or 0))
		else
			TitleText = Stats.Name
		end

		Hovering.Title.Text = TitleText
		
		if CustomHoverData and CustomHoverData.ProgressMeter then
			local Connection
			Connection = CustomHoverData.ProgressMeter.Changed:Connect(function()
				local Value = CustomHoverData.ProgressMeter.Value
				Hovering.Title.Text = `{TitleText} ({math.floor(Value)}%)`

				--UpdateActionDisplay(ActionList)
			end)

			table.insert(Residue, Connection)
		end

		Highlight.Adornee = Interactable
		UpdateActionListDisplay(ActionList)

		TweenService:Create(Highlight, TweenInfo.new(0.15), { FillTransparency = 0.9, OutlineTransparency = 0.1 }):Play()
	else
		TweenService:Create(Highlight, TweenInfo.new(0.15), { FillTransparency = 1, OutlineTransparency = 1 }):Play()
	end
end
