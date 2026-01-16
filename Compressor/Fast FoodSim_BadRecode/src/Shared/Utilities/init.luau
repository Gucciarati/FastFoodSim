local player = game:GetService('Players').LocalPlayer--; repeat wait() player = game:GetService('Players').LocalPlayer until player
local runService = game:GetService('RunService')
for i = 1, 10 do
	if player or runService:IsServer() then break end
	wait()
	player = game:GetService('Players').LocalPlayer
end
local stepped
pcall(function() stepped = runService.RenderStepped end)
local util = {}
util.uid = require(script.Ascii85).uid
util.Timing = require(script.Timing)
local Timing = util.Timing
local debugSyncs = false

util.lerpCFrame = require(script.CFrameInterpolator)

local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local remainingSeconds = seconds % 60

	local formattedHours = string.format("%02d", hours)
	local formattedMinutes = string.format("%02d", minutes)
	local formattedSeconds = string.format("%02d", remainingSeconds)

	local formattedTime = formattedHours .. ":" .. formattedMinutes .. ":" .. formattedSeconds

	return formattedTime
end

util.formatTime = formatTime
do
	local debugInstances = true
	local classes = {}
	function util.class(nc, newf)
		nc = nc or {}
		nc.__index = nc
		local classDebugData
		if debugInstances and nc.className then
			classDebugData = {name = nc.className, class = nc, instances = setmetatable({}, {__mode='v'})}
			table.insert(classes, classDebugData)
		end
		function nc:new(o, ...)
			o = o or {}
			if type(o) == 'table' and not getmetatable(o) then -- cannot assume all classes contruct using base object
				setmetatable(o, nc)
			end
			if newf then
				o = newf(o, ...) or o
			end
			if type(o) == 'table' and not getmetatable(o) then
				setmetatable(o, nc)
			end
			if classDebugData then
				table.insert(classDebugData.instances, o)
			end
			return o
		end
		return nc
	end
	function util.subclass(super, nc, newf)
		nc = util.class(nc, newf)
		nc.super = super
		nc.__index = function(_, key)
			return rawget(nc, key) or super[key]
		end
		return nc
	end
	function util.setupDestroyWatch()
		if not debugInstances then return end
		for _, class in pairs(classes) do
			local oldDestroy = class.class.destroy
			if not oldDestroy then
				--				warn(class.name .. ' does not have a destroy() function')
				class.lacksDestroy = true
			end
			class.class.destroy = function(obj, ...)
				local instances = class.instances
				for i = #instances, 1, -1 do
					if instances[i] == obj then
						table.remove(instances, i)
					end
				end
				if oldDestroy then oldDestroy(obj, ...) end
				if type(obj) == 'table' then 
					for i in pairs(obj) do
						obj[i] = nil
					end
				end

			end
		end
	end
	function util.debugClasses()
		if not debugInstances then print('instance debug disabled') return end
		table.sort(classes, function(a, b) return a.name < b.name end)
		for _, class in pairs(classes) do
			print(class.name .. ': ' .. #class.instances .. (class.lacksDestroy and ' [?]' or ''))
		end
	end
end

-- https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
-- maxDepth added
function util.print_r ( t , maxDepth )  
	local print_r_cache={}
	local function sub_print_r(t,indent,mDepth)
		if mDepth == 0 then print(indent..'...') return end
		if (print_r_cache[tostring(t)]) then
			print(indent.."*"..tostring(t))
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					if (type(val)=="table") then
						print(indent.."["..pos.."] => "..tostring(val).." {")
						sub_print_r(val,indent..string.rep(" ",string.len(pos)+8),mDepth and mDepth-1)
						print(indent..string.rep(" ",string.len(pos)+6).."}")
					elseif (type(val)=="string") then
						print(indent.."["..pos..'] => "'..val..'"')
					else
						print(indent.."["..pos.."] => "..tostring(val))
					end
				end
			else
				print(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		print(tostring(t).." {")
		sub_print_r(t,"  ",maxDepth)
		print("}")
	else
		sub_print_r(t,"  ")
	end
	print()
	--print(t)
end

function util.lerp(a, b, t)
	return a + (b - a) * t
end
-- mutates ignoreList
function util.findPartOnRayWithIgnoreFunction(ray, ignoreList, ignoreFunction)
	if type(ignoreList) == 'function' then
		ignoreFunction = ignoreList
		ignoreList = {}
	end
	local hit, pos, normal, material
	repeat
		hit, pos, normal, material = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
		if hit then
			if ignoreFunction(hit) then
				table.insert(ignoreList, hit)
			else
				return hit, pos, normal, material
			end
		end
	until not hit
	return hit, pos, normal, material
end

function util.comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function util.aOrAn(str, upper)
	local vowels = {a=true,e=true,i=true,o=true,u=true}
	if vowels[str:sub(1,1):lower()] then
		return upper and 'An '..str or 'an '..str
	end
	return upper and 'A '..str or 'a '..str
end

local function deepcopy(t)
	if type(t) ~= 'table' then return t end
	local mt = getmetatable(t)
	local res = {}
	for k, v in pairs(t) do
		if type(v) == 'table' then
			v = deepcopy(v)
		end
		res[k] = v
	end
	setmetatable(res, mt)
	return res
end
util.deepcopy = deepcopy

function util.shallowcopy(t)
	if type(t) ~= 'table' then return t end
	local c = {}
	for k, v in pairs(t) do
		c[k] = v
	end
	return c
end

function util.weightedRandom(objects, getWeight, rand)
	if not objects or #objects == 0 then return nil end
	rand = rand or math.random
	local objectsAndWeights = {}
	local totalWeight = 0
	for _, obj in pairs(objects) do
		local weight = getWeight(obj)
		table.insert(objectsAndWeights, {obj, weight})
		totalWeight = totalWeight + weight
	end
	local r = rand()*totalWeight
	for _, thing in pairs(objectsAndWeights) do
		if thing[2] >= r then
			return thing[1]
		end
		r = r - thing[2]
	end
	warn('! defaulting to last object in wtRdm') -- should never execute this
	return objectsAndWeights[#objectsAndWeights][1]
end

function util.Sync(fnList) -- returns the first return value of each function as collective tuple
	--	print('synchronizing', #fnList, 'functions')
	local nFunctions = 0
	local nReturnedFunctions = 0
	local completionSignal = util.Signal()
	local err
	local returnList = {}
	for i, fn in pairs(fnList) do
		if type(fn) == 'function' then
			nFunctions = nFunctions + 1
			spawn(function()
				if debugSyncs then
					local s, r = pcall(fn)
					if s then
						nReturnedFunctions = nReturnedFunctions + 1
						returnList[i] = r
					else
						err = r
					end
				else
					returnList[i] = (fn())
					nReturnedFunctions = nReturnedFunctions + 1
				end
				completionSignal:fire()
			end)
		end
	end
	while nReturnedFunctions < nFunctions do
		if err then
			error('Encountered an error during sync: '..err)
		end
		completionSignal:wait()
	end
	return unpack(returnList)
end

local gui, fader
if player and not script.Parent:IsA('ServerStorage') then
	local playerGui = player:WaitForChild('PlayerGui')
	util.backGui = Instance.new('ScreenGui', playerGui)
	util.backGui.Name = 'BackGui'

	gui = Instance.new('ScreenGui', playerGui)
	gui.Name = 'MainGui'
	
	util.gui = gui
	fader = Instance.new('Frame', gui)
	fader.Name = 'FadeGui'
	fader.BorderSizePixel = 0
	fader.Size = UDim2.new(1.0, 200, 1.0, 100)
	fader.Position = UDim2.new(0.0, -80, 0, -80)
	fader.BackgroundTransparency = 1.0
	fader.BackgroundColor3 = Color3.new(0, 0, 0)
	util.fadeGui = fader

	util.frontGui = Instance.new('ScreenGui', playerGui)
	util.frontGui.Name = 'FrontGui'
	util.frontGui.DisplayOrder = 3 

	util.soundContainer = Instance.new('ScreenGui', playerGui)
	util.soundContainer.Name = 'SoundContainer'

	util.simulatedCoreGui = Instance.new('ScreenGui', playerGui)
	util.simulatedCoreGui.Name = 'SimulatedCoreGui'
end


do
	--[[
		Script_ing's Comment 10/1/2020
		After running various tests, I have concluded that RC4 is 0.0014 (14e-4) seconds faster than SHA256.
		However, SHA256 is much more secure - in fact, it's so much more secure that the US government requires certain passwords to be hashed with SHA256.
		This information certainly begs the question: Which one should be used for Elemental Adventures?
		
		--
		The length of the string produced by RC4 = the length of the string sent into RC4.
		However, for SHA256, the length of the string produced by the SHA256 algorithm will always be 64 characters long. 
		This makes it much harder for an exploiter to figure out the contents of the string, and thus: if used wisely with cross server-client communication, 
		fooling exploiters may be much more feasible. 
	]]
	local rc4 = require(script.RC4) '62217fea-8ffb42fc-b2b5cd4d-9c0bc997'
	util.rc4 = rc4
	function util.rc4equal(x, y)
		local typeX = type(x)
		if typeX ~= type(y) then return false end
		if typeX == 'table' then return rc4(x) == rc4(y) end
		return x == y
	end
	local sha256 = require(script.SHA256)
	util.sha256 = sha256
end


function util.Signal(debugOff)
	local sig = {}

	local mSignaler = Instance.new('BindableEvent')

	local mArgData = nil
	local mArgDataCount = nil

	function sig:fire(...)
		--		if not debugOff then
		--			print('firing signal')
		--			print(debug.traceback())
		--		end
		mArgData = {...}
		mArgDataCount = select('#', ...)
		mSignaler:Fire()
	end

	function sig:connect(f)
		if not f then error('connect(nil)', 2) end
		return mSignaler.Event:connect(function()
			f(unpack(mArgData, 1, mArgDataCount))
		end)
	end

	function sig:wait()
		mSignaler.Event:wait()
		assert(mArgData, 'Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.')
		return unpack(mArgData, 1, mArgDataCount)
	end

	return sig
end

function util.Tween(duration, timing, fn, priority)
	local doesEndZero = timing == 'sineBack'
	if duration == 0 then
		fn(1, 0)
		return true
	end
	if type(timing) == 'string' then
		timing = Timing[timing](duration)
	end
	local st = tick()
	if fn(0, 0) == false then return false end

	while true do
		if not runService:IsServer() then 
			stepped:Wait()
		else 
			game:GetService('RunService').Heartbeat:Wait()
		end
		
		local et = tick()-st
		if et >= duration then
			fn(doesEndZero and 0 or 1, duration)
			return true
		end
		local a = et/duration
		if timing then
			a = timing(et)
		end
		if fn(a, et) == false then
			return false
		end
	end
end


function util.sound(id, volume, playFromTime, destroyAfter, playFromPart, fade)
	local sound = util.Create("Sound")({
		SoundId = type(id) == "number" and "rbxassetid://" .. id or id,
		Volume = volume or 0.5,
		TimePosition = playFromTime or 0,
		Parent = playFromPart or util.soundContainer or workspace
	})
	sound:Play()
	game:GetService('Debris'):AddItem(sound, destroyAfter or 15)
	return sound
end


function util.Create(instanceType)
	return function(data)
		local obj = Instance.new(instanceType)
		for k, v in pairs(data) do
			local s, e = pcall(function()
				if type(k) == 'number' then
					v.Parent = obj
				elseif type(v) == 'function' then
					obj[k]:connect(v)
				elseif type(k) == 'boolean' then 
					--do nothing
				else
					obj[k] = v
				end
			end)
			if not s then
				error('Create: could not set property '..k..' of '..instanceType..' ('..e..')', 2)
			end
		end
		return obj
	end
end

function util.loopSound(id, volume, loopId, playbackSpeed)
	if type(id) == 'table' then
		id, loopId = unpack(id)
	end
	if id == 317469005 then volume = .7 end -- eclipse battle music

	local sound = util.Create 'Sound' {
		SoundId = type(id)=='number' and ('rbxassetid://'..id) or id,
		Volume = volume or .5,
		Looped = loopId==nil,
		Parent = workspace,
		PlaybackSpeed = playbackSpeed or 1
	}
	local sound2
	local stopped = false
	if loopId then
		sound2 = util.Create 'Sound' {
			SoundId = type(loopId)=='number' and ('rbxassetid://'..loopId) or loopId,
			Volume = volume or .5,
			Looped = true,
			Parent = util.soundContainer or workspace,
		}
		sound.Ended:connect(function()
			if stopped then return end
			sound2.Volume = sound.Volume
			sound2.Name = sound.Name
			local oldSound = sound
			delay(.5, function() -- Jul 28 '16 ROBLOX update bug workaround
				oldSound:Destroy()
			end)
			sound = sound2
			sound2 = nil
			sound:Play()
		end)
	end
	sound:Play()
	if player then 
		player.Character.Humanoid.Died:Connect(function()
			stopped = true
			sound:Stop()
			delay(.5, function() -- Jul 28 '16 ROBLOX update bug workaround
				sound:Destroy()
				if sound2 then sound2:Destroy() end
			end)
		end)
	end
	return setmetatable({
		Stop = function()
			stopped = true
			sound:Stop()
		end,
		Destroy = function()
			stopped = true
			sound:Stop()
			delay(.5, function() -- Jul 28 '16 ROBLOX update bug workaround
				sound:Destroy()
				if sound2 then sound2:Destroy() end
			end)
		end
	}, {
		__index = function(_, key)
			return sound[key]
		end,
		__newindex = function(_, key, value)
			sound[key] = value
		end
	})
end


function util.FadeOut(duration, color, fn)
	fader.ZIndex = 10
	fader.BackgroundColor3 = color or Color3.new(0, 0, 0)
	local s = fader.BackgroundTransparency
	local e = 0.0
	if not duration then 
		duration = .65
	end
	util.Tween(duration, nil, function(a)
		fader.BackgroundTransparency = s + (e-s)*a
		if fn then
			fn(a)
		end
	end)
end


function util.isTouchDevice()
	local touchEnabled = false
	pcall(function() touchEnabled = game:GetService('UserInputService').TouchEnabled end)
	return touchEnabled
end

function util.isPhone()
	if not gui then return false end
	return util.isTouchDevice() and gui.AbsoluteSize.X <= 851
end


function util.FadeIn(duration, fn)
	if not duration then 
		duration = .65
	end
	local s = fader.BackgroundTransparency
	local e = 1.0
	util.Tween(duration, nil, function(a)
		fader.BackgroundTransparency = s + (e-s)*a
		if fn then
			fn(a)
		end
	end)
end

if gui and util.isTouchDevice() then 
	gui.IgnoreGuiInset = true 
end


return util