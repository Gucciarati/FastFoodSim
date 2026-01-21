--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local CurrenciesComponent = require(Components.CurrenciesComponent)
local DetermineHillUpgradeCost = require(ReplicatedStorage.Util.Config.DetermineHillUpgradeCost)
local SharedTypes = require(Components.Types.HillsComponent)

type HillsComponent = SharedTypes.HillsComponent

return function(Hills: HillsComponent, Player: Player, HillId: number)
	local Hill = Hills:GetHill(Player, HillId)
	if not Hill then return nil end

	local Cost = DetermineHillUpgradeCost(Hill.Level)
	local Currencies = CurrenciesComponent:GetFromPlayer(Player)
	local Cash = CurrenciesComponent:GetCurrency(Currencies, Player, "Cash")
	if Cash < Cost then return nil end

	Hill.Level += 1
	CurrenciesComponent:IncrementCurrency(Currencies, Player, "Cash", -Cost)

	return Hill.Level
end
