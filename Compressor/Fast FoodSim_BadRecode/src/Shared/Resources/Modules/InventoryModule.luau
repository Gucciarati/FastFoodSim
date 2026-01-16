local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local APIs = ReplicatedStorage.APIs
local Utilities = require(ReplicatedStorage.Utilities)
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)
local Settings = require(APIs.settings)
local GameplayAPI = require(APIs.gameplay)
local Helpers = require(ReplicatedStorage.Resources.Modules.HelpersModule)
local DeliveryModule = require(ReplicatedStorage.Resources.Modules.DeliveryModule)

local Remotes = ReplicatedStorage.Remotes.Gameplay
local Assets = ReplicatedStorage.Assets

local Tween = Utilities.Tween

local M = {}

local DELIVERY_TIME = 5

local function LastParentModel(Part)
	local CurrentModel, CurrentPart = nil, Part
	while true do
		CurrentPart = CurrentPart.Parent
		if CurrentPart == workspace then return CurrentModel end
		if CurrentPart:IsA("Model") then CurrentModel = CurrentPart end
	end
end

function M.bind(Folder, Restaurant, Player)
	Handler.childAdded(Folder.Packages, function(Package)
		if Package.Item.Value == nil then return end
		local PackageModel = Assets.Packages:FindFirstChild("Furniture Box")
		if Package.Category.Value == "Food" then
			PackageModel = Assets.Packages:FindFirstChild(Package.Item.Value)
		elseif GameplayAPI.Items[Package.Category.Value][Package.Item.Value].GamePass then
			PackageModel.Box.Material   = Enum.Material.Metal
			PackageModel.Box.BrickColor = BrickColor.new("Gold")
		end
		if not PackageModel then
			if Assets.Ingredients:FindFirstChild(Package.Item.Value) then
				local Data = DataAPI.Data(Player)
				if Data then
					Data.Packages[Package.Name] = nil
					Data.Foods[Package.Name] = {CF = Package.CF.Value, Amount = GameplayAPI.Items.Food[Package.Item.Value].Unit, Item = Package.Item.Value}
					DataAPI.UpdateData(Player)
				end
			end
			return
		end
		local TargetCF = CFrame.new(table.unpack(Package.CF.Value:split(",")))
		local S, P = Restaurant.PrimaryPart.Size, TargetCF.Position
		local Clamped = Vector3.new(
			math.clamp(P.X, -S.X/2, S.X/2),
			math.clamp(P.Y, 0, 50),
			math.clamp(P.Z, -S.Z/2, S.Z/2)
		)
		local CF = Restaurant:GetPivot() * (TargetCF - TargetCF.Position + Clamped)
		local NewPackage = PackageModel:Clone()
		NewPackage.Name = Package.Name
		local transparencyByDescendant, enabledByDescendant = Helpers.cacheHideModel(NewPackage)
		for _, d in ipairs(NewPackage:GetDescendants()) do if d:IsA("TextLabel") and Package.Category.Value ~= "Food" then d.Text = Package.Item.Value end end
		NewPackage.Parent = Restaurant.Packages
		NewPackage:PivotTo(CF)
		NewPackage.Drag:SetNetworkOwner(nil)
		Handler.onDestroy(Package, NewPackage)
		local playerFinished = Player:GetAttribute("FinishedLoading")
		if playerFinished then
			task.delay(DELIVERY_TIME, function() Helpers.restoreModel(transparencyByDescendant, enabledByDescendant) end)
			DeliveryModule.startDelivery(Restaurant, Player, CF, DELIVERY_TIME, Tween)
		else
			Helpers.restoreModel(transparencyByDescendant, enabledByDescendant)
		end
	end)

	Handler.childAdded(Folder.Foods, function(Food)
		local FoodModel = Assets.Ingredients:FindFirstChild(Food.Item.Value)
		if not FoodModel then return end
		local NewFood = FoodModel:Clone()
		NewFood.Name = Food.Name
		NewFood.Parent = Restaurant.Ingredients
		local CF = Restaurant:GetPivot() * CFrame.new(table.unpack(Food.CF.Value:split(",")))
		NewFood:PivotTo(CF)
		NewFood.Drag:SetNetworkOwner(nil)
		local transparencyByDescendant = select(1, Helpers.cacheHideModel(NewFood))
		local d = DeliveryModule.isActive(Restaurant) and DELIVERY_TIME or 0
		local playerFinished = Player:GetAttribute("FinishedLoading")
		if playerFinished then
			task.delay(d, function() Helpers.restoreModel(transparencyByDescendant) end)
		else
			Helpers.restoreModel(transparencyByDescendant)
		end
		Handler.changed(Food.Amount, function(Value)
			for _, child in ipairs(NewFood:GetChildren()) do
				local num = tonumber(child.Name)
				if num then
					if num > Value then Handler.invisible(child) else Handler.visible(child) end
				end
			end
		end)
		Handler.onDestroy(Food, NewFood)
	end)

	Handler.childAdded(Restaurant.Trash, function(Trash)
		if not Trash.Parent or not Trash:FindFirstChild("Drag") then return end
		Trash.Drag:SetNetworkOwner(nil)
	end)
