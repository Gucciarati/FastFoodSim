--[[
	Day/Night Cycle Module
	----------------
	Bootstraps the day/night cycle by delegating to DayNightModule with
	provided or default durations.

	Created by: Guinogue — Modified on October 29, 2025
]]

-----< Services and dependencies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DayNightModule = require(ReplicatedStorage.Resources.Modules.DayNightModule)

-----< Module table
local M = {}

-----< Public API
function M.init(dayDuration, nightDuration)
	local dd = dayDuration or 600
	local nd = nightDuration or 10
	DayNightModule.start(dd, nd)
end

-----< Exports
return M


