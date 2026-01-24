--!strict

if true then return true end
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerData = LocalPlayer:WaitForChild("Data", 60)

local EmployeeConfigs = require(ReplicatedStorage.Config.EmployeeConfigs)

local Services = ReplicatedStorage.Services
local Calculate = require(Services.Calculate)

local Notify = require(ReplicatedStorage.Client.Utils.Notify)

local MainScreenGui = PlayerGui:WaitForChild("main")
local EmployeesFrame = MainScreenGui.Modals.Computer.Frames.Employees
local EmployeesContainer = EmployeesFrame:FindFirstChild("Container") or EmployeesFrame

local PurchaseFrame = EmployeesContainer:FindFirstChild("Purchase")
local SlotsFrame = EmployeesContainer:FindFirstChild("Slots")
local SlotTemplate = SlotsFrame and SlotsFrame:FindFirstChild("Sample")



local function SetupEmployeeTypes()
	for _, EmployeeTypeData in EmployeeConfigs.registry do
		local TypeFrame = PurchaseFrame:FindFirstChild(EmployeeTypeData.Name)

		local RobuxPriceLabel = TypeFrame:FindFirstChild("RobuxPriceLabel")
		local CashPriceLabel = TypeFrame:FindFirstChild("PriceLabel")

		local TotalOfCurrentType = 0
		local CashPrice = Calculate.EmployeePrice(EmployeeTypeData.Name, TotalOfCurrentType)

		local Success, PriceInRobux = pcall(function()
			return MarketplaceService:GetProductInfo(EmployeeTypeData.RobuxProductId, Enum.InfoType.Product).PriceInRobux
		end)

		RobuxPriceLabel.Text = ` {if Success then PriceInRobux else "N/A"}`
		CashPriceLabel.Text = `${CashPrice}`

		local CashHireButton = TypeFrame:FindFirstChild("CashHireButton")
		local RobuxHireButton = TypeFrame:FindFirstChild("RobuxHireButton")

		CashHireButton.Activated:Connect(function()
			if CurrentCash <= CashPrice then
				MarketplaceService:PromptProductPurchase(LocalPlayer, EmployeeTypeData.ProductId)
				Notify("Not enough cash to hire this employee.")
				return
			elseif OccupiedSlots >= TotalSlots then
				PromptNextSlotPurchase(OccupiedSlots + 1)
				Notify("No available employee slots. Please expand your restaurant.")
				return
			end
		end)

		RobuxHireButton.Activated:Connect(function()
			MarketplaceService:PromptProductPurchase(LocalPlayer, EmployeeTypeData.RobuxProductId)
		end)
	end
end

local function UpdateEmployeeSlots()
	for Index, SlotFrame in SlotsFrame:GetChildren() do
		local ActiveEmployee = ActiveEmployees[Index]
		SlotFrame.Icon.Image = if ActiveEmployee then ActiveEmployee.Icon else ""
	end

end


SetupEmployeeTypes()
UpdateEmployeeSlots()


return true
