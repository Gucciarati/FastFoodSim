--!strict
local ReplicatedStorage     = game:GetService("ReplicatedStorage")
local ServerScriptService   = game:GetService("ServerScriptService")

local Components            = ServerScriptService.Server.Components
local FurnitureComponent    = require(Components.FurnitureComponent)
local FoodComponent         = require(Components.FoodComponent)

local DataService  = require(ServerScriptService.Server.DataService)
local ServerEvents = require(ServerScriptService.Server.ServerEvents)

local Net           = require(ReplicatedStorage.Packages.Net)
local OpenPackageRE = Net:RemoteEvent("OpenPackage")

local Assets = ReplicatedStorage.Assets
local Plots  = workspace.Plots


local function OpenPackage(Player: Player, PackageModel: any)
    local PlotFolder = Plots:QueryDescendants(`[$OwnerId = {Player.UserId}]`)[1]
    assert(PlotFolder, `No plot folder found for {Player.UserId}`)

    local IsFood = PackageModel:GetAttribute("Amount") ~= nil
    local Id = PackageModel:GetAttribute("Id")

    if IsFood then
        local Removed = FoodComponent.RemoveFromPackage(PackageModel)
        if not Removed then return end

        local FoodModel = FoodComponent.GenerateFood(PackageModel.Name)
        if not FoodModel then return end
        
        FoodModel:PivotTo(PackageModel:GetPivot())
        FoodModel.Parent = PlotFolder.Food
        ServerEvents.Grab:Fire(Player, FoodModel)

    else
        local PlayerData = DataService.GetData(Player)
        FurnitureComponent.Unpack(PlayerData, PackageModel)
    end
end

OpenPackageRE.OnServerEvent:Connect(OpenPackage)
print("dd")
return true