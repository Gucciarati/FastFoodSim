--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local Players             = game:GetService('Players')

local Shared                  = ReplicatedStorage:WaitForChild('SharedModules')
local Utils                   = ReplicatedStorage:WaitForChild('Utils')
local Vendor                  = ReplicatedFirst.Vendor

local Config = ReplicatedStorage.Config

local Decoration = require(ReplicatedStorage.Config.Products.Decoration)
local GuiShared           = require(Shared.GuiShared)
local ProductsConfig      = require(Config.ProductsConfig)

local LocalPlayer         = Players.LocalPlayer
local PlayerGui           = LocalPlayer.PlayerGui


local Net = require(ReplicatedStorage.Packages.Net)
local BuyRE = Net:RemoteEvent("Buy")

local IncrementFusionValue  = require(Utils.IncrementFusionValue)

local StateValue = require(ReplicatedStorage.Packages.StateValue)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local StateValue = require(ReplicatedStorage.Packages.StateValue)
local Scope = Fusion.scoped(Fusion)
local Peek = Fusion.peek

local OpenModalState          = ReplicatedStorage.GameState.OpenModal

local MainScreenGui = PlayerGui:WaitForChild('main')
local ModalsFolder  = MainScreenGui.Modals
local ComputerFrame = ModalsFolder.Computer

local MarketFrame           = ComputerFrame.Frames.Market
local ProductsContainer     = MarketFrame.Products.Products
local ShoppingCart          = MarketFrame.Products.ShoppingCart

local ProductTemplate       = ProductsContainer:FindFirstChild("Burger Buns")
local GoldProductTemplate   = ProductsContainer:FindFirstChild("GoldTemplate")
local CartItemTemplate     = ShoppingCart:FindFirstChild("Template", true)

local BuyCartButton = ShoppingCart.Buy
local ClearCartButton = ShoppingCart.Delete

local AmountsToPurchasePerProduct : {[string]: Fusion.Value<number>} = {}
local CartList: any = {}

local function ClearCartDisplay()
    for _, Child in ShoppingCart.ScrollingFrame:GetChildren() do
        if Child:IsA("Frame") and Child ~= CartItemTemplate then
            Child:Destroy()
        end
    end
end

local function ClearCart()
    CartList = {}
    ClearCartDisplay()
    UpdateTotalCartPrice()
end

local function BuyCart()
    local PurchaseList = {}
    
    for ProductName, CartItem in CartList do
        table.insert(PurchaseList, {
            ProductName = ProductName,
            Amount = Peek(CartItem.Amount),
        })
    end
    
    if #PurchaseList < 1 then return end
    
    BuyRE:FireServer(PurchaseList)
    ClearCart()
end

local function UpdateCartDisplay()
    ClearCartDisplay()
    
    print("Updating cart display", CartList)
    for _, CartItem in CartList do
        local CartItemFrame = CartItemTemplate:Clone()
        CartItemFrame.Name = CartItem.ProductName

        local NameLabel = CartItemFrame:FindFirstChild("ItemName", true)
        local TotalPriceLabel = CartItemFrame:FindFirstChild("ItemCost", true)
        local AmountLabel = CartItemFrame:FindFirstChild("Amount", true)

        local AmountComputed = Scope:Computed(function(Use)
            return Use(CartItem.Amount)
        end)

        local TotalPriceComputed = Scope:Computed(function(Use)
            local ProductData = ProductsConfig.registry[CartItem.ProductName]
            local Amount = Use(CartItem.Amount)
            return `${ProductData.price * Amount}`
        end)

        Scope:Hydrate(AmountLabel) {
            Text = AmountComputed
        }

        Scope:Hydrate(TotalPriceLabel) {
            Text = TotalPriceComputed
        }

        print(CartItemFrame)
        CartItemFrame.Visible = true
        CartItemFrame.Parent = ShoppingCart.ScrollingFrame
        NameLabel.Text = CartItem.ProductName
    end
end

