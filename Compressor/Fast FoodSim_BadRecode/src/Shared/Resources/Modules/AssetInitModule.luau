local ReplicatedStorage = game:GetService("ReplicatedStorage")
local APIs = ReplicatedStorage.APIs
local Handler = require(APIs.handler)

local M = {}

function M.initAssetModels(Container, withPadding, withAttachment, addIngredientsFolder)
	for _, Model in pairs(Container:GetChildren()) do
		local Drag = Instance.new("Part"); local CF,Size = Model:GetBoundingBox(); if withAttachment then Instance.new("Attachment", Drag) end; Drag.Size=Size; Drag.CFrame=CF; Drag.CanCollide=false; Drag.CanQuery=false; Drag.CanTouch=false; Drag.Transparency=1; Drag.Parent=Model; Drag.Name="Drag"
		if withPadding then local Padding=Drag:Clone(); Padding.Size=Size*Vector3.new(1,0,1)+Vector3.new(0,0.1,0); Padding.CFrame*=CFrame.new(0,-Drag.Size.Y/2-0.05,0); Padding.Name="Padding"; Padding.CanCollide=true; Padding.Parent=Model end
		Model.PrimaryPart=Drag
		for _,Descendant in pairs(Model:GetDescendants()) do if not Descendant:IsA("BasePart") then continue end; Descendant.CollisionGroup="Ingredients"; Descendant.Anchored=false; local Weld=Instance.new("Weld"); Weld.C0=Drag.CFrame:ToObjectSpace(Descendant.CFrame); Weld.Part0=Drag; Weld.Part1=Descendant; Weld.Parent=Descendant end
		if addIngredientsFolder then local Ingredients=Handler.create("Folder", Model, "Ingredients"); Handler.create("StringValue", Ingredients, Model.Name, "") end
	end
end

return M


