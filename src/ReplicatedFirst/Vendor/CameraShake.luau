local RunService = game:GetService("RunService")

local Module = {}
local activeShakes = {}
local activeRecoils = {}

-- Simple easing function
local function easeInOut(t)
	return t * t * (3 - 2 * t)
end

--[[
	NEW SHAKE: Offset-based shake that follows the camera
	Best for: Damage effects, explosions, environmental shakes
	Returns to exact position, no drift
]]
function Module.shake(
	camera: Camera | BasePart | Attachment,
	duration: number,
	intensity: number, -- How strong the shake is (0.1 to 2.0 recommended)
	frequency: number?, -- Optional: How fast it shakes (default: 25)
	seed: number? -- Optional: Random seed
)
	camera = camera or workspace.CurrentCamera
	duration = duration or 0.5
	intensity = intensity or 0.5
	frequency = frequency or 25
	seed = seed or tick()

	local random = Random.new(seed)
	local startTime = tick()

	-- Generate random offsets for more natural shake
	local xOffset = random:NextNumber(0, 100)
	local yOffset = random:NextNumber(0, 100)
	local zOffset = random:NextNumber(0, 100)

	local function updateShake()
		local elapsed = tick() - startTime

		-- Remove shake when duration is complete
		if elapsed >= duration then
			-- Remove the last shake offset before ending
			local lastOffset = activeShakes[camera].currentOffset
			if lastOffset then
				camera.CFrame = camera.CFrame * lastOffset:Inverse()
			end
			activeShakes[camera] = nil
			return
		end

		-- Calculate fade in/out envelope
		local fadeIn = math.min(elapsed / 0.1, 1) -- Fast fade in
		local fadeOut = math.min((duration - elapsed) / 0.2, 1) -- Smooth fade out
		local envelope = easeInOut(fadeIn) * fadeOut

		-- Calculate shake using Perlin-like noise
		local t = elapsed * frequency
		local shakeX = (math.noise(t + xOffset, 0) - 0.5) * intensity * envelope
		local shakeY = (math.noise(0, t + yOffset) - 0.5) * intensity * envelope
		local shakeZ = (math.noise(t + zOffset, t + zOffset) - 0.5) * intensity * 0.5 * envelope

		-- Create shake offset
		local newOffset = CFrame.new(shakeX, shakeY, shakeZ) * CFrame.Angles(
			math.rad(shakeY * 2),
			math.rad(shakeX * 2),
			math.rad(shakeZ * 3)
		)

		-- Remove old shake offset, then apply new one
		local oldOffset = activeShakes[camera].currentOffset
		if oldOffset then
			camera.CFrame = camera.CFrame * oldOffset:Inverse()
		end
		camera.CFrame = camera.CFrame * newOffset

		-- Store current offset for next frame
		activeShakes[camera].currentOffset = newOffset
	end

	-- Store the shake function
	activeShakes[camera] = {
		update = updateShake,
		currentOffset = nil
	}

	-- Return a function to stop the shake early
	return function()
		local shake = activeShakes[camera]
		if shake and shake.currentOffset then
			camera.CFrame = camera.CFrame * shake.currentOffset:Inverse()
		end
		activeShakes[camera] = nil
	end
end

