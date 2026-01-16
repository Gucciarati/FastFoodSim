-----< Variables

local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local PlayerHandler = require(script.Parent)
local Settings = PlayerHandler.APIs.settings
local Handler = PlayerHandler.APIs.handler
local UIHandler = PlayerHandler.UIHandler
local Player = PlayerHandler.Player
local Data = PlayerHandler.Data
local Main = PlayerHandler.Main
local Camera = workspace.CurrentCamera
local Humanoid

local Movements = {
	["Sprint"] = {
		GamePass = "Sprint",
		PromptGamePass = false,
		IdleAnimationId = nil,
		AnimationId = nil,
		MovementRequired = false,
		DisabledStates = {},
		Hold = true,
		GPE = false,
		Speed = 10,
		FOV = 20,
		Layer = 2,
		
		MobileButtons = {
			{
				Button = Main.Sprint,
				Size = 1.2, --the size multiplier from the default mobile button size
				Position = nil, --if nil, will default to the jump button's position
				Offset = UDim2.new(0,-30,0,-40), --offset from position
				Image = "rbxassetid://9525535512",
				Description = nil,
				Title = nil,
				Hold = false, --whether the button must be held or toggled
			},
		},
	},
}

local Keybinds = {
	[Enum.KeyCode.RightShift] = "Sprint",
	[Enum.KeyCode.LeftShift] = "Sprint",
}

for _,Information in pairs(Movements) do
	Information.GUID = Handler.generateGUID()
	Information.Active = false
	Information.KeyCodes = {}
end

for KeyCode,Movement in pairs(Keybinds) do
	table.insert(Movements[Movement].KeyCodes, KeyCode)
end

-----< Actions

function Action(Name, Information, Value)
	if Value and Information.GamePass and not Data.GamePasses[Information.GamePass].Value then
		if Information.PromptGamePass then
			UIHandler.PromptPurchase(Settings.GamePassId[Information.GamePass], "GamePass")
		end
		return
	end
	local Idle = Humanoid.MoveDirection.Magnitude == 0
	if Value and Idle and Information.MovementRequired then return end
	Information.Active = Value
	Handler.setStackable("WalkSpeed", Information.GUID, Value and Information.Speed or 0)
	Handler.setStackable("FOV", Information.GUID, Value and Information.FOV or 0)
	for _,State in pairs(Information.DisabledStates) do
		Humanoid:SetStateEnabled(State, not Value)
	end
	if not Information.AnimationTrack then return end
	if Value then
		if Information.IdleAnimationTrack then
			Information.IdleAnimationTrack:Play()
			if not Idle then
				Information.AnimationTrack:Play(nil, 0.4)
			end
		else
			Information.AnimationTrack:Play()
			Information.AnimationTrack:AdjustSpeed(Idle and 0 or 1)
		end
	else
		if Information.IdleAnimationTrack then
			Information.IdleAnimationTrack:Stop()
		end
		Information.AnimationTrack:Stop(0.4)
	end
end

UserInputService.InputBegan:Connect(function(Input, GPE)
	if not Humanoid then return end
	local Name = Keybinds[Input.KeyCode]
	local Information = Movements[Name]
	if not Information or (Information.Hold and Information.Active) or GPE and Information.GPE then return end
	for Name,Other in pairs(Movements) do
		if Other.Layer ~= Information.Layer or Other == Information or not Other.Active then continue end
		Action(Name, Other, false)
	end
	Action(Name, Information, not Information.Active)
end)

UserInputService.InputEnded:Connect(function(Input)
	if not Humanoid then return end
	local Name = Keybinds[Input.KeyCode]
	local Information = Movements[Name]
	if not Information or not Information.Hold or not Information.Active then return end
	Action(Name, Information, false)
end)

-----< Animations

for Name,Information in pairs(Movements) do
	if Information.AnimationId then
		Information.AnimationTrack = PlayerHandler.LoadAnimation(Name, Information.AnimationId)
	end
	if Information.IdleAnimationId then
		Information.IdleAnimationTrack = PlayerHandler.LoadAnimation(Name, Information.IdleAnimationId)
	end
end

Handler.characterAddedFunction(Player, function(Character, HRP, NewHumanoid)
	Humanoid = NewHumanoid
	Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		local Idle = Humanoid.MoveDirection.Magnitude == 0
		for Name,Information in pairs(Movements) do
			local Held = false
			for _,KeyCode in pairs(Information.KeyCodes) do
				if UserInputService:IsKeyDown(KeyCode) then Held = true break end
			end
			if Information.MovementRequired and Held and Information.Active == Idle then
				Action(Name, Information, not Idle)
			end
			if not Information.AnimationTrack then continue end
			if Information.IdleAnimationTrack then
				if Information.AnimationTrack.IsPlaying and Idle then
					Information.AnimationTrack:Stop(0.4)
				elseif not Information.AnimationTrack.IsPlaying and not Idle and Information.Active then
					Information.AnimationTrack:Play(nil, 0.4)
				end
			elseif Information.AnimationTrack.IsPlaying then
				Information.AnimationTrack:AdjustSpeed(Idle and 0 or 1)
			end
		end
	end)
	Handler.onDestroy(Humanoid, function()
		Humanoid = nil
		for Name,Other in pairs(Movements) do
			if not Other.Active then continue end
			Action(Name, Other, false)
		end
	end)
end)

-----< Mobile

for Name,Information in pairs(Movements) do
	if not Information.MobileButtons then continue end
	for Index,MB in pairs(Information.MobileButtons) do
		local Str = Name..Index
		
		if MB.Button then
			local function Changed(InputState)
				if MB.Hold then
					local Enable = InputState == Enum.UserInputState.Begin
					if Enable == Information.Active then return end
					Action(Name, Information, Enable)
				else
					if InputState ~= Enum.UserInputState.Begin then return end
					Action(Name, Information, not Information.Active)
				end
			end
			UIHandler.PressDown(MB.Button, function()
				if Information.GamePass and not Data.GamePasses[Information.GamePass].Value then
					UIHandler.PromptPurchase(Settings.GamePassId[Information.GamePass], "GamePass")
				end
				Changed(Enum.UserInputState.Begin)
			end)
			UIHandler.PressUp(MB.Button, function()
				Changed(Enum.UserInputState.End)
			end)
			Handler.attributeChanged(Player, "Device", function(Device)
				MB.Button.Visible = Device == "Mobile"
			end)
		else
			ContextActionService:BindAction(Str, function(_,InputState)
				if MB.Hold then
					local Enable = InputState == Enum.UserInputState.Begin
					if Enable == Information.Active then return end
					Action(Name, Information, Enable)
				else
					if InputState ~= Enum.UserInputState.Begin then return end
					Action(Name, Information, not Information.Active)
				end
			end, true)

			UIHandler.CreateMobileButton(Str, MB.Position, MB.Offset, MB.Size, MB.Image, MB.Title, MB.Description)
		end
	end
end

-----< 