function UpdateTotalCartPrice()
    local TotalPrice = 0
    for _, CartItem in CartList do
        local ProductData = ProductsConfig.registry[CartItem.ProductName]
        local Amount = Peek(CartItem.Amount)
        TotalPrice += ProductData.price * Amount
    end

    local TotalCartPriceLabel = ShoppingCart:FindFirstChild("TotalPrice", true)
    Scope:Hydrate(TotalCartPriceLabel) {
        Text = `Total: ${TotalPrice}`
    }
end

local function AddProductToCart(ProductName: string, Amount: number)
    if CartList[ProductName] then
        local CartItemData = CartList[ProductName]
        local NewAmount = Scope.peek(CartItemData.Amount) + Amount
        CartItemData.Amount:set(NewAmount)
    else
        CartList[ProductName] = {
            ProductName = ProductName,
            Amount = Scope:Value(Amount),
        }
    end

    UpdateTotalCartPrice()
    UpdateCartDisplay()
end


local function PopulateProductList()
    if not ProductTemplate then return end
    
    for _, child in pairs(ProductsContainer:GetChildren()) do
        if child ~= ProductTemplate and child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for _, ProductData in ProductsConfig.registry do
        local ProductName = ProductData.name

        local ProductFrame = ProductTemplate:Clone()
        ProductFrame:SetAttribute("Category", ProductData.category)
        
        local NameLabel         = ProductFrame:FindFirstChild("ItemName", true)
        local UnitPriceLabel    = ProductFrame:FindFirstChild("UnitPrice", true)
        local IconImage         = ProductFrame:FindFirstChild("Icon", true)
        local AmountTextBox   = ProductFrame:FindFirstChild("Amount", true)

        local LockedOverlay     = ProductFrame:FindFirstChild("LockedOverlay", true)
        local AddToListButton   = ProductFrame:FindFirstChild("Buy", true)
        local TotalPriceLabel   = AddToListButton:FindFirstChild("Amount", true)

        NameLabel.Text = `{ProductData.unitSize}x {ProductData.name}`
        UnitPriceLabel.Text = `${ProductData.unitPrice or 0}`
        IconImage.Image = ProductData.icon
        
        local AmountToPurchase = Scope:Value(1)
        AmountsToPurchasePerProduct[ProductData.name] = AmountToPurchase

        local TotalPrice = Scope:Computed(function(Use)
            local AmountToPurchaseValue = Use(AmountToPurchase)
            return `${(ProductData.price) * AmountToPurchaseValue}`
        end)

        local ShowLockedOverlay = Scope:Computed(function(Use)
            local CurrentLevel = Use(StateValue.Peek("Level"))
            return CurrentLevel < ProductData.lvlRequirement
        end)

        local ShowProductFrame = Scope:Computed(function(Use)
                local CurrentTab = Use(StateValue.Peek("CurrentComputerTab"))
                return CurrentTab == "Market"
        end)
        
        Scope:Hydrate(TotalPriceLabel) {
            Text = TotalPrice
        }

        Scope:Hydrate(LockedOverlay) {
            Visible = ShowLockedOverlay
        }

        Scope:Hydrate(AmountTextBox) {
            Text = AmountToPurchase
        }

        local IncreaseButton = ProductFrame:FindFirstChild("Increase", true)
        local DecreaseButton = ProductFrame:FindFirstChild("Reduce", true)

        IncreaseButton.Activated:Connect(function()
            IncrementFusionValue(AmountToPurchase, 1, 0)
        end)

        DecreaseButton.Activated:Connect(function()
            IncrementFusionValue(AmountToPurchase, -1, 0)
        end)

        AddToListButton.Activated:Connect(function()
            AddProductToCart(ProductName, Peek(AmountToPurchase))
            AmountToPurchase:set(1)
        end)
        
        

        Scope:Hydrate(ProductFrame) {
            Name = ProductName,
            Visible = ShowProductFrame,
            LayoutOrder = ProductData.lvlRequirement,
            Parent = ProductsContainer,
        }
    end
end



PopulateProductList()

BuyCartButton.Activated:Connect(BuyCart)
ClearCartButton.Activated:Connect(ClearCart)

return true