--[[
	Vehicles Server
	----------------
	Initializes the VehiclesModule.

	Created by: Guinogue — Modified on October 27, 2025
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = ReplicatedStorage.Resources
local Modules = Resources.Modules

local VehiclesModule = require(Modules.VehiclesModule)

VehiclesModule.Initialize()

print("Vehicles system initialized.")
