-----< Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Tutorial
local DataAPI = require(ReplicatedStorage.APIs.data)

-----< Data

DataAPI.ProfileTemplate.Tutorial = true

-----< Change value

Remotes.Tutorial.OnServerEvent:Connect(function(Player, Value)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	Data.Tutorial = Value
	Data.Settings.Tutorial = Value
	DataAPI.UpdateData(Player)
end)

Remotes.Skip.OnServerEvent:Connect(function(Player)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	Data.Settings.Tutorial = 29
	Data.Tutorial = 29
	DataAPI.UpdateData(Player)
end)

-----< 