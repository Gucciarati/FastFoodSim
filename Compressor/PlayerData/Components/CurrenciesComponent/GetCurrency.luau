--!strict

return function(self, Player: Player, CurrencyName: string): number
	local Currencies = self:GetFromPlayer(Player)
	return Currencies[CurrencyName]
end
