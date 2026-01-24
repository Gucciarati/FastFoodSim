--!strict
if true then return true end
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local BoostsConfig = require(ReplicatedStorage.Config.BoostsConfig)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerData = LocalPlayer:WaitForChild("Data", 60)

local MainScreenGui = PlayerGui:WaitForChild("main")
local BoostsFrame = MainScreenGui.Modals.Computer.Frames.Boosts
local BoostsContainer = BoostsFrame:FindFirstChild("Container")

local function PopulateBoostsList()

	for BoostName, BoostData in BoostsConfig.registry do
		local BoostFrame = BoostsContainer:FindFirstChild(BoostName, true)
		BoostFrame.Name = BoostName
		BoostFrame.Visible = true

		local DurationNumber
		local DurationPrefix

		for _, DurationData in BoostData.durations do
			local Duration = DurationData.Duration
			if Duration < 60 then
				DurationNumber = Duration
				DurationPrefix = "Sec"
			elseif Duration < 3600 then
				DurationNumber = math.floor(Duration / 60)
				DurationPrefix = "Mins"
			else
				DurationNumber = math.floor(Duration / 3600)
				DurationPrefix = "Hrs"
			end

			local FormattedDuration = `{DurationNumber} {DurationPrefix}`
			local DurationOptionButton = BoostFrame:FindFirstChild(FormattedDuration)

			local PriceLabel = DurationOptionButton.PriceLabel

			local Success, PriceInRobux = pcall(function()
				return MarketplaceService:GetProductInfo(DurationData.ProductId, Enum.InfoType.Product).PriceInRobux
			end)

			if Success then
				PriceLabel.Text = ` {PriceInRobux}`
			else
				PriceLabel.Text = " N/A"
			end

			DurationOptionButton.Activated:Connect(function()
				MarketplaceService:PromptProductPurchase(LocalPlayer, DurationData.ProductId)
			end)
		end
	end
end

PopulateBoostsList()


return {}
