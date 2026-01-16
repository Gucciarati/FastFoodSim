--[[
	Customer Flow Module
	----------------
	Handles queue, ordering, service, and exit for NPC customers inside a
	player's restaurant. Spawns customer/order UI, validates trays, awards
	cash/XP, and performs cleanup.

	Created by: Guinogue — Modified on October 29, 2025
]]

-----< Services and dependencies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Chat = game:GetService("Chat")

local APIs = ReplicatedStorage.APIs
local GameplayAPI = require(APIs.gameplay)
local Settings = require(APIs.settings)
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)

local Remotes = ReplicatedStorage.Remotes.Gameplay
local Assets = ReplicatedStorage.Assets

local Helpers = require(ReplicatedStorage.Resources.Modules.HelpersModule)
local SeatingModule = require(ReplicatedStorage.Resources.Modules.SeatingModule)
local Nav = require(ReplicatedStorage.Resources.Modules.NavModule)

-----< Module table
local M = {}

-----< Order UI samples & formatting
local OrderSample = Handler.sample(Assets.NPCOrder.Container.Requirements.Sample)
local IngredientSample = Handler.sample(OrderSample.Ingredients.Sample)
local OrderScreenSample = Handler.sample(Assets.CustomerOrder.Order.Sample)
local IngredientScreenSample = Handler.sample(OrderScreenSample.Ingredients.Sample)

local function formatNumber(Number)
	return string.format("%s.%02d", Handler.abbreviate(Number), Number%1*100)
end

