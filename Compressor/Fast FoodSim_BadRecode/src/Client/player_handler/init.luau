-----< Variables

local module = {}
local Start = tick()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
local Humanoid

-----< Functions



-----< Module variables

module.APIs = {}

for _,API in pairs(ReplicatedStorage.APIs:GetChildren()) do
	module.APIs[API.Name] = require(API)
end

module.Player = Players.LocalPlayer
module.Data = module.APIs.handler.waitForData(module.Player)
module.RealData = ReplicatedStorage.Functions.Data.GetData:InvokeServer()
module.PlayerGui = module.Player:WaitForChild("PlayerGui")
module.Main = module.PlayerGui:WaitForChild("main")
module.UIHandler = require(module.PlayerGui:WaitForChild("ui_manager"):WaitForChild("handler"))
module.PlayerScripts = module.Player:WaitForChild("PlayerScripts")
module.ControlModule = require(module.PlayerScripts.PlayerModule.ControlModule)
module.Controls = require(module.PlayerScripts.PlayerModule):GetControls()
module.Functions = ReplicatedStorage.Functions
module.Remotes = ReplicatedStorage.Remotes
module.Assets = ReplicatedStorage.Assets
module.Camera = workspace.CurrentCamera
module.Mouse = module.Player:GetMouse()

module.ScreenGui = {}

for _,ScreenGui in pairs(module.PlayerGui:GetChildren()) do
	module.ScreenGui[ScreenGui.Name] = ScreenGui
end

ReplicatedStorage.Remotes.Data.DataUpdated.OnClientEvent:Connect(function(Data)
	for Name,_ in pairs(module.RealData) do
		module.RealData[Name] = Data[Name]
	end
	for Name,Value in pairs(Data) do
		module.RealData[Name] = Value
	end
end)

-----< Virtual cursor mode

if module.APIs.settings.VirtualCursorMode then
	GamepadService:EnableGamepadCursor(nil)
else
	GamepadService:DisableGamepadCursor()
end

-----< HUD

local Handler = module.APIs.handler
local Main = module.Main
local Frames = {
	[Main.Left] = UDim2.new(-0.5,0,0,0),
	[Main.Topbar] = UDim2.new(0,0,-0.5,0),
	[Main.Potions] = UDim2.new(-0.5,0,0,0),
	[Main.Tutorial] = UDim2.new(0,0,-0.5,0),
	[Main.StarterPack] = UDim2.new(0.5,0,0,0),
	[Main.GroupRewards] = UDim2.new(0.5,0,0,0),
	[Main.MobileEnabled] = UDim2.new(0.5,0,0,0),
}

for Frame,Offset in pairs(Frames) do
	Frames[Frame] = {Start = Frame.Position, End = Frame.Position + Offset}
end

Handler.stackableUpdated("HUD", function(Value)
	for Frame,Information in pairs(Frames) do
		Handler.tween(Frame, {0.2}, {Position = Value and Information.Start or Information.End}):Play()
	end
end, "true", "boolean")

-----< Keybinds

local KeybindActions = {}

function module.KeybindAction(Event)
	KeybindActions[Event] = {}
	local Info = KeybindActions[Event]
	function Info:InputBegan(Function)
		Info.InputBeganFunction = Function
	end
	function Info:InputEnded(Function)
		Info.InputEndedFunction = Function
	end
	function Info:KeybindChanged(Function)
		Info.KeybindChangedFunction = Function
		KeybindChanged(Event)
	end
	return Info
end

function KeybindChanged(Event)
	local Info = KeybindActions[Event]
	if not Info or not Info.KeybindChangedFunction then return end
	local Keybinds = {}
	for _,Keybind in pairs(module.Data.Keybinds[Event]:GetChildren()) do
		Keybind[tonumber(Keybind.Name)] = Enum.KeyCode[Keybind.Value] or Enum.UserInputType[Keybind.Value]
	end
	Info.KeybindChangedFunction(Keybinds)
end

Handler.childAdded(module.Data.Keybinds, function(Event)
	Handler.childAdded(Event, function(Keybind)
		Handler.changed(Keybind, function()
			KeybindChanged(Event.Name)
		end)
	end)
end)