end

function M.initRemotes(OwnedRestaurants)
	Remotes.OpenPackage.OnServerEvent:Connect(function(Player, Package)
		local Data = DataAPI.Data(Player)
		if not Data then return end
		local Restaurant = LastParentModel(Package)
		if not Restaurant then return end
		if Restaurant.Name ~= Player.Name then
			if not Restaurant.Whitelist:FindFirstChild(Player.Name) then
				Helpers.notifyPlayer(Player, "Not whitelisted!", "Red")
			end
		end
		if not Package or Package.Parent ~= Restaurant.Packages then return end
		local Item = Data.Packages[Package.Name].Item
		Data.Packages[Package.Name] = nil
		Data.Foods[Package.Name] = {
			CF = tostring(Restaurant:GetPivot():ToObjectSpace(Package.Drag.CFrame)),
			Amount = GameplayAPI.Items.Food[Item].Unit,
			Item = Item,
			FromPackage = true,
		}
		DataAPI.UpdateData(Player)
	end)

	Remotes.SellPackage.OnServerEvent:Connect(function(Player, Package)
		local Data = DataAPI.Data(Player)
		if not Data then return end
		local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
		if not Restaurant or not Package or Package.Parent ~= Restaurant.Packages then return end
		local ItemInfo = GameplayAPI.Items[Data.Packages[Package.Name].Category][Data.Packages[Package.Name].Item]
		Data.Cash += ItemInfo.Unit*ItemInfo.UnitPrice/2
		Data.Packages[Package.Name] = nil
		DataAPI.UpdateData(Player)
	end)

	Remotes.PlaceItem.OnServerEvent:Connect(function(Player, Item, CF)
		local Restaurant = Handler.findFirstAncestorOfChild(Item, OwnedRestaurants)
		if not Restaurant or not Restaurant.Whitelist:FindFirstChild(Player.Name) then return end
		if Item.Parent ~= Restaurant.Trash and Item.Parent ~= Restaurant.Packages and Item.Parent ~= Restaurant.Ingredients then return end
		Item.Drag.CFrame = CF
		Remotes.PlaceItem:FireAllClients(Player, Item)
	end)

	local BlackListed = {"Register", "CashRegister", "Trashbin", "Bin", "Gold"}

	Remotes.PlaceFurniture.OnServerEvent:Connect(function(Player, Placing, CF)
		local Data = DataAPI.Data(Player)
		if not Data then return end
		local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
		if not Restaurant then return end
		local FurnitureModel = Restaurant.Furniture:FindFirstChild(Placing.Name, true)
		if FurnitureModel and FurnitureModel:GetAttribute("Occupied") then return end
		local PlacementType = GameplayAPI.Items[Placing.Category.Value][Placing.Item.Value].Placement
		local PlacingModel = Assets.Furniture[Placing.Item.Value]:Clone()
		PlacingModel:PivotTo(CF)
		PlacingModel.Parent = workspace
		local Valid = GameplayAPI.CanPlaceFurniture(Data, Restaurant, PlacingModel, CF, PlacementType, FurnitureModel)
		PlacingModel:Destroy()
		if Valid then
			local GUID = Handler.generateGUID()
			Data.Furniture[Placing.Name] = {Category = Placing.Category.Value, Item = Placing.Item.Value, CF = tostring(Restaurant:GetPivot():ToObjectSpace(CF))}
			Data.Packages[Placing.Name] = nil
			DataAPI.UpdateData(Player)
		end
	end)

	Remotes.DeleteFurniture.OnServerEvent:Connect(function(Player, Placing)
		local HasTag = false
		for _, Item in ipairs(BlackListed) do if Placing:HasTag(Item) then HasTag = true break end end
		if HasTag or table.find(BlackListed, Placing.Name) then
			Helpers.notifyPlayer(Player, `Cannot sell {Placing.Name}!`, "Red")
			return
		end
		local Data = DataAPI.Data(Player)
		if not Data then return end
		local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
		if not Restaurant then return end
		local FurnitureModel = Restaurant.Furniture:FindFirstChild(Placing.Name, true)
		if not FurnitureModel or FurnitureModel:GetAttribute("Occupied") then return end
		Data.Furniture[Placing.Name] = nil
		DataAPI.UpdateData(Player)
	end)
end

return M


