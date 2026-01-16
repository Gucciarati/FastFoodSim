-----< Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Remotes = ReplicatedStorage.Remotes.Settings
local Handler = require(ReplicatedStorage.APIs.handler)
local DataAPI = require(ReplicatedStorage.APIs.data)

-----< Change setting

Remotes.Setting.OnServerEvent:Connect(function(Player, Setting, Value)
	local Data = DataAPI.Data(Player)
	if not Data or Data.Settings[Setting] == nil then return end
	if Setting == "RestaurantName" then
		if typeof(Value) ~= "string" then return end
		local Success,Filtered = Handler.filter(Value, Player.UserId)
		if Success then
			Value = Filtered
		else
			return
		end
	end
	
	Data.Settings[Setting] = Value
	
	DataAPI.UpdateData(Player)
end)

-----< 