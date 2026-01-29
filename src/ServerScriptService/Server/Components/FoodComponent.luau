--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plots = workspace.Plots

local Assets = ReplicatedStorage.Assets
local CFrameSerdes = require(ReplicatedStorage.Utils.CFrameSerdes)
local SetAnchored = require(ReplicatedStorage.Utils.SetAnchored)

local FoodComponent = {}

local function GetDeliveryAreaCFrame(PlotFolder: Folder): CFrame
	local Spawn = PlotFolder:FindFirstChild("Spawn")
	if Spawn then
		local offset = CFrame.new(math.random(-10, 10), math.random(5, 10), math.random(-10, 10))
		return CFrameSerdes.ToObjectSpace(PlotFolder, Spawn.CFrame * offset)
	end
	return CFrame.new(math.random(-10, 10), 5, math.random(-10, 10))
end

type AssemblyData = {
	Id: string,
	Name: string,
	Cframe: string?,
	Amount: number,
}

type Data = {
	Assemblies: { [string]: AssemblyData },
}

function FoodComponent.UpdatePackageAppearance(PackageModel: Model, Amount: number)
	if not PackageModel then return end
	Amount = Amount or 1
	if Amount <= 0 then
		PackageModel:Destroy()
		return
	end
	
	PackageModel:SetAttribute("Amount", Amount)
	
	for _, Child in PackageModel:GetChildren() do
		if Child:IsA("BasePart") then
			local ChildNum = tonumber(Child.Name)
			if ChildNum then
				Child.Transparency = if ChildNum > Amount then 1 else 0
			end
		end
	end
end

function FoodComponent.RemoveFromPackage(PackageModel: Model): boolean
	if not PackageModel then return false end
	
	local CurrentAmount = PackageModel:GetAttribute("Amount") :: number
	if CurrentAmount <= 0 then return false end
	
	local NewAmount = CurrentAmount - 1
	FoodComponent.UpdatePackageAppearance(PackageModel, NewAmount)
	
	return true
end

function FoodComponent.GenerateFood(FoodName: string): Model
	local FoodTemplate = Assets.Products:FindFirstChild(FoodName, true)["1"]
	if not FoodTemplate then return nil end
	
	local FoodModel = FoodTemplate:Clone()
	FoodModel:SetAttribute("Id", FoodModel.Name)
	FoodModel.Name = FoodName
	
	return FoodModel
end

function FoodComponent.PlaceAssembly(Player: Player, AssemblyData: AssemblyData): Model?
	local PlotFolder = Plots:QueryDescendants(`[$OwnerId = {Player.UserId}]`)[1]
	if not PlotFolder then return nil end
	
	local FoodTemplate = Assets.Products:FindFirstChild(AssemblyData.Name, true)
	if not FoodTemplate then return nil end
	
	local FoodModel = FoodTemplate:Clone()
	FoodModel.Name = AssemblyData.Name
	FoodModel:SetAttribute("Id", AssemblyData.Id)
	FoodModel:SetAttribute("Amount", AssemblyData.Amount)
	
	local ObjectSpaceCFrame: CFrame
	if AssemblyData.Cframe then
		ObjectSpaceCFrame = CFrameSerdes.Deserialize(AssemblyData.Cframe)
	else
		ObjectSpaceCFrame = GetDeliveryAreaCFrame(PlotFolder)
		AssemblyData.Cframe = CFrameSerdes.Serialize(ObjectSpaceCFrame)
	end
	
	local WorldCFrame = CFrameSerdes.ToWorldSpace(PlotFolder, ObjectSpaceCFrame)
	
	SetAnchored(FoodModel, true)
	
	local Size = FoodModel:GetExtentsSize()
	WorldCFrame *= CFrame.new(0, Size.Y / 2, 0)
	
	FoodModel:PivotTo(WorldCFrame)
	FoodModel.Parent = PlotFolder.Food
	
	FoodComponent.UpdatePackageAppearance(FoodModel, AssemblyData.Amount)
	
	return FoodModel
end

function FoodComponent.PlaceAllAssemblies(Player: Player, data: Data)
	for _, assemblyData in data.Assemblies do
		FoodComponent.PlaceAssembly(Player, assemblyData)
	end
end

return FoodComponent
