--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Furniture = require(ReplicatedStorage.Config.Products.Furniture)
local GeneratePackages = require(ServerScriptService.Server.Features.Delivery.Helpers.GeneratePackages)
local CFrameSerdes = require(ReplicatedStorage.Utils.CFrameSerdes)
local SetAnchored = require(ReplicatedStorage.Utils.SetAnchored)
local Visibility = require(ReplicatedStorage.Utils.Visibility)

local Plots = workspace.Plots
local Assets = ReplicatedStorage.Assets

local FurnitureComponent = {}

local function GetDeliveryAreaCFrame(PlotFolder: Folder): CFrame
	local Spawn = PlotFolder:FindFirstChild("Spawn")
	if Spawn then
		local offset = CFrame.new(math.random(-10, 10), math.random(5, 10), math.random(-10, 10))
		return CFrameSerdes.ToObjectSpace(PlotFolder, Spawn.CFrame * offset)
	end
	return CFrame.new(math.random(-10, 10), 5, math.random(-10, 10))
end

type Data = {
	Furniture: { [string]: FurnitureData },
}

type FurnitureData = {
	Name: string,
	Cframe: string?,
	Occupied: boolean?,
	Id: string,
	Packed: boolean?,
}

function FurnitureComponent.Place(Player: Player, FurnitureData: FurnitureData, FurnitureCFrame: CFrame?)
	local PlotFolder = Plots:QueryDescendants(`[$OwnerId = {Player.UserId}]`)[1]
	assert(PlotFolder, `No plot folder found for {Player.UserId}`)
	
	local FurnitureModel
	if FurnitureData.Packed then
		FurnitureModel = GeneratePackages({FurnitureData})[1]
	else
		local FurnitureTemplate = Assets.Products:FindFirstChild(FurnitureData.Name, true)
		FurnitureModel = FurnitureTemplate:Clone()
	end

	local ObjectSpaceCFrame: CFrame
	if FurnitureCFrame then
		ObjectSpaceCFrame = FurnitureCFrame
	elseif FurnitureData.Cframe then
		ObjectSpaceCFrame = CFrameSerdes.Deserialize(FurnitureData.Cframe)
	else
		ObjectSpaceCFrame = GetDeliveryAreaCFrame(PlotFolder)
		FurnitureData.Cframe = CFrameSerdes.Serialize(ObjectSpaceCFrame)
	end
	
	local WorldCFrame = CFrameSerdes.ToWorldSpace(PlotFolder, ObjectSpaceCFrame)

	SetAnchored(FurnitureModel, true)

	local Size = FurnitureModel:GetExtentsSize()
	--WorldCFrame *= CFrame.new(0, Size.Y / 2, 0)

	FurnitureModel:PivotTo(WorldCFrame)
	FurnitureModel:SetAttribute("Id", FurnitureData.Id)
	FurnitureModel.Parent = PlotFolder.Furniture


	for _, Snap in FurnitureModel:GetDescendants() do
		if Snap:HasTag("Snap") then
			Visibility.HideChildren(Snap)
		end
	end

	return FurnitureModel
end

function FurnitureComponent.Unpack(PlayerData: any, PackageModel: any)
	local Id = PackageModel:GetAttribute("Id")
	local FurnitureData = PlayerData.Furniture[Id]
	assert(FurnitureData, `No furniture data of Id: {Id}`)

	FurnitureData.Packed = false

	local FurnitureTemplate = Assets.Products:FindFirstChild(PackageModel.Name, true)
	local FurnitureModel = FurnitureTemplate:Clone()
	FurnitureModel:SetAttribute("Id", Id)
	FurnitureModel:PivotTo(PackageModel:GetPivot())
	FurnitureModel.Parent = PackageModel.Parent
	

	for _, Snap in FurnitureModel:GetDescendants() do
		if Snap:HasTag("Snap") then
			Visibility.HideChildren(Snap)
		end
	end
	
	PackageModel:Destroy()
end

function FurnitureComponent.PlaceAll(Player: Player, data: Data)
	for _, furnitureData in data.Furniture do
		FurnitureComponent.Place(Player, furnitureData)
	end
end

return FurnitureComponent
