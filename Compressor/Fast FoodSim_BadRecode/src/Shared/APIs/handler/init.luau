local module = {}
local abbreviations = {"K","M","B","T","Q","QN","S","SP","O","N","D","U","DD","TD","QT","QD","SD","ST"}
local key = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
local numberToWords = require(script.number_to_words)
local viewportModel = require(script.viewportmodel)
local countries = require(script.countries)
local keybinds = require(script.keybinds)
local names = require(script.names)
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local textService = game:GetService("TextService")
local tweenService = game:GetService("TweenService")
local starterPlayer = game:GetService("StarterPlayer")
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")
local marketplaceService = game:GetService("MarketplaceService")
local localizationService = game:GetService("LocalizationService")

module.numberToWords = numberToWords.convert
module.abbreviations = abbreviations

local nameColors = {
	Color3.new(253/255, 41/255, 67/255), -- BrickColor.new("Bright red").Color,
	Color3.new(1/255, 162/255, 255/255), -- BrickColor.new("Bright blue").Color,
	Color3.new(2/255, 184/255, 87/255), -- BrickColor.new("Earth green").Color,
	BrickColor.new("Bright violet").Color,
	BrickColor.new("Bright orange").Color,
	BrickColor.new("Bright yellow").Color,
	BrickColor.new("Light reddish violet").Color,
	BrickColor.new("Brick yellow").Color,
}

function nameValue(name)
	local value = 0
	for index = 1, #name do
		local cValue = string.byte(string.sub(name, index, index))
		local reverseIndex = #name - index + 1
		if #name%2 == 1 then
			reverseIndex = reverseIndex - 1
		end
		if reverseIndex%4 >= 2 then
			cValue = -cValue
		end
		value = value + cValue
	end
	return value
end

