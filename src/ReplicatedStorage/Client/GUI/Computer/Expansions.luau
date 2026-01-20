--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerData = LocalPlayer:WaitForChild("Data", 1)
if not PlayerData then
	warn("[ExpansionsClient] Failed to load PlayerData")
	return true
end
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local MainScreenGui = PlayerGui:WaitForChild("main")
local ExpansionsFrame = MainScreenGui.Modals.Computer.Frames.Expansions
local ExpansionsContainer = ExpansionsFrame:FindFirstChild("Container") or ExpansionsFrame
local ExpansionsScrollFrame = ExpansionsContainer:FindFirstChild("ScrollingFrame") or ExpansionsContainer

local ExpansionData = {
	{ Level = 1, Price = 0, LevelReq = 1, Name = "Starter Plot" },
	{ Level = 2, Price = 5000, LevelReq = 5, Name = "Small Extension" },
	{ Level = 3, Price = 15000, LevelReq = 10, Name = "Medium Restaurant" },
	{ Level = 4, Price = 40000, LevelReq = 15, Name = "Large Restaurant" },
	{ Level = 5, Price = 100000, LevelReq = 20, Name = "Mega Restaurant" },
	{ Level = 6, Price = 250000, LevelReq = 25, Name = "Premium Space" },
	{ Level = 7, Price = 500000, LevelReq = 30, Name = "Ultimate Plot" },
}

local function FormatNumber(num: number): string
	local formatted = tostring(num)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end
	return formatted
end

local function GetPlayerLevel(): number
	local xpValue = PlayerData:FindFirstChild("XP")
	if xpValue then
		-- Simple level calculation (matches bad recode pattern)
		local xp = xpValue.Value
		local level = 1
		local baseXP = 40
		local growthPerLevel = 8
		local currentXP = baseXP
		
		while xp >= currentXP and level < 50 do
			xp = xp - currentXP
			level = level + 1
			currentXP = currentXP + growthPerLevel
		end
		
		return level
	end
	return 1
end

local function GetCurrentExpansion(): number
	local expansionValue = PlayerData:FindFirstChild("Expansions")
	if expansionValue then
		return expansionValue.Value
	end
	return 1
end

local function UpdateExpansionUI()
	local currentExpansion = GetCurrentExpansion()
	local playerLevel = GetPlayerLevel()
	local cashValue = PlayerData:FindFirstChild("Cash")
	local cash = cashValue and cashValue.Value or 0
	
	for _, expansion in ipairs(ExpansionData) do
		local expansionFrame = ExpansionsScrollFrame:FindFirstChild(tostring(expansion.Level))
		if expansionFrame then
			local nameLabel = expansionFrame:FindFirstChild("Name")
			local priceLabel = expansionFrame:FindFirstChild("Price")
			local levelLabel = expansionFrame:FindFirstChild("LevelReq")
			local buyButton = expansionFrame:FindFirstChild("Buy")
			local ownedIndicator = expansionFrame:FindFirstChild("Owned")
			local lockedOverlay = expansionFrame:FindFirstChild("Locked")
			
			if nameLabel then nameLabel.Text = expansion.Name end
			if priceLabel then priceLabel.Text = `$${FormatNumber(expansion.Price)}` end
			if levelLabel then levelLabel.Text = `Lvl ${expansion.LevelReq}` end
			
			local isOwned = expansion.Level <= currentExpansion
			local isNext = expansion.Level == currentExpansion + 1
			local canAfford = cash >= expansion.Price
			local meetsLevel = playerLevel >= expansion.LevelReq
			
			if ownedIndicator then ownedIndicator.Visible = isOwned end
			if buyButton then buyButton.Visible = isNext and not isOwned end
			if lockedOverlay then lockedOverlay.Visible = not meetsLevel and not isOwned end
			
			if buyButton and isNext then
				buyButton.Activated:Connect(function()
					if canAfford and meetsLevel then
						local buyRemote = Remotes.Gameplay:FindFirstChild("BuyExpansion")
						if buyRemote then
							buyRemote:FireServer()
						end
					end
				end)
			end
			
			-- Robux purchase option
			local robuxButton = expansionFrame:FindFirstChild("BuyRobux")
			if robuxButton and isNext then
				local productId = expansion.ProductId
				if productId then
					robuxButton.Activated:Connect(function()
						MarketplaceService:PromptProductPurchase(LocalPlayer, productId)
					end)
				end
			end
		end
	end
end

local function UpdateMoneyDisplay()
	local moneyLabel = ExpansionsFrame:FindFirstChild("YourMoney")
	if not moneyLabel then
		local info = ExpansionsFrame:FindFirstChild("Info")
		if info then moneyLabel = info:FindFirstChild("YourMoney") end
	end
	
	local cashValue = PlayerData:FindFirstChild("Cash")
	if moneyLabel and cashValue then
		moneyLabel.Text = `$${FormatNumber(cashValue.Value)}`
	end
end

-- Initialize
UpdateExpansionUI()
UpdateMoneyDisplay()

-- Update when data changes
local expansionValue = PlayerData:FindFirstChild("Expansions")
if expansionValue then
	expansionValue:GetPropertyChangedSignal("Value"):Connect(UpdateExpansionUI)
end

local cashValue = PlayerData:FindFirstChild("Cash")
if cashValue then
	cashValue:GetPropertyChangedSignal("Value"):Connect(function()
		UpdateExpansionUI()
		UpdateMoneyDisplay()
	end)
end

local xpValue = PlayerData:FindFirstChild("XP")
if xpValue then
	xpValue:GetPropertyChangedSignal("Value"):Connect(UpdateExpansionUI)
end

return {}