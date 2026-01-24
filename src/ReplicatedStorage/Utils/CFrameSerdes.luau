--!strict
local CFrameSerdes = {}

function CFrameSerdes.Serialize(cf: CFrame): string
	local components = { cf:GetComponents() }
	return table.concat(components, ",")
end

function CFrameSerdes.Deserialize(str: string): CFrame
	local components = {}
	for value in string.gmatch(str, "[^,]+") do
		table.insert(components, tonumber(value))
	end
	return CFrame.new(unpack(components))
end

function CFrameSerdes.ToWorldSpace(PlotFolder: Instance, objectSpaceCFrame: CFrame): CFrame
	local Base = PlotFolder:FindFirstChild("Base")
	if not Base or not Base:IsA("BasePart") then
		return objectSpaceCFrame
	end
	return Base.CFrame:ToWorldSpace(objectSpaceCFrame)
end

function CFrameSerdes.ToObjectSpace(PlotFolder: Instance, worldSpaceCFrame: CFrame): CFrame
	local Base = PlotFolder:FindFirstChild("Base")
	if not Base or not Base:IsA("BasePart") then
		return worldSpaceCFrame
	end
	return Base.CFrame:ToObjectSpace(worldSpaceCFrame)
end

return CFrameSerdes
