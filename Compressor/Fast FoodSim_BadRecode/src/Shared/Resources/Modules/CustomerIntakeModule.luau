local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Handler = require(ReplicatedStorage.APIs.handler)
local OrderModule = require(ReplicatedStorage.Resources.Modules.OrderModule)
local Helpers = require(ReplicatedStorage.Resources.Modules.HelpersModule)
local GameplayAPI = require(ReplicatedStorage.APIs.gameplay)

local Assets = ReplicatedStorage.Assets
local Remotes = ReplicatedStorage.Remotes.Gameplay

local M = {}

function M.start(CashRegister, Tray, Player, Data, NPCType, Increment)
	local orderFrame, orderScreen, instances, Total, TotalXP = OrderModule.build(Data, NPCType, Increment)
	local EmptyTray = Assets.Food.Tray:Clone()
	EmptyTray.TrayHitbox.Value = Tray
	EmptyTray.NPCBeam.Attachment1.Parent = Tray

	local OrderTaken, Cashier = false, nil
	local bindableConn = CashRegister.EmployeeTakeOrder.Event:Once(function() OrderTaken = true end)
	local remoteConn = CashRegister.TakeOrder.OnServerEvent:Once(function(taker)
		OrderTaken = true; Cashier = taker; Helpers.playAudio(Player, "OrderTaken")
	end)

	while not OrderTaken do task.wait(.1) end
	bindableConn:Disconnect(); remoteConn:Disconnect()

	return orderFrame, orderScreen, EmptyTray, instances, Total, TotalXP, Cashier
end

return M


