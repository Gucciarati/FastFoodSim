-----< Variables

local PlayerHandler = require(script.Parent)
local Settings = PlayerHandler.APIs.settings
local Handler = PlayerHandler.APIs.handler
local UIHandler = PlayerHandler.UIHandler
local Remotes = PlayerHandler.Remotes.Settings
local Player = PlayerHandler.Player
local Data = PlayerHandler.Data
local Main = PlayerHandler.ScreenGui.main
local Frame = Main.Frames.Settings.ScrollingFrame

-----< Settings

local SettingFunctions = {
}

for _,Setting in pairs(Frame:GetChildren()) do
	local Frame = Setting
	Setting = Data.Settings:FindFirstChild(Frame.Name)
	if not Setting then continue end
	
	local Choices = Frame:FindFirstChild("Choices")
	local Slider = Frame:FindFirstChild("Slider")
	local Switch = Frame:FindFirstChild("Switch")
	
	local Function = SettingFunctions[Setting.Name]
	if Function then
		Handler.changed(Setting, Function)
	end
	
	if Slider then
		UIHandler.CreateSlider(
			Slider.Drag,
			Slider.Drag,
			Slider,
			Vector2.new(0,1),
			Vector2.new(0.5,0.5),
			Vector2.new(0,0),
			function(Position)
				Setting.Value = Position.X.Scale
				--Slider.UIGradient.Offset = Vector2.new(Position.X.Scale - 0.5, 0)
			end,
			function(Position)
				Remotes.Setting:FireServer(Setting.Name, Position.X.Scale)
			end,
			UDim2.new(Setting.Value,0,0.5,0)
		)
	elseif Switch then
		UIHandler.PressDown(Switch, function()
			Remotes.Setting:FireServer(Setting.Name, not Setting.Value)
		end)
		
		Handler.changed(Setting, function(Value)
			Switch.On.Visible = Value
			Switch.Off.Visible = not Value
		end)
	elseif Choices then
		for _,Button in pairs(Choices:GetChildren()) do
			if not Button:IsA("GuiButton") then continue end
			UIHandler.PressDown(Button, function()
				Remotes.Setting:FireServer(Setting.Name, Button.Name)
			end)
		end
		
		Handler.changed(Setting, function(Value)
			for _,Button in pairs(Choices:GetChildren()) do
				if not Button:IsA("GuiButton") then continue end
				local On = Button.Name == Value
				Button.On.Enabled = On
				Button.Off.Enabled = not On
			end
		end)
	end
end

-----< 