function module.nameColor(name)
	return nameColors[(nameValue(name) % #nameColors) + 1]
end

function module.countryInformation(countryCode)
	return countries[countryCode]
end

function module.keycodeString(input)
	return (input.EnumType == Enum.KeyCode and userInputService:GetStringForKeyCode(input)) or keybinds.String[input] or ""
end

function module.keycodeImage(input)
	return (input.EnumType == Enum.KeyCode and userInputService:GetImageForKeyCode(input)) or keybinds.Image[input] or ""
end

local stackables = {}
local defaults = {
	["boolean"] = {
		["true"] = true,
		["false"] = false,
		["priority"] = false,
	},
	["number"] = {
		["stacks"] = 0,
		["priority"] = 0,
	},
}

function module.getStackable(name)
	local stackable = stackables[name]
	local valueType = stackable.valueType
	local returnType = stackable.returnType
	local value,highestPriority = defaults[valueType][returnType],0
	
	for _,info in pairs(stackable.specifics) do
		if valueType == "boolean" then
			if returnType == "true" then
				if not info.value then
					return false
				end
			elseif returnType == "false" then
				if info.value then
					return true
				end
			elseif returnType == "priority" then
				value = info.priority > highestPriority and info.value or value
			end
		elseif valueType == "number" then
			if returnType == "stacks" then
				value += info.value
			elseif returnType == "priority" then
				value = info.priority > highestPriority and info.value or value
			end
		end
		
		if info.priority > highestPriority then
			highestPriority = info.priority
		end
	end
	
	return value
end

function module.stackableUpdated(name, updateFunction, returnType, valueType)
	if not stackables[name] then
		stackables[name] = {
			returnType = returnType,
			valueType = valueType,
			specifics = {},
			updateFunctions = {},
		}
	end
	table.insert(stackables[name].updateFunctions, updateFunction)
	updateFunction(module.getStackable(name))
end

function module.setStackable(name, specific, value, priority)
	task.spawn(function()
		while not stackables[name] do
			task.wait()
		end
		local specificInfo = stackables[name].specifics[specific]
		priority = priority or (specificInfo and specificInfo.priority) or tick()
		if specificInfo and value == specificInfo.value and priority == specificInfo.priority then return end
		if value ~= nil then
			stackables[name].specifics[specific] = {value = value, priority = priority}
		else
			stackables[name].specifics[specific] = nil
		end
		for _,updateFunction in pairs(stackables[name].updateFunctions) do
			updateFunction(module.getStackable(name))
		end
	end)
end

function module.setMinViewport(viewport, instance, orientation)
	local worldModel = Instance.new("WorldModel", viewport)
	local camera = Instance.new("Camera", viewport)
	local clone = instance:Clone()
	viewport.CurrentCamera = camera
	clone.Parent = worldModel
	
	local vpfModel = viewportModel.new(viewport, camera)
	vpfModel:SetModel(clone)
	
	local cframeValue = module.create("CFrameValue", viewport, "Orientation", orientation or CFrame.new())
	
	module.changed(cframeValue, function(value)
		camera.CFrame = vpfModel:GetMinimumFitCFrame(value)
	end)
	
	return cframeValue
end

function module.setFitViewport(viewport, instance, orientation)
	local worldModel = Instance.new("WorldModel", viewport)
	local camera = Instance.new("Camera", viewport)
	local clone = instance:Clone()
	viewport.CurrentCamera = camera
	clone.Parent = worldModel
	
	local vpfModel = viewportModel.new(viewport, camera)
	vpfModel:SetModel(clone)
	
	local cf, size = clone:GetBoundingBox()
	local distance = vpfModel:GetFitDistance(cf.Position)
	
	local cframeValue = module.create("CFrameValue", viewport, "Orientation", orientation or CFrame.new())
	
	module.changed(cframeValue, function(value)
		camera.CFrame = CFrame.new(cf.Position) * value * CFrame.new(0, 0, distance)
	end)
	
	return cframeValue
end

function module.elapsed(start)
	return os.time() - (start or 0)
end

function module.version(increments, start)
	return math.floor(module.elapsed(start)/increments)
end

function module.timeFromVersion(increments, start, version)
	start = start or 0
	return start + (version or module.version(increments, start)) * increments
end

function module.random(min, max, seed)
	if typeof(min) == "NumberRange" then
		max = min.Max
		min = min.Min
	else
		local hasMax = max
		max = hasMax and max or min
		min = hasMax and min or 1
	end
	return Random.new(seed):NextNumber(min, max)
end

function module.randomInt(min, max, seed)
	if typeof(min) == "NumberRange" then
		max = min.Max
		min = min.Min
	else
		local hasMax = max
		max = hasMax and max or min
		min = hasMax and min or 1
	end
	return Random.new(seed):NextInteger(min, max)
end

function module.tween(instance, tweenInfo, properties)
	tweenInfo = TweenInfo.new(
		tweenInfo[1] or 1,
		Enum.EasingStyle[tweenInfo[2] or "Quad"],
		Enum.EasingDirection[tweenInfo[3] or "Out"],
		tweenInfo[4] or 0,
		tweenInfo[5] or false,
		tweenInfo[6] or 0
	)
	return tweenService:Create(instance, tweenInfo, properties)
end

function module.sample(item)
	local clone,parent = item:Clone(),item.Parent
	module.destroy(item)
	return clone,parent
end

function module.destroy(item, time)
	if time then
		task.delay(time, function()
			if not item or not item.Parent then return end
			item:Destroy()
		end)
	elseif item and item.Parent then
		item:Destroy()
	end
end

function module.findFirstChild(instance, ancestry)
	for _,name in pairs(ancestry) do
		instance = instance:FindFirstChild(name)
		if not instance then return end
	end
	return instance
end

function module.waitForChild(instance, ancestry)
	for _,name in pairs(ancestry) do
		instance = instance:WaitForChild(name)
		if not instance then return end
	end
	return instance
end

function module.ragdoll(character)
	if character:GetAttribute("ragdoll") then return end
	character:SetAttribute("ragdoll", true)
	local humanoid = character:WaitForChild("Humanoid")
	
	for _,descendant in pairs(character:GetDescendants()) do
		if descendant:IsA("Motor6D") then
			local socket = Instance.new("BallSocketConstraint")
			local a0 = Instance.new("Attachment")
			local a1 = Instance.new("Attachment")
			a0.Name = descendant.Name
			a1.Name = descendant.Name
			a0:SetAttribute("Target", "C0")
			a1:SetAttribute("Target", "C1")
			a0.Parent = descendant.Part0
			a1.Parent = descendant.Part1
			socket.Parent = descendant.Parent
			socket.Attachment0 = a0
			socket.Attachment1 = a1
			a0.CFrame = descendant.C0
			a1.CFrame = descendant.C1
			socket.LimitsEnabled = true
			socket.TwistLimitsEnabled = true
			
			descendant.Enabled = false
		end
	end
	
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.AutoRotate = false
	humanoid.PlatformStand = true
	
	humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)	
end

function module.unragdoll(character)
	if not character:GetAttribute("ragdoll") then return end
	local humanoid = character:WaitForChild("Humanoid")
	
	for _,descendant in pairs(character:GetDescendants()) do
		if descendant:IsA("BallSocketConstraint") then
			module.destroy(descendant)
		elseif descendant:IsA("Motor6D") then
			descendant.Enabled = true
		end
	end
	
	humanoid.WalkSpeed = starterPlayer.CharacterWalkSpeed
	humanoid.JumpPower = starterPlayer.CharacterJumpPower
	humanoid.AutoRotate = true
	humanoid.PlatformStand = false
	
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)	
	
	character:SetAttribute("ragdoll", nil)
