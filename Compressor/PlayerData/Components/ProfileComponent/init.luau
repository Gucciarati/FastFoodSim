--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local World = require(ServerScriptService.World)

local ProfileComponent = InjectLifeCycleSignal {}
local GetEntityProfileHelper = require(script.GetEntityProfile)

ProfileComponent.ProfileStore = nil

local function GetEntityProfile(player: Player)
	return GetEntityProfileHelper(ProfileComponent, player)
end

function ProfileComponent:add(entity: number, player: Player)
	if not self.ProfileStore then return end
	return GetEntityProfile(player)
end
return World.factory(ProfileComponent)