-----< Public API
function M.MakeNPCGoIntoRestaurant(NPCData, Restaurant, opts)
	local NPC = NPCData.NPC
	local Information = NPCData.Information
	local NPCType = NPCData.NPCType

	local Player = Players:FindFirstChild(Restaurant.Name)
	local Data = DataAPI.Data(Player)

	local FoundTable,FoundSeat,Tray = nil,nil,nil
	local Increment = 1

	local CashRegister = SeatingModule.pickCashRegister(Restaurant)
	if not CashRegister then return end

	CashRegister:SetAttribute("Occupied", true)
	FoundTable,FoundSeat,Tray = SeatingModule.findSeatAndTray(Restaurant, NPC)
	if FoundTable then FoundTable:SetAttribute("Occupied", true) end

	local Humanoid = NPC.Humanoid
	local HRP = NPC.HumanoidRootPart

	NPC.Parent = Restaurant.NPCs
	NPC:SetAttribute("IsWandering", false)

	if Data then
		Data.Customers += 1
		Data.DailyStats.Customers += 1
		DataAPI.UpdateData(Player)
	end

	local Placement = SeatingModule.createLinePlacement(CashRegister, NPC)

	local Spawns = Restaurant.Model.NPCSpawns:GetChildren()
	FoundSeat.NPC.Value = NPC

	while tonumber(Placement.Name) ~= 1 do
		Nav.ScriptsWalkTo(NPC,(CashRegister.Order.CFrame * CFrame.new(0,0,2.5*(tonumber(Placement.Name)-1))).Position)
		if tonumber(Placement.Name) == 1 then break end
		while task.wait(0.1) do if tonumber(Placement.Name) == 1 then break end end
		task.wait()
	end

	Nav.ScriptsWalkTo(NPC, CashRegister.Order.Position)
	NPC:SetAttribute("IsInRegister", true)
	Helpers.playAudio(Player, "NewAtRegister")
	Information.InLine.Value = true
	local OrderScreenFrame = Assets.CustomerOrder:Clone()
	local OrderFrame = Assets.NPCOrder:Clone()
	local EmptyTray = Assets.Food.Tray:Clone()
	EmptyTray.TrayHitbox.Value = Tray
	EmptyTray.NPCBeam.Attachment1.Parent = Tray
	local OrderItems = {}
	local Order = {}
	local Total,TotalXP = 0,0
	for Category,Items in pairs(GameplayAPI.Orders) do
		local Item = Handler.chance(Items)
		local ItemInfo = Items[Item]
		if Item == "Nothing" or GameplayAPI.XPToLevel(Data.XP) < ItemInfo.Lvl then continue end
		local FoodLeft = Handler.create("StringValue", EmptyTray.FoodsLeft, Item, "")
		for Index = 1,Handler.randomInt(ItemInfo.Amount) do
			local ItemFrame = OrderSample:Clone()
			local ItemScreenFrame = OrderScreenSample:Clone()
			local Price = ItemInfo.Price
			for _,IngredientInfo in pairs(ItemInfo.Ingredients) do
				if GameplayAPI.XPToLevel(Data.XP) < IngredientInfo.Lvl then continue end
				if Handler.random(0,100) > IngredientInfo.Chance then continue end
				local IngredientLeft = Handler.create("StringValue", FoodLeft, IngredientInfo.Item, IngredientInfo.Item)
				local IngredientFrame = IngredientSample:Clone()
				local IngredientScreenFrame = IngredientScreenSample:Clone()
				if GameplayAPI.Ingredients[IngredientInfo.Item] then
					IngredientFrame.Icon.Image = GameplayAPI.Ingredients[IngredientInfo.Item].Icon
					IngredientScreenFrame.Icon.Image = GameplayAPI.Ingredients[IngredientInfo.Item].Icon
				else
				end
				IngredientFrame.Parent = ItemFrame.Ingredients
				IngredientScreenFrame.Parent = ItemScreenFrame.Ingredients
				Price += IngredientInfo.Price
				table.insert(Order, IngredientInfo.Item)
			end
			table.insert(OrderItems, Item)
			ItemScreenFrame.Item.Text = Item.." - "
			ItemScreenFrame.Parent = OrderScreenFrame.Order
			local Rows = math.ceil((#ItemFrame.Ingredients:GetChildren()-3)/6)
			ItemFrame.Ingredients.UIAspectRatioConstraint.AspectRatio /= Rows
			ItemFrame.Ingredients.UIGridLayout.CellSize = UDim2.new(0.166,0,1/Rows,0)
			ItemFrame.Ingredients.UICorner.CornerRadius = UDim.new(0.5/Rows,0)
			ItemFrame.Item.Text = string.format("%s - <font color=\"rgb(0,172,0)\">$%s</font>", Item, formatNumber(Price))
			ItemFrame.Parent = OrderFrame.Container.Requirements
			Total += Price
		end
	end
	local Multiplier = GameplayAPI.NPCs[NPCType].CashMultiplier
	Total *= Multiplier
	TotalXP = Total * 0.5 * Increment
	OrderFrame.Container.TotalPriceContainer.TotalPrice.Text = "Total: $"..formatNumber(Total).." ("..Multiplier.."x)"
	OrderFrame.Parent = CashRegister.CustomerOrder
	OrderScreenFrame.Top.OrderGain.Text = "$"..formatNumber(Total).." ("..Multiplier.."x)"; OrderScreenFrame.Top.Time.Text = GameplayAPI.ClockTime(); OrderScreenFrame.Top.TableNumber.Text = "Customer No. "..Data.DailyStats.Customers + 1
	OrderScreenFrame.Parent = (opts and opts.orderScreenParent) or script
	EmptyTray:PivotTo(CashRegister:GetPivot() * CFrame.new(-2.3,3,0) * CFrame.Angles(0,math.rad(90),0))
	EmptyTray.Parent = Restaurant.Trash
	OrderFrame.Container.Title.Visible = false
	OrderFrame.Container.TotalPriceContainer.Visible = false
	OrderFrame.Container.BackgroundTransparency = 0.5
	OrderFrame.StudsOffsetWorldSpace = Vector3.new(0,(#OrderFrame.Container.Requirements:GetChildren()-1)*0.4,0)
	OrderFrame.Parent = EmptyTray.Drag
	for _,Appliance in pairs(Restaurant.Furniture.OrderScreens:GetChildren()) do
		for _,Descendant in pairs(Appliance:GetDescendants()) do
			if Descendant:IsA("SurfaceGui") and Descendant.Name == "CustomerOrders" then
				local Frame = OrderScreenFrame:Clone()
				Frame.Parent = Descendant.CustomerOrders.ScrollingFrame
				Handler.onDestroy(OrderScreenFrame, Frame)
			end
		end
	end
	if Cashier then
		Remotes.DragItem:FireClient(Cashier, EmptyTray, "Tray")
	end
	Information.Ordered.Value = true
	Information.OrderTime.Value = Lighting.ClockTime
	task.delay(0.5, function()
		Placement:Destroy()
		for _,Lineup in pairs(CashRegister.Lineup:GetChildren()) do
			Lineup.Name -= 1
		end
		CashRegister:SetAttribute("Occupied", #CashRegister.Lineup:GetChildren() > 0 or nil)
	end)

	Nav.ScriptsWalkTo(NPC, FoundSeat.Seat.CFrame.Position)
	if FoundSeat.Seat.Occupant then FoundSeat.Seat.Occupant.Jump = true end
	FoundSeat.Seat:Sit(Humanoid)
	if opts and opts.onSeated then opts.onSeated(NPCData) end
	local OrderReceived = false
	local Connection
	local Debounce = false
	Connection = game:GetService("RunService").Heartbeat:Connect(function()
		if Debounce then return end
		Debounce = true
		task.delay(0.1, function() Debounce = false end)
		if not table.find(workspace:GetPartBoundsInBox(Tray.CFrame, Tray.Size), EmptyTray.Padding) then return end
		local VerifyingOrder = table.clone(Order)
		for _,Ingredient in pairs(EmptyTray.Ingredients:GetChildren()) do
			local Found = table.find(VerifyingOrder, Ingredient.Name)
			if not Found then VerifyingOrder = nil return end
			if Found then table.remove(VerifyingOrder, Found) end
		end
		if VerifyingOrder[1] then VerifyingOrder = nil return end
		VerifyingOrder = nil
		OrderReceived = true
		for _,Ingredient in pairs(Order) do
			Data.ServedIngredientCount[Ingredient] = (Data.ServedIngredientCount[Ingredient] or 0) + 1
		end
		for _,Item in pairs(OrderItems) do
			Data.ServedItemCount[Item] = (Data.ServedItemCount[Item] or 0) + 1
		end
	end)

	while not OrderReceived and EmptyTray:IsDescendantOf(workspace) do task.wait() end

	Connection:Disconnect()
	OrderScreenFrame:Destroy()
	if OrderReceived then
		local NewTray = EmptyTray:Clone()
		EmptyTray:Destroy()
		NewTray:PivotTo(Tray.CFrame * CFrame.new(0,NewTray:GetExtentsSize().Y/2,0) * CFrame.Angles(0,math.rad(180),0))
		NewTray.Snap:RemoveTag("Snap")
		NewTray.Drag.Anchored = true
		NewTray.Parent = Tray.Parent
		local eatAnim = opts and opts.eatingAnimation
		if eatAnim then Humanoid:LoadAnimation(eatAnim):Play() end
		task.wait(10)
		local DirtyTray = Assets.Food["Dirty Tray"]:Clone()
		DirtyTray:PivotTo(Tray.CFrame * CFrame.new(0,DirtyTray:GetExtentsSize().Y/2,0) * CFrame.Angles(0,math.rad(180),0))
		DirtyTray.Parent = Restaurant.DirtyTrays
		NewTray:Destroy()
		if Data.GamePasses["AutoCollect"] then
			DirtyTray:Destroy()
		else
			DirtyTray.Collect.OnServerEvent:Connect(function() DirtyTray:Destroy() end)
		end
	else
		EmptyTray:Destroy()
	end
	if not NPC:IsDescendantOf(workspace) then return end
	FoundSeat.NPC.Value = nil
	local MessageOptions = GameplayAPI.Messages[OrderReceived and "Satisfied" or "Unsatisfied"]
	Chat:Chat(HRP, MessageOptions[Handler.randomInt(#MessageOptions)], Enum.ChatColor.White)
	if Data and OrderReceived then
		Data.CustomersServed += 1
		Data.DailyStats.CustomersServed += 1
		Data.Cash += Total * Settings.Multiplier(Player, "Cash")
		local XP = TotalXP * Settings.Multiplier(Player, "XP")
		Data.XP += XP
		Helpers.notifyPlayer(Player, "You gained "..math.round(XP).." XP!", "Green")
		Helpers.playAudio(Player, "XPGained")
		DataAPI.UpdateData(Player)
	end
	if Humanoid.Sit then
		if FoundSeat and FoundSeat.Seat.Occupant == Humanoid then FoundSeat.Seat:Sit(nil) end
		Humanoid.Sit = false
		Humanoid.Jump = true
	end
	task.wait(0.5)
	Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	local ChairOccupied = nil
	for _,Seat in pairs(FoundSeat.Parent:GetChildren()) do
		if not Seat.NPC.Value then continue end
		ChairOccupied = true
		break
	end
	FoundSeat.Parent.Parent:SetAttribute("Occupied", ChairOccupied)
	local TableOccupied = nil
	for _,Chair in pairs(FoundTable.Chairs:GetChildren()) do
		Chair = Chair.Chair.Value
		if not Chair then continue end
		if TableOccupied then break end
		for _,Seat in pairs(Chair.Seats:GetChildren()) do
			if not Seat.NPC.Value then continue end
			TableOccupied = true
			break
		end
	end
	FoundTable:SetAttribute("Occupied", TableOccupied)
	task.wait(1)
	game:GetService('Debris'):AddItem(NPC, 8)
	Nav.ScriptsWalkTo(NPC, Spawns[Handler.randomInt(#Spawns)].CFrame.Position)
end

return M



