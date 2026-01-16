local BLOCK = {0, 1, 2, 3, 4, 5, 6, 7}
local WEDGE = {0, 1, 3, 4, 5, 7}
local CORNER_WEDGE = {0, 1, 4, 5, 6}
local module = {}

local function getIndices(part)
	if part:IsA("WedgePart") then
		return WEDGE
	elseif part:IsA("CornerWedgePart") then
		return CORNER_WEDGE
	end
	return BLOCK
end

local function getCorners(cf, size2, indices)
	local corners = {}
	for _, i in pairs(indices) do
		corners[i + 1] = cf * (size2 * Vector3.new(
			2 * (math.floor(i / 4) % 2) - 1,
			2 * (math.floor(i / 2) % 2) - 1,
			2 * (i % 2) - 1
		))
	end
	return corners
end

local function getModelPointCloud(model)
	local points = {}
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local indices = getIndices(part)
			local corners = getCorners(part.CFrame, part.Size / 2, indices)
			for _, wp in pairs(corners) do
				table.insert(points, wp)
			end
		end
	end
	return points
end

local function viewProjectionEdgeHits(cloud, axis, depth, tanFov2)
	local max, min = -math.huge, math.huge

	for _, lp in pairs(cloud) do
		local distance = depth - lp.Z
		local halfSpan = tanFov2 * distance

		local a = lp[axis] + halfSpan
		local b = lp[axis] - halfSpan

		max = math.max(max, a, b)
		min = math.min(min, a, b)
	end

	return max, min
end

function module.new(vpf, camera)
	local info = {}
	
	info.Model = nil
	info.ViewportFrame = vpf
	info.Camera = camera
	
	info._points = {}
	info._modelCFrame = CFrame.new()
	info._modelSize = Vector3.new()
	info._modelRadius = 0
	
	info._viewport = {}
	
	function info:Calibrate()
		local viewport = {}
		local size = info.ViewportFrame.AbsoluteSize

		viewport.aspect = size.X / size.Y

		viewport.yFov2 = math.rad(info.Camera.FieldOfView / 2)
		viewport.tanyFov2 = math.tan(viewport.yFov2)

		viewport.xFov2 = math.atan(viewport.tanyFov2 * viewport.aspect)
		viewport.tanxFov2 = math.tan(viewport.xFov2)

		viewport.cFov2 = math.atan(viewport.tanyFov2 * math.min(1, viewport.aspect))
		viewport.sincFov2 = math.sin(viewport.cFov2)

		info._viewport = viewport
	end
	
	function info:SetModel(model)
		info.Model = model

		local cf, size = model:GetBoundingBox()

		info._points = getModelPointCloud(model)
		info._modelCFrame = cf
		info._modelSize = size	
		info._modelRadius = size.Magnitude / 2
	end
	
	function info:GetFitDistance(focusPosition)
		local displacement = focusPosition and  (focusPosition - info._modelCFrame.Position).Magnitude or 0
		local radius = info._modelRadius + displacement

		return radius / info._viewport.sincFov2
	end
	
	function info:GetMinimumFitCFrame(orientation)
		if not info.Model then
			return CFrame.new()
		end

		local rotation = orientation - orientation.Position
		local rInverse = rotation:Inverse()

		local wcloud = info._points
		local cloud = {rInverse * wcloud[1]}
		local furthest = cloud[1].Z

		for i = 2, #wcloud do
			local lp = rInverse * wcloud[i]
			furthest = math.min(furthest, lp.Z)
			cloud[i] = lp
		end

		local hMax, hMin = viewProjectionEdgeHits(cloud, "X", furthest, info._viewport.tanxFov2)
		local vMax, vMin = viewProjectionEdgeHits(cloud, "Y", furthest, info._viewport.tanyFov2)

		local distance = math.max(
			((hMax - hMin) / 2) / info._viewport.tanxFov2,
			((vMax - vMin) / 2) / info._viewport.tanyFov2
		)

		return orientation * CFrame.new(
			(hMax + hMin) / 2,
			(vMax + vMin) / 2,
			furthest + distance
		)
	end
	
	info:Calibrate()
	
	return info
end

return module