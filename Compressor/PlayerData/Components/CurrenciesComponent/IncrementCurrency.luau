--!strict

return function(self, Player: Player, CurrencyName: string, Amount: number)
	local Currencies = self:GetFromPlayer(Player)
	if not Currencies[CurrencyName] then
		Currencies[CurrencyName] = 0
	end
	Currencies[CurrencyName] += Amount
end
