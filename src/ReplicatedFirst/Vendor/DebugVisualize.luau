local DebugVisualize = {}

function DebugVisualize.raycast(origin: Vector3, direction: Vector3, stopOnHit: boolean?, params: RaycastParams?): (RaycastResult?, BasePart)
	-- do the raycast
	local result = workspace:Raycast(origin, direction, params)

	local endPoint = origin + direction
	if stopOnHit and result then
		endPoint = result.Position
	end

	-- draw segment as a thin anchored part
	local segment = Instance.new("Part")
	segment.Anchored = true
	segment.CanCollide = false
	segment.CanTouch = false
	segment.CanQuery = false
	segment.Material = Enum.Material.Neon
	segment.Color = Color3.fromRGB(255, 0, 0)

	local dirVec = endPoint - origin
	local len = dirVec.Magnitude
	segment.Size = Vector3.new(0.2, 0.2, len) -- thin cylinder-like bar
	segment.CFrame = CFrame.lookAt(origin + dirVec * 0.5, endPoint)
	segment.Parent = workspace

	return result, segment
end


function DebugVisualize.part(properties: {[string]: any}?): Part
	local part = Instance.new("Part")
	part.Name = 'DebugPart'
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Size = Vector3.one
	part.Parent = properties.Parent or workspace
	
	local properties = properties or {}
	for k, v in properties do
		part[k] = v
	end

	
	return part
end

function DebugVisualize.radius(at: CFrame, radius: number): Part
	local part = DebugVisualize.part(
		{
			CFrame = at,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(1, radius * 2, radius * 2),
			Name = 'DebugRadius'
		}
	)
	part.Orientation = Vector3.new(0, 0, 90)
end

return DebugVisualize