UserInputService.InputBegan:Connect(function(Input)
	if TextChatService.ChatInputBarConfiguration.IsFocused then return end
	for _,Event in pairs(module.Data.Keybinds:GetChildren()) do
		local Info = KeybindActions[Event.Name]
		if not Info or not Info.InputBeganFunction then continue end
		for _,Keybind in pairs(Event:GetChildren()) do
			if Keybind.Value == Handler.fromEnum(Input.KeyCode) or Keybind.Value == Handler.fromEnum(Input.UserInputType) then
				Info.InputBeganFunction()
				break
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(Input)
	for _,Event in pairs(module.Data.Keybinds:GetChildren()) do
		local Info = KeybindActions[Event.Name]
		if not Info or not Info.InputEndedFunction then continue end
		for _,Keybind in pairs(Event:GetChildren()) do
			if Keybind.Value == Handler.fromEnum(Input.KeyCode) or Keybind.Value == Handler.fromEnum(Input.UserInputType) then
				Info.InputEndedFunction()
				break
			end
		end
	end
end)

-----< Animations

local Animations = {}

function module.LoadAnimation(Name, Id)
	local Animation = Instance.new("Animation")
	Animation.AnimationId = Id
	Animations[Name] = {
		Animation = Animation,
		AnimTrack = nil,
		IsPlaying = false,
		Markers = {},
		PlayArguments = {},
		AdjustSpeedArguments = {},
	}
	local Info = Animations[Name]
	if Humanoid and Humanoid:IsDescendantOf(workspace) then
		Info.AnimTrack = Humanoid:LoadAnimation(Info.Animation)
	end
	function Info:Play(OnRespawn, ...)
		Info.PlayArguments = table.pack(...)
		Info.IsPlaying = true
		Info.PlayOnRespawn = OnRespawn
		if Info.AnimTrack then
			Info.AnimTrack:Play(...)
			Info.AnimTrack:AdjustSpeed(table.unpack(Info.AdjustSpeedArguments))
		end
	end
	function Info:Stop(...)
		Info.IsPlaying = false
		if Info.AnimTrack then
			Info.AnimTrack:Stop(...)
		end
	end
	function Info:AdjustSpeed(...)
		Info.AdjustSpeedArguments = table.pack(...)
		if Info.AnimTrack then
			Info.AnimTrack:AdjustSpeed(...)
		end
	end
	function Info:GetMarkerReachedSignal(Function, ...)
		table.insert(Info.Markers, table.pack(Function, ...))
		if Info.AnimTrack then
			Info.AnimTrack:GetMarkerReachedSignal(...):Connect(Function)
		end
	end
	return Info
end

-----< Camera

Handler.stackableUpdated("FOV", function(Value)
	Handler.tween(module.Camera, {0.25}, {FieldOfView = Value}):Play()
end, "stacks", "number")

Handler.setStackable("FOV", "Default", module.Camera.FieldOfView)

-----< WalkSpeed

local StarterPlayer = game:GetService("StarterPlayer")

Handler.stackableUpdated("WalkSpeed", function(Value)
	if not Humanoid then return end
	Handler.tween(Humanoid, {0.25}, {WalkSpeed = Value}):Play()
end, "stacks", "number")

Handler.setStackable("WalkSpeed", "Default", StarterPlayer.CharacterWalkSpeed)

-----< Humanoid

Handler.characterAddedFunction(module.Player, function(Character, HRP, NewHumanoid)
	Humanoid = NewHumanoid
	Humanoid.WalkSpeed = Handler.getStackable("WalkSpeed")
	for _,Info in pairs(Animations) do
		Info.AnimTrack = Humanoid:LoadAnimation(Info.Animation)
		for _,Arguments in pairs(Info.Markers) do
			Info.AnimTrack:GetMarkerReachedSignal(table.unpack(Arguments, 2)):Connect(Arguments[1])
		end
		if Info.IsPlaying and Info.PlayOnRespawn then
			Info.AnimTrack:Play(table.unpack(Info.PlayArguments))
			Info.AnimTrack:AdjustSpeed(table.unpack(Info.AdjustSpeedArguments))
		end
	end
end)

-----< Blur

local Blur = game:GetService("Lighting").Blur

Handler.stackableUpdated("Blur", function(Value)
	Handler.tween(Blur, {0.25}, {Size = Value}):Play()
end, "stacks", "number")

-----< Controls

Handler.stackableUpdated("ControlsEnabled", function(Value)
	if Value then
		module.Controls:Enable()
	else
		module.Controls:Disable()
	end
end, "true", "boolean")

-----< 

print("Client Initialized in "..module.APIs.handler.timer(tick() - Start, 2).." ⏳")

return module