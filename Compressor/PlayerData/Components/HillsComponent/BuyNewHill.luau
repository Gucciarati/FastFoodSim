--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DetermineHillUpgradeCost = require(ReplicatedStorage.Util.Config.DetermineHillUpgradeCost)
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local CurrenciesComponent = require(Components.CurrenciesComponent)
local SharedTypes = require(Components.Types.HillsComponent)

type HillsComponent = SharedTypes.HillsComponent

return function(Hills: HillsComponent, Player: Player)
	local HillsData = Hills:GetFromPlayer(Player)
	if not HillsData then return nil end

	local NextHillId = #HillsData + 1
	local Cost = DetermineHillUpgradeCost(NextHillId)
	local Currencies = CurrenciesComponent:GetFromPlayer(Player)
	local Cash = CurrenciesComponent:GetCurrency(Currencies, Player, "Cash")

	if Cash < Cost then return nil end
	
	local NewHill = {
		HillId = NextHillId,
		Level = 1,
		Lanes = {
			{
				LaneId = 1,
				EmployeeId = nil,
				IsOccupied = false,
				Multipliers = {
					Speed = 1,
					Snow = 1,
				},
			},
		},
	}

	table.insert(HillsData, NewHill)
	CurrenciesComponent:IncrementCurrency(Currencies, Player, "Cash", -Cost)

	return NewHill :: any
end
