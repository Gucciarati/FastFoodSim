--[[
	Tutorial Module
	----------------
	Manages tutorial data and server events (set value and skip).

	Created by: Guinogue — Modified on October 27, 2025
]]

local TutorialModule = {}

-----< Module Setup >

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Tutorial
local DataAPI = require(ReplicatedStorage.APIs.data)

-----< Data >

local function setupTemplate()
	DataAPI.ProfileTemplate.Tutorial = true
end

-----< Events >

local function setTutorial(Player, Value)
	local Data = DataAPI.Data(Player); if not Data then return end
	Data.Tutorial = Value; Data.Settings.Tutorial = Value; DataAPI.UpdateData(Player)
end

local function skipTutorial(Player)
	local Data = DataAPI.Data(Player); if not Data then return end
	Data.Settings.Tutorial = 29; Data.Tutorial = 29; DataAPI.UpdateData(Player)
end

local function connectRemotes()
	Remotes.Tutorial.OnServerEvent:Connect(setTutorial)
	Remotes.Skip.OnServerEvent:Connect(function(Player) skipTutorial(Player) end)
end

-----< Initialize >

function TutorialModule.Initialize()
	setupTemplate(); connectRemotes(); return true
end

return TutorialModule


