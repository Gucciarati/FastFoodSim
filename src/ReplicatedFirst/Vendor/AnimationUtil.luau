--!strict
-- AnimationTrackCache.lua
-- Thin cache so you can ask for tracks by (model, animation) without re-plumbing
-- API: getTrack(), isLoaded(), getAllTracks()

local AnimationUtil = {}

--\\ Internal cache: cache[model][animation] = AnimationTrack
local cache: { [Model]: { [Animation]: AnimationTrack } } = {}

-- =================
-- HELPERS
-- =================

--\\ Ensures the model always ends up with a valid Animator instance.
--\\ Priority order:
--\\   1) Return existing Animator if found.
--\\   2) If a Humanoid exists, attach a new Animator under it.
--\\   3) Otherwise, create an AnimationController and attach an Animator under that.
local function getAnimatorFor(model: Model): Animator
	-- 1) Prefer an existing Animator anywhere under the model.
	local existingAnimator = model:FindFirstChildWhichIsA("Animator", true)
	if existingAnimator then
		return existingAnimator
	end

	-- 2) If the rig uses Humanoid, attach a fresh Animator there.
	local humanoid = model:FindFirstChildWhichIsA("Humanoid", true)
	if humanoid then
		local newAnimator = Instance.new("Animator")
		newAnimator.Parent = humanoid
		return newAnimator
	end

	-- 3) No Humanoid: ensure an AnimationController on the model, then attach an Animator.
	local controller = model:FindFirstChildWhichIsA("AnimationController", true)
	if not controller then
		controller = Instance.new("AnimationController")
		controller.Name = "AnimationController"
		controller.Parent = model
	end

	local controllerAnimator = Instance.new("Animator")
	controllerAnimator.Parent = controller
	return controllerAnimator
end


--\\ Ensure per-model cache table and hook cleanup when the model dies
local function getModelCache(model: Model): { [Animation]: AnimationTrack }
	local modelBucket = cache[model]
	if modelBucket then
		return modelBucket
	end

	modelBucket = {}
	cache[model] = modelBucket

	--\\ When the model is destroyed, stop & destroy tracks and drop the bucket.
	model.Destroying:Once(function()
		local bucket = cache[model]
		if bucket then
			for _, track in bucket do
				pcall(function() track:Stop(0) end)
				pcall(function() track:Destroy() end)
			end
		end
		cache[model] = nil
	end)

	return modelBucket
end

--\\ Try to find a currently playing track that matches by Name (best-effort).
local function findPlayingTrackByName(animation: Animation, model: Model): AnimationTrack?
	local animator = getAnimatorFor(model) :: any
	local playing = animator:GetPlayingAnimationTracks()
	for _, track in playing do
		if track.Name == animation.Name then
			return track
		end
	end
	return nil
end


-- =================
-- API
-- =================
--\\ Returns the real AnimationTrack. Loads if needed.
function AnimationUtil.getAnimationTrack(animation: Animation, model: Model): AnimationTrack
	local modelCache = getModelCache(model)

	-- 1) Return cached if present.
	local cached = modelCache[animation]
	if cached then
		return cached
	end

	-- 2) Best-effort: try to reuse a currently playing track (by name).
	local playingMatch = findPlayingTrackByName(animation, model)
	if playingMatch then
		modelCache[animation] = playingMatch
		return playingMatch
	end

	-- 3) Load and cache a fresh track.
	local animator = getAnimatorFor(model) :: any
	local track = (animator :: Animator):LoadAnimation(animation)
	track.Name = animation.Name -- keep names aligned for easier debugging
	modelCache[animation] = track
	return track
end


--\\ Tells you if we “know” the track is loaded.
--\\ true if cached, or if a matching playing track is found (and then cached).
function AnimationUtil.isLoaded(animation: Animation, model: Model): boolean
	local modelBucket = cache[model]
	if modelBucket and modelBucket[animation] then
		return true
	end

	local playingMatch = findPlayingTrackByName(animation, model)
	if playingMatch then
		local bucket = getModelCache(model)
		bucket[animation] = playingMatch
		return true
	end

	return false
end

--\\ Returns *all* tracks we can see for this model right now.
--\\ This is a union of:
--\\  - tracks we loaded (cached), and
--\\  - tracks currently playing (Roblox can enumerate these only).
--\\ NOTE: Non-playing, non-cached tracks are invisible to Roblox and won’t appear here.
function AnimationUtil.getAllAnimationTracks(model: Model): { AnimationTrack }
	local results: { AnimationTrack } = {}
	local seen: { [AnimationTrack]: true } = {}

	-- 1) Add cached tracks (loaded through this util).
	local modelCache = getModelCache(model)
	for _, track in modelCache do
		if not seen[track] then
			seen[track] = true
			table.insert(results, track)
		end
	end

	-- 2) Add currently playing tracks (even if we didn’t load them, hence the seen table, so we don't insert dups).
	local animator: Animator = getAnimatorFor(model) 
	local playing: {AnimationTrack} = animator:GetPlayingAnimationTracks()
	for _, track in playing do
		if not seen[track] then
			seen[track] = true
			table.insert(results, track)
		end
	end

	return results
end


--\\ Plays the animation and returns the real AnimationTrack.
--\\ Param order (all optional): speed?, fadeTime?, weight?
function AnimationUtil.play(
	animation: Animation,
	model: Model,
	speed: number?,
	fadeTime: number?,
	weight: number?
): AnimationTrack
	local track = AnimationUtil.getAnimationTrack(animation, model)

	if not track.IsPlaying then
		track:Play(fadeTime, weight)
	end

	if speed ~= nil then
		track:AdjustSpeed(speed)
	end

	return track
end

--\\ Stops a specific animation on the model.
--\\ Guarantees a valid track via getAnimationTrack(), loading and caching if needed.
--\\ Optional: pass fadeTime for a smooth blend-out.
function AnimationUtil.stop(animation: Animation, model: Model, fadeTime: number?)
	local animationTrack = AnimationUtil.getAnimationTrack(animation, model)
	animationTrack:Stop(fadeTime or 0)
end

--\\ Creates an Animation instance from a raw asset ID.
--\\ Handy when you only have the animation’s ID but need a full Animation object
--\\ to use with any of the API functions. Example usage: 
--\\ AnimationUtil.play(AnimationUtil.assetIdToAnimation(yourAnimationIdHere), ...)
function AnimationUtil.assetIdToAnimation(animationId: string): Animation
	local animation: Animation = Instance.new('Animation')
	animation.AnimationId = animationId
	return animation	
end


--\\ Stops every visible animation track on the model right now.
--\\ Uses getAllTracks(): cached tracks + currently playing tracks.
--\\ Note: non-playing, non-cached tracks are invisible to Roblox and won’t appear.
--\\ Optional: pass fadeTime for a smooth blend-out.
function AnimationUtil.stopAllAnimations(model: Model, fadeTime: number?)
	for _, animationTrack in AnimationUtil.getAllAnimationTracks(model) do
		 animationTrack:Stop(fadeTime or 0)
	end
end

return AnimationUtil

