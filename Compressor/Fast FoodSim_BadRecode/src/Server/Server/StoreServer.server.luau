--[[
	Store Server
	----------------
	Initializes the StoreModule.

	Created by: Guinogue — Modified on October 24, 2025
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = ReplicatedStorage.Resources
local Modules = Resources.Modules

local StoreModule = require(Modules.StoreModule)

StoreModule.Initialize()

print("Store system initialized.")
