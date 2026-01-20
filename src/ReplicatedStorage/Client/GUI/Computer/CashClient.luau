--!strict
--[[
	CashClient
	----------
	Handles the Cash tab UI for Robux purchases, cash bundles, and special offers.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = ReplicatedStorage:WaitForChild('Config')
local CashBundlesConfig = require(Config.CashBundlesConfig)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerData = LocalPlayer:WaitForChild("Data", 60)
if not PlayerData then
	warn("[CashClient] Failed to load PlayerData")
	return {}
end

local MainScreenGui = PlayerGui:WaitForChild("main")
local CashFrame = MainScreenGui.Modals.Computer.Frames.Cash
local CashContainer = CashFrame:FindFirstChild("Container")

local function PopulateCashBundles()
	
	for BundleName, BundleData in CashBundlesConfig.registry do
		local BundleFrame = CashContainer:FindFirstChild(BundleName, true)
		local BuyButton = BundleFrame:FindFirstChildOfClass("TextButton")
		local PriceLabel = BuyButton.Amount

		local Success, PriceInRobux = pcall(function()
			return MarketplaceService:GetProductInfo(BundleData.ProductId, Enum.InfoType.Product).PriceInRobux
		end)

		PriceLabel.Text = if Success then ` {PriceInRobux}` else " N/A"

		BuyButton.Activated:Connect(function()
			MarketplaceService:PromptProductPurchase(LocalPlayer, BundleData.ProductId)
		end)
	end
end

PopulateCashBundles()
return {}