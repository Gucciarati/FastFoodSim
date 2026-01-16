--!strict

local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local ServerScriptService = script.Parent
local Global              = require(ReplicatedStorage:WaitForChild('Global'))
local GameState     = ReplicatedStorage:WaitForChild('GameState')

local ServerModules = ServerScriptService.Server
local Utils         = ReplicatedStorage:WaitForChild('Utils')
local Vendor        = ReplicatedFirst.Vendor


local ConnectUtil   = require(Vendor.ConnectUtil)
local RegisterModules = require(Utils.RegisterModule)

local modules = {
	-- load this first
	ServerModules.PlayerServer,
	ServerModules.RestaurantServer,
	
} :: {ModuleScript}

RegisterModules.requireModules(modules)
GameState:SetAttribute(Global.Attributes.GameState.ServerInitialized, true)
