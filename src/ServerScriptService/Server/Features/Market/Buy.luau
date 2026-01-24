local ReplicatedStorage     = game:GetService("ReplicatedStorage")
local ServerScriptService   = game:GetService("ServerScriptService")

local DataService   = require(ServerScriptService.Server.DataService)
local ServerEvents  = require(ServerScriptService.Server.ServerEvents)

local Components            = ServerScriptService.Server.Components
local InventoryComponent    = require(Components.InventoryComponent)

local Net   = require(ReplicatedStorage.Packages.Net)
local BuyRE = Net:RemoteEvent("Buy")

local ProductConfigs = require(ReplicatedStorage.Config.ProductsConfig)


local function Buy(Player: Player, PurchaseList: {ProductName: string, Amount: number})
    local PlayerData = DataService.GetData(Player)
    local DeliveryList = {}

    for _, Purchase in PurchaseList do
        print(`Buying {Purchase.Amount} of {Purchase.ProductName}`)
        
        local ProductInformation = ProductConfigs.registry[Purchase.ProductName]
        local TotalPrice = ProductInformation.price * Purchase.Amount
        if PlayerData.Cash < TotalPrice then continue end
        PlayerData.Cash -= TotalPrice


        for Index = 1, Purchase.Amount do
           local ItemData = InventoryComponent.Add(PlayerData, { 
            Name = Purchase.ProductName,
            Amount = ProductInformation.unitSize or 1,
         })
           table.insert(DeliveryList, ItemData)
        end
        
    end

    if #DeliveryList < 1 then return end
    ServerEvents.DeliverProducts:Fire(Player, DeliveryList)
end


BuyRE.OnServerEvent:Connect(Buy)

return true