end

local cached = {}
local caching = {}

function module.cacheAsync(name, cacheFunction, cacheDuration)
	while caching[name] and not cached[name] do
		task.wait()
	end
	if cached[name] then
		return cached[name]
	else
		caching[name] = true
		local result = cacheFunction()
		caching[name] = nil
		cached[name] = result
		if cacheDuration and result then
			task.delay(cacheDuration, function()
				cached[name] = nil
			end)
		end
		return result
	end
end

function module.usernameAsync(userId)
	return module.cacheAsync("usernameAsync"..userId, function()
		local username,success = 
			module.forcePcall(1, .1, players.GetNameFromUserIdAsync, players, userId)
		return success and username or nil
	end)
end

function module.clearAllChildren(instance, class, delayIntervals)
	for index,child in pairs(instance:GetChildren()) do
		if class and not child:IsA(class) then continue end
		module.destroy(child)
		if delayIntervals and index % delayIntervals == 0 then
			task.wait()
		end
	end
end

function module.gradientPercent(keypoints, percent)
	if percent >= 1 then
		return keypoints[#keypoints].Value
	elseif percent <= 0 then
		return keypoints[1].Value
	end
	for index,keypoint in pairs(keypoints) do
		local next = keypoints[index+1]
		if keypoint.Time < percent and next.Time >= percent then
			percent = (percent - keypoint.Time) / (next.Time - keypoint.Time)
			local value
			if typeof(keypoint.Value) == "number" then
				value = keypoint.Value + (next.Value-keypoint.Value) * percent
			else
				value = keypoint.Value:Lerp(next.Value, percent)
			end
			return value
		end
	end
end

function module.abbreviate(number, firstAbbreviation, lastAbbreviation)
	firstAbbreviation = table.find(abbreviations, (firstAbbreviation or ""):upper())
	lastAbbreviation = table.find(abbreviations, (lastAbbreviation or ""):upper()) or #abbreviations
	number = ("%f"):format(number)
	number = number:sub(0, #number-7)
	
	if firstAbbreviation then
		local abbreviation = math.clamp(math.floor((#number-1)/3), firstAbbreviation, lastAbbreviation)
		
		if #number > abbreviation * 3 then
			local left = number:sub(0, #number - abbreviation * 3)
			local right = ""
			
			if #left < 3 then
				right = "."..number:sub(#left+1,#left+(3-#left))
			end
			
			number = tonumber(left..right)..abbreviations[abbreviation]
		end
	end
	
	local left, num, right = number:match('^([^%d]*%d)(%d*)(.-)$')
	number = left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
	
	return number
end

function module.unabbreviate(string)
	string = string:gsub(",", "")
	local Numbers,Abbreviation = string:match("^(%d*%.?%d*)(%a*)")
	Abbreviation = (Abbreviation or ""):upper()
	return (tonumber(Numbers) or 0) * (1000 ^ (table.find(abbreviations, Abbreviation) or 0))
end

local timeFormats = {
	{":", ":", ":", ":", ":", ""},
	{"y", "mo", "d", "h", "m", "s"},
	{" years ", " months ", " days ", " hours ", " minutes ", " seconds"}
}

local timeSeconds = {31536000, 2628028.8, 86400, 3600, 60}

function module.timer(seconds, format, forcePlacement, keep)
	format = timeFormats[format or 1]
	local function get(placement)
		local unit = math.floor(seconds/timeSeconds[placement])
		seconds, keep = seconds % timeSeconds[placement], keep or placement == forcePlacement or unit > 0
		return keep and ("%02i"):format(unit)..format[placement] or ""
	end
	return get(1)..get(2)..get(3)..get(4)..get(5)..tostring(100+math.floor(seconds*100)/100):match("1(.+)")..format[6]
end

function module.incrementZIndex(gui, amount)
	local descendants = gui:GetDescendants()
	table.insert(descendants, gui)
	for _,descendant in pairs(descendants) do
		if not descendant:IsA("GuiObject") then continue end
		descendant.ZIndex += amount
	end
end

local emptyProductInfo = {
	Description = "error",
	Name = "error",
	IconImageAssetId = 0,
	PriceInRobux = 0,
	Remaining = 0,
}

function module.productInfo(id, productType)
	local info,success
	if productType == "Subscription" then
		info,success = module.forcePcall(1, .1, marketplaceService.GetSubscriptionProductInfoAsync, marketplaceService, id)
	else
		info,success = module.forcePcall(1, .1, marketplaceService.GetProductInfo, marketplaceService, id, Enum.InfoType[productType])
	end
	info = (success and info) or table.clone(emptyProductInfo)
	for name,value in pairs(emptyProductInfo) do
		if info[name] then continue end
		info[name] = value
	end
	if productType == "Subscription" then
		info.PriceString = info.DisplayPrice..info.DisplaySubscriptionPeriod
	else
		info.PriceString = " "..module.abbreviate(info.PriceInRobux)
	end
	return info
end

function module.filter(text, userid)
	local filteredObject,success = module.forcePcall(1, .1, textService.FilterStringAsync, textService, text, userid)
	if not success then return end
	local string,success = module.forcePcall(1, .1, filteredObject.GetNonChatStringForUserAsync, filteredObject, userid)
	return success,string
end

function module.playerTouched(part, target, touchedFunction)
	part.Touched:Connect(function(touched)
		if touched.Name ~= "HumanoidRootPart" then return end
		local player = players:GetPlayerFromCharacter(touched.Parent)
		if not player or (target and player ~= target) then return end
		touchedFunction(player)
	end)
end

function module.playerTouchEnded(part, target, touchedEndedFunction)
	part.TouchEnded:Connect(function(touched)
		if touched.Name ~= "HumanoidRootPart" then return end
		if table.find(workspace:GetPartBoundsInBox(touched.CFrame, touched.Size), part) then return end
		local player = players:GetPlayerFromCharacter(touched.Parent)
		if not player or (target and player ~= target) then return end
		touchedEndedFunction(player)
	end)
end

function module.childrenChanged(instance, changedFunction)
	instance.ChildRemoved:Connect(changedFunction)
	instance.ChildAdded:Connect(changedFunction)
	changedFunction()
end

function module.childAdded(instance, childAddedFunction)
	instance.ChildAdded:Connect(childAddedFunction)
	for _,child in pairs(instance:GetChildren()) do
		task.spawn(childAddedFunction, child)
	end
end

function module.descendantsChanged(instance, changedFunction)
	instance.DescendantRemoving:Connect(changedFunction)
	instance.DescendantAdded:Connect(changedFunction)
	changedFunction()
end

function module.descendantAdded(instance, descendantAddedFunction)
	instance.DescendantAdded:Connect(descendantAddedFunction)
	for _,descendant in pairs(instance:GetDescendants()) do
		task.spawn(descendantAddedFunction, descendant)
	end
end

function module.uniqueChildAdded(instance, childAddedFunction)
	local registered = {}
	module.childAdded(instance, function(child)
		if registered[child] then return end
		registered[child] = ""
		childAddedFunction(child)
	end)
end

function module.uniqueDescendantAdded(instance, descendantAddedFunction)
	local registered = {}
	module.descendantAdded(instance, function(child)
		if registered[child] then return end
		registered[child] = ""
		descendantAddedFunction(child)
	end)
end

function module.tagAdded(tag, tagAddedFunction)
	collectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		tagAddedFunction(instance)
	end)
	for _,instance in pairs(collectionService:GetTagged(tag)) do
		task.spawn(tagAddedFunction, instance)
	end
end

function module.setInformation(instance, folder)
	for _,property in pairs(folder.Properties:GetChildren()) do
		instance[property.Name] = property.Value
	end
	for _,child in pairs(folder.Children:GetChildren()) do
		module.destroy(instance:FindFirstChildOfClass(child.ClassName))
		child:Clone().Parent = instance
	end
end

function module.clampPositive(num)
	return math.clamp(num, 0, math.huge)
end

function module.clampNegative(num)
	return math.clamp(num, -math.huge, 0)
end

function module.clampOne(num)
	return math.clamp(num, 0, 1)
end

function module.findFirstAncestorOfChild(instance, parent)
	repeat
		if instance.Parent == parent then return instance end
		instance = instance.Parent
	until not instance
end

function module.weld(part0, part1)
	local weld = Instance.new("Weld")
	weld.C0 = part0.CFrame:ToObjectSpace(part1)
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = part1
end

local faces = {
	["Front"] = {"X", "Y"},
	["Back"] = {"X", "Y"},
	["Left"] = {"Z", "Y"},
	["Right"] = {"Z", "Y"},
	["Top"] = {"X", "Z"},
	["Bottom"] = {"X", "Z"},
}

function module.flipBook(instance, framerate, grid, image)
	task.spawn(function()
		local texture = instance:IsA("Texture")
		local image = instance:IsA("ImageLabel") or instance:IsA("ImageButton")
		
		if texture then
			instance.StudsPerTileU = instance.Parent.Size[faces[module.fromEnum(instance.Face)][1]]*grid
			instance.StudsPerTileV = instance.Parent.Size[faces[module.fromEnum(instance.Face)][2]]*grid
		elseif image then
			instance.ScaleType = Enum.ScaleType.Fit
			instance.ImageRectSize = instance.AbsoluteSize
		end
		
		local frame = 0
		
		while instance.Parent do
			frame = frame % (grid ^ 2) + 1
			local row = math.ceil(frame/grid)
			local column = frame - ((row - 1) * grid)
			local offset = Vector2.new(column - 1, row - 1)
			
			if texture then
				instance.OffsetStudsU = instance.StudsPerTileU / grid * offset.X
				instance.OffsetStudsV = instance.StudsPerTileV / grid * offset.Y
			elseif image then
				instance.ImageRectOffset = instance.ImageRectSize * offset
			end
			task.wait(1/framerate)
		end
	end)
end

module.emitAttachment = require(script.emit)

local resizeAttachmentModel = Instance.new("Model")

function module.resizeAttachment(attachment, scale)
	local descendants = attachment:GetDescendants()
	table.insert(descendants, attachment)
	
	resizeAttachmentModel:ScaleTo(1)
	
	local resizing = {}
	
	for _,descendant in pairs(descendants) do
		local clone = attachment:Clone()
		clone.Parent = resizeAttachmentModel
		resizing[clone] = attachment
	end
	
	resizeAttachmentModel:ScaleTo(scale)
	
	for clone,attachment in pairs(resizing) do
		if attachment:IsA("ParticleEmitter") then
			attachment.Size = clone.Size
			attachment.Speed = clone.Speed
		elseif attachment:IsA("Beam") then
			attachment.Width0 = clone.Width0
			attachment.Width1 = clone.Width1
		elseif attachment:IsA("Trail") then
			attachment.MinLength = clone.MinLength
			attachment.WidthScale = clone.WidthScale
			attachment.TextureLength = clone.TextureLength
		end
		module.destroy(clone)
	end
end

local savedTransparencies = {}
local transparencyProperties = {
	["TextButton"] = {["TextTransparency"] = 1, ["TextStrokeTransparency"] = 1},
	["TextLabel"] = {["TextTransparency"] = 1, ["TextStrokeTransparency"] = 1},
	["TextBox"] = {["TextTransparency"] = 1, ["TextStrokeTransparency"] = 1},
	["ScrollingFrame"] = {["ScrollBarImageTransparency"] = 1},
	["GuiObject"] = {["BackgroundTransparency"] = 1},
	["ImageButton"] = {["ImageTransparency"] = 1},
	["ImageLabel"] = {["ImageTransparency"] = 1},
	["UIStroke"] = {["Transparency"] = 1},

	["ProximityPrompt"] = {["Enabled"] = false},
	["ForceField"] = {["Visible"] = false},
	["BasePart"] = {["Transparency"] = 1, ["CanCollide"] = false, ["CanTouch"] = false, ["CanQuery"] = false, ["Material"] = Enum.Material.SmoothPlastic},
	["Texture"] = {["Transparency"] = 1},
	["Decal"] = {["Transparency"] = 1},
	
	["ParticleEmitter"] = {["Transparency"] = NumberSequence.new(1)},
	["Trail"] = {["Transparency"] = NumberSequence.new(1)},
	["Beam"] = {["Enabled"] = false},
}

function module.invisible(model)
	if not model then return end
	local descendants = model:GetDescendants()
	table.insert(descendants, model)
	for _,descendant in pairs(descendants) do
		if not savedTransparencies[descendant] then
			savedTransparencies[descendant] = {}
		end
		for class,properties in pairs(transparencyProperties) do
			if not descendant:IsA(class) then continue end
			for property,value in pairs(properties) do
				if savedTransparencies[descendant][property] then continue end
				savedTransparencies[descendant][property] = descendant[property]
				descendant[property] = value
			end
		end
	end
end

function module.visible(model)
	if not model then return end
	local descendants = model:GetDescendants()
	table.insert(descendants, model)
	for _,descendant in pairs(descendants) do
		if not savedTransparencies[descendant] then continue end
		for class,properties in pairs(transparencyProperties) do
			if not descendant:IsA(class) then continue end
			for property,_ in pairs(properties) do
				if not savedTransparencies[descendant][property] then continue end
				descendant[property] = savedTransparencies[descendant][property]
				savedTransparencies[descendant][property] = nil
			end
		end
		savedTransparencies[descendant] = nil
	end
end

function module.autoCanvasSize(canvas, layout)
	module.propertyChanged(layout, "AbsoluteContentSize", function(Value)
		local Both = canvas.ScrollingDirection == Enum.ScrollingDirection.XY
		local Y = Both or canvas.ScrollingDirection == Enum.ScrollingDirection.Y
		local X = Both or canvas.ScrollingDirection == Enum.ScrollingDirection.X
		canvas.CanvasSize = UDim2.fromOffset(X and Value.X or 0, Y and Value.Y or 0)
	end)
end

local gamePassPurchaseFunctions = {}

function module.gamePassPurchase(gamePassPurchaseFunction)
	table.insert(gamePassPurchaseFunctions, gamePassPurchaseFunction)
end

marketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, bought)
	if not bought then return end
	
	for _,gamePassPurchaseFunction in pairs(gamePassPurchaseFunctions) do
		gamePassPurchaseFunction(player, id)
	end
end)

module.productPurchaseFunctions = {}

function module.gifting(player)
	local isGifting = player:FindFirstChild("IsGifting")
	local giftingUsername = isGifting and isGifting.Value and player:FindFirstChild("GiftingUsername")
	return giftingUsername and giftingUsername.Value
end

function module.fireOtherClients(event, player, ...)
	for _,player in pairs(module.otherPlayers(player)) do
		event:FireClient(player, ...)
	end
end

function module.headshotAsync(userId, thumbnailType, thumbnailSize)
	thumbnailType = thumbnailType or "AvatarHeadShot"
	thumbnailSize = thumbnailSize or "420"
	return ("rbxthumb://type=%s&id=%s&w=%s&h=%s"):format(thumbnailType, userId, thumbnailSize, thumbnailSize)
end

function module.character(player)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	return character and hrp and humanoid, character, hrp, humanoid
end

function module.data(player)
	local data = player:FindFirstChild("Data")
	return data
end

function module.waitForData(player)
	local data,start = player:WaitForChild("Data", 60),tick()
	if not data then return end
	while #data:GetDescendants() < (data:GetAttribute("Descendants") or math.huge) do
		task.wait()
		if tick() - start > 60 then break end
	end
	return data
end

local playerAddedFunctions = {}
local playersRegistered = {}

function module.playerAddedFunction(playerAddedFunction)
	local players = players:GetPlayers()
	local index = #playerAddedFunctions+1
	playersRegistered[index] = players
	playerAddedFunctions[index] = playerAddedFunction

	for _,player in pairs(players) do
		task.spawn(playerAddedFunction, player)
	end
end

players.PlayerAdded:Connect(function(player)
	for index,playerAddedFunction in pairs(playerAddedFunctions) do
		if table.find(playersRegistered[index], player) then continue end
		table.insert(playersRegistered[index], player)
		task.spawn(playerAddedFunction, player)
	end
end)

local playerRemovingFunctions = {}

function module.playerRemovingFunction(playerRemovingFunction)
	table.insert(playerRemovingFunctions, playerRemovingFunction)
end

players.PlayerRemoving:Connect(function(player)
	for _,playerRemovingFunction in pairs(playerRemovingFunctions) do
		task.spawn(playerRemovingFunction, player)
	end
	for _,players in pairs(playersRegistered) do
		local found = table.find(players, player)
		if found then
			table.remove(players, found)
		end
	end
end)

function module.characterAddedFunction(player, characterAddedFunction)
	player.CharacterAdded:Connect(function(character)
		characterAddedFunction(character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid"))
	end)
	
	local character = player.Character
	if character then
		characterAddedFunction(character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid"))
	end
end

local renderSteppedFunctions = {}

function module.renderStepped(renderSteppedFunction)
	table.insert(renderSteppedFunctions, renderSteppedFunction)
end

if runService:IsClient() then
	runService.RenderStepped:Connect(function(delta)
		for _,renderSteppedFunction in pairs(renderSteppedFunctions) do
			task.spawn(renderSteppedFunction)
		end
	end)
else
	runService.Stepped:Connect(function(delta)
		for _,renderSteppedFunction in pairs(renderSteppedFunctions) do
			task.spawn(renderSteppedFunction, delta)
		end
	end)
end

local heartbeatFunctions = {}

function module.heartbeat(heartbeatFunction)
	table.insert(heartbeatFunctions, heartbeatFunction)
end

runService.Heartbeat:Connect(function(delta)
	for _,heartbeatFunction in pairs(heartbeatFunctions) do
		task.spawn(heartbeatFunction, delta)
	end
end)

function module.create(class, parent, name, value)
	local instance = Instance.new(class)
	if value then
		instance.Value = value or ""
	end
	instance.Name = name
	instance.Parent = parent
	return instance
end

function module.forcePcall(attempts, debounce, ...)
	local result = {false}
	while not result[1] do
		attempts -= 1
		result = table.pack(pcall(...))
		if attempts == 0 or result[1] then break end
		task.wait(debounce)
	end
	return table.unpack(result, 2, #result), result[1]
end

function module.fromEnum(enum)
	return tostring(enum):match("%..+%.(.+)")
end

function module.roundToNumber(start, grid)
	return math.floor(((start+grid/2)/(grid)))*(grid)
end

local debugParts = {}

function module.debugPart(cframe, index)
	index = index or 1
	local debugPart = debugParts[index]
	if not debugPart then
		debugPart = Instance.new("Part", workspace)
		debugPart.Size = Vector3.one
		debugPart.Color = Color3.fromHSV((index/15)%1,1,1)
		debugPart.Anchored = true
		debugPart.CanCollide = false
		debugPart.CanTouch = false
		debugPart.CanQuery = false
		debugPart.CastShadow = false
		debugParts[index] = debugPart
	end
	cframe = typeof(cframe) == "Vector3" and CFrame.new(cframe) or cframe
	debugPart.CFrame = cframe
end

function module.onDestroy(part, event)
	local function run()
		if part.Parent then return end
		
		if typeof(event) == "function" then
			event()
		elseif typeof(event) == "Instance" then
			module.destroy(event)
		end
	end

	part.AncestryChanged:Connect(run)
	run()
end

function module.otherPlayers(player)
	local allPlayers = players:GetPlayers()
	local found = table.find(allPlayers, player or players.LocalPlayer)
	if found then
		table.remove(allPlayers, found)
	end
	return allPlayers
end

function module.modelToGround(part, model)
	local cf = part.CFrame * CFrame.new(0,-part.Size.Y/2,0)
	local pivot,boundingBox = model:GetPivot(),model:GetBoundingBox()
	local pivotOffset = pivot:ToObjectSpace(boundingBox)
	model:PivotTo(cf * pivotOffset:Inverse() * CFrame.new(0,model:GetExtentsSize().Y/2,0))
end

function module.changed(instance, changedFunction)
	local old = instance.Value
	instance.Changed:Connect(function()
		local new = instance.Value
		task.spawn(changedFunction, new, old)
		old = new
	end)
	changedFunction(old, old)
end

function module.propertyChanged(instance, property, propertyChangedFunction)
	local old = instance[property]
	instance:GetPropertyChangedSignal(property):Connect(function()
		local new = instance[property]
		task.spawn(propertyChangedFunction, new, old)
		old = new
	end)
	propertyChangedFunction(old, old)
end

function module.attributeChanged(instance, attribute, attributeChangedFunction)
	local old = instance:GetAttribute(attribute)
	instance:GetAttributeChangedSignal(attribute):Connect(function()
		local new = instance:GetAttribute(attribute)
		task.spawn(attributeChangedFunction, new, old)
		old = new
	end)
	attributeChangedFunction(old, old)
end

function module.createTrigger(instance, name)
	instance:SetAttribute(name, (instance:GetAttribute(name) or 0) + 1)
end

function module.onTrigger(instance, name, triggerFunction)
	instance:GetAttributeChangedSignal(name):Connect(triggerFunction)
end

function module.chance(chancedictionary)
	local chanceTable = {}
	for name,data in pairs(chancedictionary) do
		table.insert(chanceTable, {Name = name, Chance = data.Chance})
	end
	
	table.sort(chanceTable, function(a,b) return a.Chance < b.Chance end)
	
	local totalChance = 0
	for i,data in pairs(chanceTable) do
		totalChance += data.Chance
	end
	
	local chosenChance = module.random(0, totalChance)
	local currentChance = 0
	
	for i,data in pairs(chanceTable) do
		currentChance += data.Chance
		if chosenChance < currentChance then
			return data.Name
		end
	end
end

function module.generateGUID(...)
	return httpService:GenerateGUID(...)
end

function module.name()
	local createdName = names[module.randomInt(0, #names)]
	return createdName
end

local types = {
	["table"] = "Folder",
	["boolean"] = "BoolValue",
	["number"] = "NumberValue",
	["string"] = "StringValue",
}

function module.getType(value)
	return types[typeof(value)]
end

function module.valueToObject(value, name)
	return module.create(module.getType(value), nil, name, value)
end

function module.tableToObject(tab, folderName)
	local folder = module.create("Folder", nil, folderName)
	for name,value in pairs(tab) do
		local class = module.getType(value)
		if class == "Folder" then
			module.tableToObject(value, name).Parent = folder
		else
			module.create(class, folder, name, value)
		end
	end
	return folder
end

function module.objectToTable(folder)
	local tab = {}
	for i,value in pairs(folder:GetChildren()) do
		if value.ClassName == "Folder" then
			tab[value.Name] = module.objectToTable(value)
		else
			tab[value.Name] = value.Value
		end
	end
	return tab
end

function module.dictionaryLength(dictionary)
	local length = 0
	for _,value in pairs(dictionary) do
		length += 1
	end
	return length
end

function module.sortDictionary(dictionary, sortFunction)
	local array = {}
	for key,value in pairs(dictionary) do
		table.insert(array, {key = key, value = value})
	end
	table.sort(array, sortFunction)
	return array
end

return module