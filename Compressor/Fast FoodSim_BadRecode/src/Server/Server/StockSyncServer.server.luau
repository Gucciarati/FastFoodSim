--[[
	Stock Sync Server
	----------------
	Initializes the StockSyncModule.

	Created by: Guinogue — Modified on October 27, 2025
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = ReplicatedStorage.Resources
local Modules = Resources.Modules

local StockSyncModule = require(Modules.StockSyncModule)

StockSyncModule.Initialize()

print("Stock sync initialized.")
