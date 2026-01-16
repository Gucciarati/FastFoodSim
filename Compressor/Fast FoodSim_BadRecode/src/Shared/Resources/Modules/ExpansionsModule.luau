local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Handler = require(ReplicatedStorage.APIs.handler)

local M = {}

function M.setup(expansionsFolder)
	if not expansionsFolder then return end
	local oldParent = expansionsFolder.Parent
	expansionsFolder.Parent = Workspace
	for _, Level in pairs(expansionsFolder:GetChildren()) do
		local Unplacement = Handler.create("Folder", Level, "Unplacement")
		for _, Category in pairs(Level.Placement:GetChildren()) do
			local NewCategory = Handler.create("Folder", Unplacement, Category.Name)
			local AreaParams = OverlapParams.new()
			AreaParams.FilterType = Enum.RaycastFilterType.Include
			AreaParams.FilterDescendantsInstances = Category:GetChildren()
			for _, Area in pairs(Category:GetChildren()) do
				local CF, Size = Area.CFrame, Area.Size
				for Side = -0.5, 0.5 do
					local Length = Size.Z
					local Width = Size.X
					local Streak = false
					local Segments = {}
					for Index = 1, Length do
						local CurrentCF = CF * CFrame.new(Side*Width+Side, 0, -Length/2-0.5+Index)
						if Workspace:GetPartBoundsInBox(CurrentCF, Vector3.one * 0.8, AreaParams)[1] then Streak = false continue end
						if not Streak then Streak = true table.insert(Segments, {}) end
						table.insert(Segments[#Segments], Index)
					end
					for _, Segment in pairs(Segments) do
						local FirstIndex = Segment[1]
						local LastIndex = Segment[#Segment]
						local NewArea = Area:Clone()
						local CurrentCF = CF * CFrame.new(Side*Width+Side, 0, -Length/2-0.5+(FirstIndex+LastIndex)/2)
						NewArea.Size = NewArea.Size * Vector3.new(0,1,0) + Vector3.new(1,0,1+LastIndex-FirstIndex)
						NewArea.CFrame = CurrentCF
						NewArea.Parent = NewCategory
						NewArea.Color = Color3.fromRGB(0,255,0)
					end
				end
				for Side = -0.5, 0.5 do
					local Length = Size.X
					local Width = Size.Z
					local Streak = false
					local Segments = {}
					for Index = 1, Length do
						local CurrentCF = CF * CFrame.new(-Length/2-0.5+Index, 0, Side*Width+Side)
						if Workspace:GetPartBoundsInBox(CurrentCF, Vector3.one * 0.8, AreaParams)[1] then Streak = false continue end
						if not Streak then Streak = true table.insert(Segments, {}) end
						table.insert(Segments[#Segments], Index)
					end
					for _, Segment in pairs(Segments) do
						local FirstIndex = Segment[1]
						local LastIndex = Segment[#Segment]
						local NewArea = Area:Clone()
						local CurrentCF = CF * CFrame.new(-Length/2-0.5+(FirstIndex+LastIndex)/2, 0, Side*Width+Side)
						NewArea.Size = NewArea.Size * Vector3.new(0,1,0) + Vector3.new(1+LastIndex-FirstIndex,0,1)
						NewArea.CFrame = CurrentCF
						NewArea.Parent = NewCategory
						NewArea.Color = Color3.fromRGB(0,255,0)
					end
				end
			end
		end
	end
	expansionsFolder.Parent = oldParent
end

return M


