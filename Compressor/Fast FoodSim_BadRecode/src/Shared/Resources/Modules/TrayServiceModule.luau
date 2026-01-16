local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Chat = game:GetService("Chat")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local APIs = ReplicatedStorage.APIs
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)
local Settings = require(APIs.settings)
local GameplayAPI = require(APIs.gameplay)
local Helpers = require(ReplicatedStorage.Resources.Modules.HelpersModule)

local Assets = ReplicatedStorage.Assets

local M = {}

function M.waitForOrder(EmptyTray, Tray, Order, OrderItems)
	local OrderReceived = false
	local Debounce = false
	local Connection
	Connection = RunService.Heartbeat:Connect(function()
		if Debounce then return end
		Debounce = true
		task.delay(0.1, function() Debounce = false end)
		if not table.find(Workspace:GetPartBoundsInBox(Tray.CFrame, Tray.Size), EmptyTray.Padding) then return end
		local VerifyingOrder = table.clone(Order)
		for _,Ingredient in pairs(EmptyTray.Ingredients:GetChildren()) do
			local Found = table.find(VerifyingOrder, Ingredient.Name)
			if not Found then VerifyingOrder = nil return end
			if Found then table.remove(VerifyingOrder, Found) end
		end
		if VerifyingOrder[1] then VerifyingOrder = nil return end
		VerifyingOrder = nil
		OrderReceived = true
	end)
	while not OrderReceived and EmptyTray:IsDescendantOf(Workspace) do task.wait() end
	Connection:Disconnect()
	return OrderReceived
end

function M.serveAndCleanup(Restaurant, EmptyTray, Tray, Data, Player, NPC, Humanoid, HRP, FoundSeat, FoundTable, Total, TotalXP, Order, OrderItems)
	if not NPC or not NPC:IsDescendantOf(Workspace) then return end
	if EmptyTray and EmptyTray:IsDescendantOf(Workspace) then
		local NewTray = EmptyTray:Clone()
		EmptyTray:Destroy()
		NewTray:PivotTo(Tray.CFrame * CFrame.new(0,NewTray:GetExtentsSize().Y/2,0) * CFrame.Angles(0,math.rad(180),0))
		NewTray.Snap:RemoveTag("Snap")
		NewTray.Drag.Anchored = true
		NewTray.Parent = Tray.Parent
		Humanoid:LoadAnimation(script.Parent.Parent.Parent.OldScript.EatingAnimation):Play()
		task.wait(10)
		local DirtyTray = Assets.Food["Dirty Tray"]:Clone()
		DirtyTray:PivotTo(Tray.CFrame * CFrame.new(0,DirtyTray:GetExtentsSize().Y/2,0) * CFrame.Angles(0,math.rad(180),0))
		DirtyTray.Parent = Restaurant.DirtyTrays
		NewTray:Destroy()
		if Data.GamePasses["AutoCollect"] then
			DirtyTray:Destroy()
		else
			DirtyTray.Collect.OnServerEvent:Connect(function()
				DirtyTray:Destroy()
			end)
		end
	end

	FoundSeat.NPC.Value = nil
	local MessageOptions = GameplayAPI.Messages["Satisfied"]
	Chat:Chat(HRP, MessageOptions[Handler.randomInt(#MessageOptions)], Enum.ChatColor.White)
	if Data then
		Data.CustomersServed += 1
		Data.DailyStats.CustomersServed += 1
		Data.Cash += Total * Settings.Multiplier(Player, "Cash")
		local XP = TotalXP * Settings.Multiplier(Player, "XP")
		Data.XP += XP
		Helpers.notifyPlayer(Player, "Você ganhou "..math.round(XP).." XP!", "Green")
		Helpers.playAudio(Player, "XPGained")
		for _,Ingredient in pairs(Order) do Data.ServedIngredientCount[Ingredient] = (Data.ServedIngredientCount[Ingredient] or 0) + 1 end
		for _,Item in pairs(OrderItems) do Data.ServedItemCount[Item] = (Data.ServedItemCount[Item] or 0) + 1 end
		DataAPI.UpdateData(Player)
	end

	if Humanoid.Sit then
		if FoundSeat and FoundSeat.Seat.Occupant == Humanoid then FoundSeat.Seat:Sit(nil) end
		Humanoid.Sit = false; Humanoid.Jump = true
	end
	task.wait(0.5)
	Humanoid:ChangeState(Enum.HumanoidStateType.Running)

	local ChairOccupied = nil
	for _,Seat in pairs(FoundSeat.Parent:GetChildren()) do if Seat.NPC.Value then ChairOccupied = true break end end
	FoundSeat.Parent.Parent:SetAttribute("Occupied", ChairOccupied)

	local TableOccupied = nil
	for _,Chair in pairs(FoundTable.Chairs:GetChildren()) do
		Chair = Chair.Chair.Value; if not Chair then continue end
		if TableOccupied then break end
		for _,Seat in pairs(Chair.Seats:GetChildren()) do if Seat.NPC.Value then TableOccupied = true break end end
	end
	FoundTable:SetAttribute("Occupied", TableOccupied)
	task.wait(1)
	Debris:AddItem(NPC, 8)
end

return M


