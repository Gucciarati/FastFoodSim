--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.MuseumComponent)

type MuseumComponent = SharedTypes.MuseumComponent


return function(Museum: MuseumComponent, Player: Player): number
	local MuseumData = Museum:GetFromPlayer(Player)
	if not MuseumData then return 0 end

	local TotalIncome = 0
	local UtilsFolder = ReplicatedStorage.Util
	local DetermineSnowmanIncome = require(UtilsFolder.Config.DetermineSnowmanIncome)

	for _, Slot in MuseumData.Slots do
		if Slot and Slot.SnowmanName then
			local BaseIncome = DetermineSnowmanIncome(Slot.SnowmanName)
			TotalIncome += BaseIncome
		end
	end

	return TotalIncome * MuseumData.IncomeMultiplier
end
