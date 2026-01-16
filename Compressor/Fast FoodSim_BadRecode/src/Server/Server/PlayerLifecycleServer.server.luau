--[[
	Player Lifecycle Server
	----------------
	Initializes the PlayerLifecycleModule.

	Created by: Guinogue — Modified on October 27, 2025
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = ReplicatedStorage.Resources
local Modules = Resources.Modules

local PlayerLifecycleModule = require(Modules.PlayerLifecycleModule)

PlayerLifecycleModule.Initialize()

print("Player lifecycle initialized.")
