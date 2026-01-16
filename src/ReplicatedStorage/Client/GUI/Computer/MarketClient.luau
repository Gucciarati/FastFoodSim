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
local ProductsFrame         = MarketFrame.Products
local ProductsScrollFrame   = ProductsFrame.Products

local NormalProductTemplate = ProductsScrollFrame.NormalProductTemplate
local GoldenProductTemplate = ProductsScrollFrame.GoldenProductTemplate


local function SetupCategorySelectors()
    local CategorySelectorsFrame = MarketFrame.CategorySelectors
    local CategoryButtons = CategorySelectorsFrame:GetChildren()
    
    for _, Button in CategoryButtons do
        Button.Activated:Connect(function()
            --Category filtering logic
        end)
    end
end


local function PopulateProductList()
    
    for _, ProductData in ProductsConfig.registry do
        local IsGolden = ProductData.Golden
        
        local ProductTemplate = if IsGolden then GoldenProductTemplate else NormalProductTemplate
        
        local ProductFrame = ProductTemplate:Clone()
        local NameLabel = ProductFrame.Name
        local PriceLabel = ProductFrame.Price
        local IconImage = ProductFrame.Icon

        local LockedOverlay = ProductFrame.LockedOverlay

        local PurchaseButton = ProductFrame.PurchaseButton
        local AmountIncreaseButton = ProductFrame.AmountSelector.Increase
        local AmountDecreaseButton = ProductFrame.AmountSelector.Decrease

        ProductFrame.LayoutOrder = ProductData.lvlRequirement
        NameLabel.Text = `{ProductData.unitSize}x {ProductData.Name}`
        PriceLabel.Text = `${ProductData.unitPrice}`
        IconImage.Image = ProductData.Icon

        --TODO: Make LockedOverlay visibility reactive to player level vs lvlRequirement
        --TODO: Make button visibility reactive to current category filter
        --TODO: Make dynamic amount selection work

        AmountDecreaseButton.Activated:Connect(function()
            --Decrease amount logic
        end)
        AmountIncreaseButton.Activated:Connect(function()
            --Increase amount logic
        end)

        PurchaseButton.Activated:Connect(function()
            --Request purchase from server
        end)
    end


end


return true