--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local Players             = game:GetService('Players')

local Shared                  = ReplicatedStorage:WaitForChild('SharedModules')
local Utils                   = ReplicatedStorage:WaitForChild('Utils')
local Vendor                  = ReplicatedFirst.Vendor

local Config = ReplicatedStorage.Config

local GuiShared           = require(Shared.GuiShared)
local ProductsConfig      = require(Config.ProductsConfig)

local LocalPlayer         = Players.LocalPlayer
local PlayerGui           = LocalPlayer.PlayerGui

local Tagged           = require(Vendor.Tagged)
local Connect          = require(Vendor.ConnectUtil)
local RequireAttribute = require(Utils.RequireAttribute)

local OpenModalState          = ReplicatedStorage.GameState.OpenModal
local CurrentComputerTabState = ReplicatedStorage.GameState.CurrentComputerTab

local MainScreenGui = PlayerGui:WaitForChild('main')
local SideButtons   = MainScreenGui.Left
local ModalsFolder  = MainScreenGui.Modals
local ComputerFrame = ModalsFolder.Computer

local MarketFrame           = ComputerFrame.Frames.Market
local ProductsContainer     = MarketFrame.Products.Products
local ShoppingCart          = MarketFrame.Products.ShoppingCart
local InfoTabs              = MarketFrame.Info.Tabs

-- Get product template (use existing "Burger Buns" or "Gold Cooktop" as template)
local ProductTemplate = ProductsContainer:FindFirstChild("Burger Buns") or ProductsContainer:FindFirstChild("Gold Cooktop")


local function SetupCategorySelectors()
    -- Category tabs are in MarketFrame.Info.Tabs
    if not InfoTabs then return end
    
    local categoryButtons = {
        Food = InfoTabs:FindFirstChild("Food"),
        Appliances = InfoTabs:FindFirstChild("Appliances"),
        Furniture = InfoTabs:FindFirstChild("Furniture"),
        Decoration = InfoTabs:FindFirstChild("Decoration")
    }
    
    for categoryName, button in pairs(categoryButtons) do
        if button then
            button.Activated:Connect(function()
                -- Filter products by category
                for _, productFrame in pairs(ProductsContainer:GetChildren()) do
                    if productFrame:IsA("Frame") and productFrame:FindFirstChild("Container") then
                        local categoryAttr = productFrame:GetAttribute("Category")
                        if categoryAttr then
                            productFrame.Visible = categoryAttr == categoryName
                        end
                    end
                end
            end)
        end
    end
end


local function PopulateProductList()
    if not ProductTemplate then return end
    
    -- Clear existing products except template
    for _, child in pairs(ProductsContainer:GetChildren()) do
        if child ~= ProductTemplate and child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for _, ProductData in ProductsConfig.registry do
        local productFrame = ProductTemplate:Clone()
        productFrame.Name = ProductData.Name
        productFrame.Visible = true
        productFrame:SetAttribute("Category", ProductData.category)
        
        local container = productFrame:FindFirstChild("Container") or productFrame
        local nameLabel = container:FindFirstChild("ItemName")
        local priceLabel = container:FindFirstChild("UnitPrice")
        local iconImage = container:FindFirstChild("Icon")
        local lockedOverlay = container:FindFirstChild("LockedOverlay")
        local buyButton = container:FindFirstChild("Buy")
        local productButton = container:FindFirstChild("Product")
        local amountFrame = container:FindFirstChild("BuyAmount")
        
        if nameLabel then nameLabel.Text = `{ProductData.unitSize}x {ProductData.Name}` end
        if priceLabel then priceLabel.Text = `$${ProductData.unitPrice or 0}` end
        if iconImage then iconImage.Image = ProductData.icon end
        
        productFrame.LayoutOrder = ProductData.lvlRequirement or 0
        
        -- Handle amount selection
        if amountFrame then
            local increaseBtn = amountFrame:FindFirstChild("Increase")
            local decreaseBtn = amountFrame:FindFirstChild("Reduce")
            local amountLabel = amountFrame:FindFirstChild("Amount")
            
            if amountLabel then amountLabel.Text = "1" end
            
            if increaseBtn and amountLabel then
                increaseBtn.Activated:Connect(function()
                    local current = tonumber(amountLabel.Text) or 1
                    amountLabel.Text = tostring(math.clamp(current + 1, 1, 100))
                end)
            end
            
            if decreaseBtn and amountLabel then
                decreaseBtn.Activated:Connect(function()
                    local current = tonumber(amountLabel.Text) or 1
                    amountLabel.Text = tostring(math.clamp(current - 1, 1, 100))
                end)
            end
        end
        
        -- Handle cash purchase
        if buyButton then
            buyButton.Activated:Connect(function()
                local amount = 1
                if amountFrame then
                    local amountLabel = amountFrame:FindFirstChild("Amount")
                    if amountLabel then
                        amount = tonumber(amountLabel.Text) or 1
                    end
                end
                -- Fire to server
                local buyRemote = ReplicatedStorage.Remotes.Gameplay:FindFirstChild("BuyProduct")
                if buyRemote then
                    buyRemote:FireServer(ProductData.Name, amount)
                else
                    warn(`Purchase request: {ProductData.Name} x{amount}`)
                end
            end)
        end
        
        -- Handle Robux purchase (if product has devProductId)
        if productButton and ProductData.productId then
            productButton.Activated:Connect(function()
                game:GetService("MarketplaceService"):PromptProductPurchase(LocalPlayer, ProductData.productId)
            end)
        end
        
        productFrame.Parent = ProductsContainer
    end
    
    if ProductTemplate then ProductTemplate.Visible = false end
    
    -- Show Food category by default
    for _, productFrame in pairs(ProductsContainer:GetChildren()) do
        if productFrame:IsA("Frame") and productFrame:FindFirstChild("Container") then
            local categoryAttr = productFrame:GetAttribute("Category")
            productFrame.Visible = categoryAttr == "Food"
        end
    end
end


-- Initialize
PopulateProductList()
SetupCategorySelectors()

return {}