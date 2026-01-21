--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local CurrenciesComponent = require(Components.CurrenciesComponent)
local DetermineLaneUpgradeCost = require(ReplicatedStorage.Util.Config.DetermineLaneUpgradeCost)

local SharedTypes = require(Components.Types.HillsComponent)

type HillsComponent = SharedTypes.HillsComponent

return function(Hills: HillsComponent, Player: Player, HillId: number)
	local Hill = Hills:GetHill(Player, HillId)
	if not Hill then return nil end

	Hill.Lanes = Hill.Lanes or {}
	local NextLaneId = #Hill.Lanes + 1
	local Cost = DetermineLaneUpgradeCost(NextLaneId)
	
	local Currencies = CurrenciesComponent:GetFromPlayer(Player)
	local Cash = CurrenciesComponent:GetCurrency(Currencies, Player, "Cash")

	if Cash < Cost then return nil end

	local NewLane = {
		LaneId = NextLaneId,
		EmployeeId = nil,
		IsOccupied = false,
		Multipliers = {
			Speed = 1,
			Snow = 1,
		},
	}

	table.insert(Hill.Lanes, NewLane)
	CurrenciesComponent:IncrementCurrency(Currencies, Player, "Cash", -Cost)

	return NewLane  :: any
end
