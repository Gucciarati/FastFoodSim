--[[
	PotionsServer
	
	Server script responsible for initializing the potion system.
	This script should be placed inside ServerScriptService.
	
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Resources = ReplicatedStorage.Resources
local Modules = Resources.Modules
local PotionsModule = require(Modules.PotionsModule)

-- Initialize the potion system
PotionsModule.Initialize()

print("Potion System initialized successfully!")
