--!strict
local ReplicatedStorage 	= game:GetService("ReplicatedStorage")
local ServerScriptService 	= game:GetService("ServerScriptService")
local RunService 			= game:GetService("RunService")

local ServerEvents = require(ServerScriptService.Server.ServerEvents)

local Helpers 					= script.Parent.Helpers
local FindClosestLane 			= require(Helpers.FindClosestLane)
local CalculateDeliveryPoint 	= require(Helpers.CalculateDeliveryPoint)
local CalculateDeliveryCFrames	= require(Helpers.CalculateDeliveryCFrames)
local GeneratePackages			= require(Helpers.GeneratePackages)

local MakePackagesInvisible 	= require(Helpers.MakePackagesInvisible)
local RevealPackages 			= require(Helpers.RevealPackages)
local DepartTruck 				= require(Helpers.DepartTruck)

local Plots = workspace.Plots

local ActiveTrucksByRestaurant: { [any]: Model } = {}

local DELIVERY_TIME = 5

type DeliveryOptions = {
	Restaurant: Model,
	Player: Player,
	DeliveryCFrame: CFrame,
	Packages: { any },
	DeliveryTime: number,
}




local function RequestDelivery(Player: Player, DeliveryList: any)
	local UserId = Player.UserId
	local PlotFolder = Plots:QueryDescendants(`[$OwnerId = {UserId}]`)[1]
	assert(PlotFolder, `No plot folder found for {UserId}`)

	local Packages = GeneratePackages(DeliveryList)

	local IsActive = ActiveTrucksByRestaurant[UserId]
	if IsActive then return end
	
	local Lane = FindClosestLane(PlotFolder.Base.Position)
	local TruckTemplate = ReplicatedStorage:FindFirstChild("DeliveryTruck", true)
	
	local Truck = TruckTemplate:Clone()
	Truck:SetAttribute("ForPlayer", Player.Name)
	Truck:SetAttribute("Status", "InTransit")
	Truck.Parent = workspace
	
	local SpawnCFrame = Lane.P1.CFrame * CFrame.new(0, -1, 0)
	Truck:PivotTo(SpawnCFrame)
	
	ActiveTrucksByRestaurant[UserId] = Truck
	
	local TransparencyMap = MakePackagesInvisible(Packages)
	local DeliveryCFrames = CalculateDeliveryCFrames(PlotFolder, DeliveryList)
	
	local ProductsConfig = require(ReplicatedStorage.Config.ProductsConfig)
	local FoodFolder = PlotFolder:FindFirstChild("Food")
	local FurnitureFolder = PlotFolder:FindFirstChild("Furniture")
	
	for Index, Package in Packages do
		local DeliveryCFrame = DeliveryCFrames[Index]
		Package:PivotTo(DeliveryCFrame)
		
		local ItemName = Package.Name
		local IsFood = ProductsConfig.registry[ItemName] and ProductsConfig.registry[ItemName].category == "Food"
		Package.Parent = if IsFood then FoodFolder else FurnitureFolder
	end
	
	local DeliveryPoint = CalculateDeliveryPoint(DeliveryCFrames[1], Lane, Lane.P1)
	local TargetCFrame = CFrame.new(DeliveryPoint, SpawnCFrame.Position + SpawnCFrame.LookVector * 10000)
	
	local StartTime = tick()
	local TweenConnection
	TweenConnection = RunService.Heartbeat:Connect(function()
		local Elapsed = tick() - StartTime
		local Progress = math.min(Elapsed / DELIVERY_TIME, 1)
		
		if Truck and Truck.Parent then
			Truck:PivotTo(SpawnCFrame:Lerp(TargetCFrame, Progress))
		end
		
		if Progress >= 1 then
			TweenConnection:Disconnect()
			
			task.delay(0.5, function()
				RevealPackages(TransparencyMap)
			end)
			
			task.delay(2, function()
				DepartTruck(Truck, Lane, DELIVERY_TIME * 0.8)
				ActiveTrucksByRestaurant[UserId] = nil
			end)
		end
	end)
	
	return true
end


ServerEvents.DeliverProducts:Connect(RequestDelivery)

return true