--[[
	RECOIL SHAKE: Velocity-based shake for gun recoil
	Best for: Weapon recoil, directional impacts
	Creates a "kick" effect that gradually settles
]]
function Module.shakeRecoil(
	camera: Camera | BasePart | Attachment,
	duration: number,
	xAmplitude: number, -- Horizontal intensity
	yAmplitude: number, -- Vertical intensity
	xFrequency: number?, -- Horizontal speed (default: 1.33)
	yFrequency: number?, -- Vertical speed (default: 2.0)
	easingInDuration: number?, -- Fade in time (default: 0.1)
	easingOutDuration: number?, -- Fade out time (default: 0.2)
	easingWeight: number?, -- Easing curve strength (default: 2)
	seed: number? -- Optional seed for variation
)
	xFrequency = xFrequency or 1.33
	yFrequency = yFrequency or 2.0
	easingInDuration = easingInDuration or 0.1
	easingOutDuration = easingOutDuration or 0.2
	easingWeight = easingWeight or 2

	local time = 0
	local timeOffset = 0
	local amplitude = 0

	-- Randomize phase/frequency offsets if a seed is given
	if seed then
		local rng = Random.new(seed)
		timeOffset = rng:NextNumber(0, math.pi * 2)
		xFrequency *= 0.8 + rng:NextNumber() * 0.4
		yFrequency *= 0.8 + rng:NextNumber() * 0.4
		xAmplitude *= 0.8 + rng:NextNumber() * 0.4
		yAmplitude *= 0.8 + rng:NextNumber() * 0.4
	end

	local function step(dt: number)
		local sign = if time > duration - easingOutDuration then -1 else 1

		amplitude += if sign > 0
			then dt / easingInDuration
			else -dt / easingOutDuration

		amplitude = math.clamp(amplitude, 0, 1)

		if amplitude <= 0 then
			activeRecoils[step] = nil
			return
		end

		local weighted = amplitude ^ easingWeight

		-- Calculate velocity-based shake
		local t = time + timeOffset
		local deltaX = 2 * xAmplitude * math.pi * xFrequency * math.sin(2 * math.pi * xFrequency * t) * dt
		local deltaY = 2 * yAmplitude * math.pi * yFrequency * math.cos(2 * math.pi * yFrequency * t) * dt

		local deltaCFrame = CFrame.lookAt(
			Vector3.zero,
			-Vector3.zAxis + weighted * Vector3.new(deltaX, deltaY, 0)
		)

		camera.CFrame *= deltaCFrame

		time += dt
		if time >= duration then
			activeRecoils[step] = nil
			return
		end
	end

	activeRecoils[step] = true

	-- Return function to stop early
	return function()
		duration = time + easingOutDuration
	end
end

function Module.shakeGuiObject(
	guiObject,
	seed,
	posAmplitude, posFrequency,  -- position channel
	rotAmplitude, rotFrequency,  -- rotation channel
	fadeInTime, sustainTime, fadeOutTime
)
	local startTime = tick()
	local startPosition = guiObject.Position
	local startRotation = guiObject.Rotation
	local noiseSeed = seed or 0
	local ended = Instance.new('BindableEvent')
	local running = true

	local connection
	connection = RunService.RenderStepped:Connect(function()
		local now = tick()
		local elapsed = now - startTime

		-- fade in/out
		local fadeInMultiplier = (fadeInTime and fadeInTime > 0) and math.min(elapsed / fadeInTime, 1) or 1
		local fadeOutMultiplier = 1
		if sustainTime and fadeOutTime and elapsed > (fadeInTime or 0) + (sustainTime or 0) then
			if fadeOutTime <= 0 then
				local running = false
				connection:Disconnect()
				ended:Fire()
				return
			end
			fadeOutMultiplier = 1 - (elapsed - (fadeInTime or 0) - (sustainTime or 0)) / fadeOutTime
			if elapsed >= (fadeInTime or 0) + (sustainTime or 0) + fadeOutTime then
				local running = false
				connection:Disconnect()
				ended:Fire()
				return
			end
		end
		local shakeAmount = math.clamp(fadeInMultiplier * fadeOutMultiplier, 0, 1)

		-- clamps
		posAmplitude = math.clamp(posAmplitude or 0, 0, 100)
		rotAmplitude = math.clamp(rotAmplitude or 0, 0, 360)
		posFrequency = math.clamp(posFrequency or 0, 0, 100)
		rotFrequency = math.clamp(rotFrequency or 0, 0, 100)

		-- position channel
		if posAmplitude > 0 and posFrequency > 0 then
			local posT = (now /posFrequency) % 10000
			local offsetX = (math.noise(posT + noiseSeed, 0) * 0.5) * posAmplitude
			local offsetY = (math.noise(0, posT + noiseSeed) * 0.5) * posAmplitude
			guiObject.Position = startPosition + UDim2.fromScale(offsetX * shakeAmount, offsetY * shakeAmount)
		end

		-- rotation channel (use a different noise lane)
		if rotAmplitude > 0 and rotFrequency > 0 then
			local rotT = (now / rotFrequency) % 10000
			local rotationNoise = (math.noise(rotT + noiseSeed) * 0.5) * rotAmplitude * shakeAmount
			guiObject.Rotation = rotationNoise + startRotation
		end
	end)

	return {
		ended = ended,
		destroy = function()
			if running then
				ended:Fire()
			end
			ended:Destroy()
			connection:Disconnect()
		end,
	}
end

-- Update all active shakes and recoils
RunService:BindToRenderStep("CAMERA_SHAKE", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
	-- Update offset-based shakes
	for camera, shake in pairs(activeShakes) do
		shake.update()
	end

	-- Update velocity-based recoils
	for step in pairs(activeRecoils) do
		step(dt)
	end
end)

return Module