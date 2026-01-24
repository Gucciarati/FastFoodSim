--!strict
local CFrameSerdes = require(game:GetService("ReplicatedStorage").Utils.CFrameSerdes)

local ITEM_SPACING = 4

return function (PlotFolder: Folder, DeliveryList: { any })
	local DeliveryCFrames = {}
	
	local Spawn = PlotFolder:FindFirstChild("Spawn", true)
	local SpawnCFrame = Spawn and Spawn.CFrame or PlotFolder.Base.CFrame
	
	for Index, Item in DeliveryList do
		local CframeData = Item.Cframe or Item.CF
		
		local ObjectSpaceCFrame: CFrame
		if CframeData then
			if typeof(CframeData) == "string" then
				ObjectSpaceCFrame = CFrameSerdes.Deserialize(CframeData)
			else
				ObjectSpaceCFrame = CframeData
			end
		else
			local offset = CFrame.new(math.random(-10, 10), math.random(5, 10), math.random(-10, 10))
			local WorldCFrame = SpawnCFrame * offset
			ObjectSpaceCFrame = CFrameSerdes.ToObjectSpace(PlotFolder, WorldCFrame)
			Item.Cframe = CFrameSerdes.Serialize(ObjectSpaceCFrame)
		end
		
		local WorldCFrame = CFrameSerdes.ToWorldSpace(PlotFolder, ObjectSpaceCFrame)
		table.insert(DeliveryCFrames, WorldCFrame)
	end
	
	return DeliveryCFrames
end
