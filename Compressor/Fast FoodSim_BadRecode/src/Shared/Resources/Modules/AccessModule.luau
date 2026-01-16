local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Handler = require(ReplicatedStorage.APIs.handler)
local DataAPI = require(ReplicatedStorage.APIs.data)
local Remotes = ReplicatedStorage.Remotes.Gameplay

local DayNight = {}

function DayNight.start(dayDuration, nightDuration)
	Lighting.ClockTime = 9
	task.spawn(function()
		while true do
			Handler.tween(Lighting, {dayDuration, "Linear"}, {ClockTime = 23.99}):Play()
			task.wait(dayDuration)
			for _, player in pairs(Players:GetPlayers()) do
				local data = DataAPI.Data(player)
				if not data then continue end
				Remotes.EndOfDay:FireClient(player, data.Day, data.DailyStats)
				data.Day += 1
				data.DailyStats = { Customers = 0, CustomersServed = 0, StartXP = data.XP, StartPopularity = data.Popularity, StartCash = data.Cash }
				DataAPI.UpdateData(player)
			end
			Lighting.ClockTime = 0
			Handler.tween(Lighting, {nightDuration, "Linear"}, {ClockTime = 9}):Play()
			task.wait(nightDuration)
		end
	end)
end

return DayNight


