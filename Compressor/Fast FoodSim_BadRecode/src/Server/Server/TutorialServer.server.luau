--[[
	Tutorial Server
	----------------
	Initializes the TutorialModule.

	Created by: Guinogue — Modified on October 27, 2025
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = ReplicatedStorage.Resources
local Modules = Resources.Modules

local TutorialModule = require(Modules.TutorialModule)

TutorialModule.Initialize()

print("Tutorial system initialized.")


