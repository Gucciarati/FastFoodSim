--!strict

local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

-- line of sight helper
local function isVisible(origin: Vector3, targetPos: Vector3, targetInstance: Instance, rayParams: RaycastParams): boolean
	local dir = targetPos - origin
	if dir.Magnitude == 0 then
		return true
	end
	local result = workspace:Raycast(origin, dir, rayParams)
	if not result then
		return false
	end

	local hit = result.Instance
	return hit == targetInstance or hit:IsDescendantOf(targetInstance)
end


local function sortByDistanceFromOrigin<T>(items: {any}, origin: Vector3, getPositionFn: (any) -> Vector3)
	table.sort(items, function(a, b)
		local pa = getPositionFn(a)
		local pb = getPositionFn(b)

		local da = pa - origin
		local db = pb - origin

		local da2 = da.X * da.X + da.Y * da.Y + da.Z * da.Z
		local db2 = db.X * db.X + db.Y * db.Y + db.Z * db.Z

		return da2 < db2
	end)
end


-- Core function for part detection (box)
local function getPartsInBox(atCFrame: CFrame, size: Vector3, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?): {BasePart}
	local origin = atCFrame.Position
	local overlapParams = op
	local raycastParams = rp

	local parts = workspace:GetPartBoundsInBox(atCFrame, size, overlapParams)

	-- Optional line of sight filter
	if raycastParams then
		local visibleParts = table.create(#parts)
		for _, part in parts do
			local p = part:GetPivot().Position
			if isVisible(origin, p, part, raycastParams) then
				table.insert(visibleParts, part)
			end
		end
		parts = visibleParts
	end

	if shouldSort then
		sortByDistanceFromOrigin(parts, origin, function(part)
			return (part.GetPivot and part:GetPivot().Position) or part.Position
		end)
	end

	return parts :: {BasePart}
end

-- Model variant with deduplication (box)
local function getPVInstancesInBox(atCFrame: CFrame, size: Vector3, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?): {PVInstance}
	local origin = atCFrame.Position

	-- OPTIMIZATION: Skip sorting in getPartsInBox since we'll sort at the end anyway
	local parts = getPartsInBox(atCFrame, size, op, rp)

	local seen: {[PVInstance]: boolean} = {}
	local pvInstances: {PVInstance} = {}

	for _, part in parts do
		local model = part:FindFirstAncestorOfClass("Model")
		local target: PVInstance = model or part
		if not seen[target] then
			seen[target] = true
			table.insert(pvInstances, target)
		end
	end

	-- OPTIMIZATION: Only sort once at the end if needed
	if shouldSort then
		sortByDistanceFromOrigin(pvInstances, origin, function(inst)
			return (inst:IsA("Model") and inst:GetPivot().Position) or (inst :: BasePart).Position
		end)
	end

	return pvInstances
end

-- Convenience: get players by deduping characters found via models query (box)
local function getPlayersInBox(atCFrame: CFrame, size: Vector3, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?): {Player}
	local origin = atCFrame.Position

	-- OPTIMIZATION: Skip intermediate sorting
	local insts = getPVInstancesInBox(atCFrame, size, op, rp)

	local seenPlayers: {[Player]: boolean} = {}
	local playersInRange: {Player} = {}

	for _, inst in insts do
		local player = Players:GetPlayerFromCharacter(inst :: Model)
		if player and not seenPlayers[player] then
			seenPlayers[player] = true
			table.insert(playersInRange, player)
		end
	end

	if shouldSort then
		sortByDistanceFromOrigin(playersInRange, origin, function(player)
			return player.Character and player.Character:GetPivot().Position or origin
		end)
	end

	return playersInRange
end

-- Humanoids via models (box)
local function getHumanoidsInBox(atCFrame: CFrame, size: Vector3, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?): {Humanoid}
	local origin = atCFrame.Position

	local insts = getPVInstancesInBox(atCFrame, size, op, rp)

	local humanoids = {} :: {Humanoid}
	for _, inst in insts do
		local model = inst:IsA("Model") and inst or inst:FindFirstAncestorOfClass("Model")
		if model then
			local hum = model:FindFirstChildWhichIsA("Humanoid")
			if hum then
				table.insert(humanoids, hum :: Humanoid)
			end
		end
	end

	if shouldSort then
		sortByDistanceFromOrigin(humanoids, origin, function(hum)
			return (hum.Parent :: Model):GetPivot().Position
		end)
	end

	return humanoids
end

-- Core function for part detection (radius)
local function getPartsInRadius(atCFrame: CFrame, radius: number, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?): {BasePart}
	local origin = atCFrame.Position
	local overlapParams = op
	local raycastParams = rp

	local parts = workspace:GetPartBoundsInRadius(origin, radius, overlapParams or OverlapParams.new())

	-- Optional line of sight filter
	if raycastParams then
		local visibleParts = {}
		for _, part in parts do
			if isVisible(origin, part.Position, part, raycastParams) then
				table.insert(visibleParts, part)
			end
		end
		parts = visibleParts
	end

	if shouldSort then
		sortByDistanceFromOrigin(parts, origin, function(part)
			return part:GetPivot().Position
		end)
	end

	return parts
end

-- Model variant with deduplication (radius)
local function getPVInstancesInRadius(atCFrame: CFrame, radius: number, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?): {PVInstance}
	local origin = atCFrame.Position

	local parts = getPartsInRadius(atCFrame, radius, op, rp)

	local seen = {} 
	local pvInstances = {} 

	for _, part in parts do
		local model = part:FindFirstAncestorOfClass("Model")
		local target = model or part
		if not seen[target] then
			seen[target] = true
			table.insert(pvInstances, target :: PVInstance)
		end
	end

	if shouldSort then
		sortByDistanceFromOrigin(pvInstances, origin, function(inst)
			return inst:GetPivot().Position
		end)
	end

	return pvInstances
end

-- Convenience: get players by deduping characters found via models query (radius)
local function getPlayersInRadius(atCFrame: CFrame, radius: number, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?): {Player}
	local origin = atCFrame.Position

	local models = getPVInstancesInRadius(atCFrame, radius, op, rp) :: {Model | Part}

	local seenPlayers: {[Player]: boolean} = {}
	local playersInRange: {Player} = {}

	for _, pvInstance in models do
		local player = Players:GetPlayerFromCharacter(pvInstance :: Model)
		if player and not seenPlayers[player] then
			seenPlayers[player] = true
			table.insert(playersInRange, player)
		end
	end

	if shouldSort then
		sortByDistanceFromOrigin(playersInRange, origin, function(player)
			return player.Character and player.Character:GetPivot().Position or origin
		end)
	end

	return playersInRange
end

-- Humanoids via models (radius)
local function getHumanoidsInRadius(atCFrame: CFrame, radius: number, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?): {Humanoid}
	local origin = atCFrame.Position

	local models = getPVInstancesInRadius(atCFrame, radius, op, rp)

	local humanoids = {} :: {Humanoid}

	for _, model in models do
		if model then
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hum then
				table.insert(humanoids, hum :: Humanoid)
			end
		end
	end

	if shouldSort then
		sortByDistanceFromOrigin(humanoids, origin, function(hum)
			return (hum.Parent :: Model):GetPivot().Position
		end)
	end

	return humanoids
end



--\\ Zone util is intentionally bare-bones: it only tracks previous and current sets.
--\\ You drive the CFrame/size yourself by calling the observe functions each frame.
--\\ If you stop updating, currentSet becomes outdated, and when you resume,
--\\ the exited callback will fire for every player no longer in the zone.

type QueryCallback<T> = (detected: T, queryResult: {T}, queryLookup: {[T]: true}, previousQueryLookup: {[T]: true}) -> ()
type ZoneData = {
	currentSet: {[any]: true},
	previousSet: {[any]: true},
	detectedInstances: {any},
}

type ZoneQuery<M, T> = (at: CFrame, size: M, entered: QueryCallback<T>, exited: QueryCallback<T>?, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?) -> {T}

local function buildSpatialQuery<M, T>(zone: ZoneData, queryFn: (at: CFrame, size: M, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?) -> {T}): ZoneQuery<M, T>
	return function(at: CFrame, size: M, entered: QueryCallback<T>, exited: QueryCallback<T>?, op: OverlapParams?, rp: RaycastParams?, shouldSort: true?)
		table.clear(zone.currentSet)

		-- keep the raw query separate, then copy into the shared buffer
		local queryResults = queryFn(at, size, op, rp, shouldSort)
		local detectedInstances = zone.detectedInstances

		-- keep external reference stable
		table.clear(detectedInstances)

		for i = 1, #queryResults do
			local detectedInstance = queryResults[i]
			detectedInstances[i] = detectedInstance
			zone.currentSet[detectedInstance] = true
		end

		-- entered
		for detectedInstance in zone.currentSet do
			if not zone.previousSet[detectedInstance] then
				entered(detectedInstance :: any, detectedInstances :: {T}, zone.currentSet, zone.previousSet)
			end
		end

		-- exited
		if exited then
			for detectedInstance in zone.previousSet do
				if not zone.currentSet[detectedInstance] then
					exited(detectedInstance :: any, detectedInstances :: {T}, zone.currentSet, zone.previousSet)
				end
			end
		end

		zone.previousSet, zone.currentSet = zone.currentSet, zone.previousSet

		return detectedInstances :: {T}
	end
end

local function boxZone()
	local zone: ZoneData = {
		currentSet = {},
		previousSet = {},
		detectedInstances = {},
	}

	local observe = {
		forPlayers = buildSpatialQuery(zone, getPlayersInBox) :: ZoneQuery<Vector3, Player>,
		forPvInstances = buildSpatialQuery(zone, getPVInstancesInBox) :: ZoneQuery<Vector3, PVInstance>,
		forHumanoids = buildSpatialQuery(zone, getHumanoidsInBox) :: ZoneQuery<Vector3, Humanoid>,
		forParts = buildSpatialQuery(zone, getPartsInBox) :: ZoneQuery<Vector3, BasePart>,
	}

	return {
		-- zone is private, but this table stays stable across calls
		detectedInstances = zone.detectedInstances,
		observe = observe,
	}
end

local function sphereZone()
	local zone: ZoneData = {
		currentSet = {},
		previousSet = {},
		detectedInstances = {},
	}

	local observe = {
		forPlayers = buildSpatialQuery(zone, getPlayersInRadius) :: ZoneQuery<number, Player>,
		forPVInstances = buildSpatialQuery(zone, getPVInstancesInRadius) :: ZoneQuery<number, PVInstance>,
		forHumanoids = buildSpatialQuery(zone, getHumanoidsInRadius) :: ZoneQuery<number, Humanoid>,
		forParts = buildSpatialQuery(zone, getPartsInRadius) :: ZoneQuery<number, BasePart>,
	}

	return {
		detectedInstances = zone.detectedInstances,
		observe = observe,
	}
end




return {
	getPartsInRadius = getPartsInRadius,
	getPVInstancesInRadius = getPVInstancesInRadius,
	getPlayersInRadius = getPlayersInRadius,
	getHumanoidsInRadius = getHumanoidsInRadius,

	getPartsInBox = getPartsInBox,
	getPVInstancesInBox = getPVInstancesInBox,
	getPlayersInBox = getPlayersInBox,
	getHumanoidsInBox = getHumanoidsInBox,

	boxZone = boxZone,
	sphereZone = sphereZone,
	sortByDistanceFromOrigin = sortByDistanceFromOrigin
}