--!strict
-- This is a simple context action service wrapper 
local UserInputService = game:GetService('UserInputService')
local Players          = game:GetService('Players')
local RunService       = game:GetService('RunService')

export type buttonProperties = {
	position           : UDim2?,
	size               : UDim2?,
	image              : string?,
	anchorPoint        : Vector2?,
}

export type ContextAction = {
	addMobileButton    : boolean,
	callback           : (actionName: string, inputState : Enum.UserInputState, InputObject : InputObject)->(),
	bindTo             : {Enum.KeyCode | Enum.UserInputType },
	buttonProperties   : buttonProperties?,
	button             : ImageButton?,
	tapDownConnection  : RBXScriptConnection?,
	tapUpConnection    : RBXScriptConnection?,
	priority           : number?,
}

local module = {
	ContextActions = {} :: {[string] : ContextAction},
	bcasScreenUi = nil :: ScreenGui?,
	forceMobileButtons = false,
}

local function toggleMobileButtons(state : boolean)
	-- Force override always enables
	if module.forceMobileButtons then
		module.bcasScreenUi.Enabled = true
	else
		module.bcasScreenUi.Enabled = state
	end
end

local function createMobileButton(buttonProperties : buttonProperties, actionName : string) : ImageButton
	local BCASScreenUI     = module.bcasScreenUi :: ScreenGui
	local JumpButtonFrame  = BCASScreenUI:FindFirstChild('JumpButtonFrame') :: Frame

	local buttonTemplate = script:WaitForChild("MobileButton"):Clone()

	if not buttonProperties then
		buttonProperties = {
			position = UDim2.fromScale(0,0),
			size     = UDim2.fromScale(1,1),
			anchorPoint = Vector2.new(.5,.5),
		}
	end

	buttonProperties.position = buttonProperties.position or UDim2.fromScale(0,0)
	buttonProperties.size     = buttonProperties.size or UDim2.fromScale(1,1)
	buttonProperties.anchorPoint = buttonProperties.anchorPoint or Vector2.new(.5,.5)

	if buttonProperties.position and typeof(buttonProperties.position) == "UDim2" then
		buttonTemplate.Position = buttonProperties.position
	end
	if buttonProperties.size and typeof(buttonProperties.size) == "UDim2" then
		buttonTemplate.Size = buttonProperties.size
	end
	if buttonProperties.anchorPoint and typeof(buttonProperties.anchorPoint) == "Vector2" then
		buttonTemplate.AnchorPoint = buttonProperties.anchorPoint
	end
	if buttonProperties.image  then
		buttonTemplate.Image = buttonProperties.image
	end

	buttonTemplate.Parent = JumpButtonFrame
	buttonTemplate.ZIndex = module.ContextActions[actionName].priority or 1
	return buttonTemplate
end

local function triggerAction(io : InputObject, inputState : Enum.UserInputState)
	for actionName, contextActionData in module.ContextActions do
		if #contextActionData.bindTo == 0 then
			contextActionData.callback(actionName, inputState, io)
			continue
		end
		for _,bindTo in contextActionData.bindTo do
			if bindTo == io.KeyCode or bindTo == io.UserInputType then
				contextActionData.callback(actionName, inputState, io)
			end
		end
	end	
end

