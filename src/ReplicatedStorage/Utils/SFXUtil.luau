local SFXUtil = {}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local World = require(ReplicatedStorage.World)

export type SoundPlayData = {
	toParent: Instance?,
	pitchMult: number?,
	volumeMult: number?,
	pitchVariance: number?,
	volumeVariance: number?,
	tempClone: boolean?,
	excludeLastSounds: number?,
}

local function ensureBaselineAttributes(sound: Sound)
	World.requireAttribute(sound, "BasePlaybackSpeed", sound.PlaybackSpeed)
	World.requireAttribute(sound, "BaseVolume", sound.Volume)
end

local function applyVariance(base: number, variance: number?): number
	if not variance or variance == 0 then
		return base
	end

	local cents = (math.random() * 2 - 1) * (variance * 2)
	return base * math.pow(2, cents / 1200)
end

local function selectFromBank(folder: Folder, excludeCount: number?): Sound?
	local sounds = folder:GetChildren()
	if #sounds == 0 then
		return nil
	end

	if #sounds == 1 then
		return sounds[1] :: Sound
	end

	local candidates: {Sound}

	if excludeCount and excludeCount > 0 then
		candidates = {}
		for _, sound in sounds do
			local lastPlayed = sound:GetAttribute("LastPlayed") or math.huge
			if lastPlayed >= excludeCount then
				table.insert(candidates, sound)
			end
		end
		-- Fallback to all sounds if everything was excluded
		if #candidates == 0 then
			candidates = sounds
		end
	else
		candidates = sounds
	end

	local selected = candidates[math.random(1, #candidates)] :: Sound

	-- Update play counters: selected resets to 0, others increment
	for _, sound in sounds do
		if sound == selected then
			sound:SetAttribute("LastPlayed", 0)
		else
			local current = sound:GetAttribute("LastPlayed") or 0
			sound:SetAttribute("LastPlayed", current + 1)
		end
	end

	return selected
end

function SFXUtil.Play(soundSource: Sound | Folder, data: SoundPlayData?): Sound?
	data = data or {}

	-- Resolve sound from source
	local baseSound: Sound?
	if soundSource:IsA("Sound") then
		baseSound = soundSource
	elseif soundSource:IsA("Folder") then
		baseSound = selectFromBank(soundSource, data.excludeLastSounds)
	end

	if not baseSound then
		warn("[SFXUtil] No sound found to play")
		return nil
	end

	ensureBaselineAttributes(baseSound)

	-- Determine which sound instance to actually play
	local soundToPlay: Sound
	local shouldClone = data.tempClone or (data.toParent and data.toParent:FindFirstChild(baseSound.Name) ~= baseSound)

	if shouldClone then
		soundToPlay = baseSound:Clone()
		soundToPlay.Parent = data.toParent or baseSound.Parent
	else
		soundToPlay = baseSound
		if data.toParent then
			soundToPlay.Parent = data.toParent
		end
	end

	-- Apply pitch and volume with optional variance
	local basePitch = soundToPlay:GetAttribute("BasePlaybackSpeed")
	local baseVolume = soundToPlay:GetAttribute("BaseVolume")

	local finalPitch = applyVariance(basePitch * (data.pitchMult or 1), data.pitchVariance)
	local finalVolume = applyVariance(baseVolume * (data.volumeMult or 1), data.volumeVariance)

	soundToPlay.PlaybackSpeed = finalPitch
	soundToPlay.Volume = finalVolume

	soundToPlay:Play()

	if data.tempClone then
		local adjustedDuration = soundToPlay.TimeLength / soundToPlay.PlaybackSpeed + 0.1
		Debris:AddItem(soundToPlay, adjustedDuration)
	end

	return soundToPlay
end

return SFXUtil