function module.BindAction(
	actionName         : string, 
	callback           : (actionName: string, inputState : Enum.UserInputState, InputObject : InputObject)->(),
	addMobileButton    : boolean,
	bindTo             : {Enum.KeyCode | Enum.UserInputType},
	buttonProperties   : buttonProperties?,
	priority           : number?
)
	if module.ContextActions[actionName] then
		module.UnbindAction(actionName) -- Clean up old binding first
	end
	buttonProperties = buttonProperties

	local actionData : ContextAction = {
		callback         = callback,
		addMobileButton  = addMobileButton,
		bindTo           = bindTo,
		buttonProperties = buttonProperties,
		button           = nil,
		priority         = priority or 1,
	}	

	module.ContextActions[actionName] = actionData

	if addMobileButton and buttonProperties then
		local button = createMobileButton(buttonProperties, actionName)
		actionData.button = button

		actionData.tapDownConnection = button.MouseButton1Down:Connect(function(x,y)
			local io = {
				Delta = Vector3.new(0,0,0),
				KeyCode = Enum.KeyCode.Unknown,
				Position = Vector3.new(x,y,0),
				UserInputState = Enum.UserInputState.Begin,
				UserInputType = Enum.UserInputType.Touch,
			} :: InputObject

			callback(actionName, Enum.UserInputState.Begin, io)
		end)

		actionData.tapUpConnection = button.MouseButton1Up:Connect(function(x,y)
			local io = {
				Delta = Vector3.new(0,0,0),
				KeyCode = Enum.KeyCode.Unknown,
				Position = Vector3.new(x,y,0),
				UserInputState = Enum.UserInputState.End,
				UserInputType = Enum.UserInputType.Touch,
			} :: InputObject

			callback(actionName, Enum.UserInputState.End, io)
		end)
	end	

	module.ContextActions[actionName] = actionData
end

function module.GetButton(actionName:string) : ImageButton?
	return module.ContextActions[actionName].button
end

function module.SetPosition(actionName:string, position:UDim2)
	local button = module.GetButton(actionName)
	if not button then return end
	if position and typeof(position) == 'UDim2' then
		button.Position = position
	end
end

function module.SetSize(actionName:string, size:UDim2)
	local button = module.GetButton(actionName)
	if not button then return end
	if size and typeof(size) == 'UDim2' then
		button.Size = size
	end
end

function module.getCurrentInputType(): 'pc' | 'mobile'
	return if module.bcasScreenUi and module.bcasScreenUi.Enabled then 'mobile' else 'pc'
end

function module.SetImage(actionName:string, image:string)
	local button = module.GetButton(actionName)
	if not button then return end
	button.Image = image
end

function module.UnbindAction(actionName : string)
	local actionData = module.ContextActions[actionName]

	if not actionData then 
		return 
	end

	-- Disconnect events
	if actionData.tapDownConnection then
		actionData.tapDownConnection:Disconnect()
		actionData.tapDownConnection = nil
	end
	if actionData.tapUpConnection then
		actionData.tapUpConnection:Disconnect()
		actionData.tapUpConnection = nil
	end

	-- Destroy button
	if actionData.button then
		if actionData.button.Parent then
			actionData.button:Destroy()
		end
		actionData.button = nil
	end

	module.ContextActions[actionName] = nil
end
if RunService:IsClient() then
	local localPlayer      = Players.LocalPlayer
	local PlayerGui        = localPlayer.PlayerGui
	local bcasScreenUI     = Instance.new('ScreenGui')
	module.bcasScreenUi    = bcasScreenUI

	bcasScreenUI.ClipToDeviceSafeArea = false
	bcasScreenUI.Name      = 'BCAS'

	local JumpButtonFrame = script:WaitForChild("JumpButtonFrame")
	JumpButtonFrame.Parent = bcasScreenUI
	bcasScreenUI.Parent    = PlayerGui

	-- Initial state
	if module.forceMobileButtons then
		toggleMobileButtons(true)
	else
		if UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
			toggleMobileButtons(false)
		elseif UserInputService.PreferredInput == Enum.PreferredInput.Touch then
			toggleMobileButtons(true)
		end
	end

	UserInputService.InputBegan:Connect(function(io, gameProcessed)
		if gameProcessed then return end
		triggerAction(io, Enum.UserInputState.Begin)
	end)

	UserInputService.InputEnded:Connect(function(io, gameProcessed)
		if gameProcessed then return end
		triggerAction(io, Enum.UserInputState.End)
	end)

	UserInputService.InputChanged:Connect(function(io, processed)
		if processed then return end
		triggerAction(io, Enum.UserInputState.Begin)

		-- Do NOT auto-switch when override is enabled
		if not module.forceMobileButtons then
			if UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
				toggleMobileButtons(false)
			elseif UserInputService.PreferredInput == Enum.PreferredInput.Touch then
				toggleMobileButtons(true)
			end
		end
	end)
end

return module
