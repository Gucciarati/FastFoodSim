--!strict

return function(Currencies: any, Player: Player, CurrencyName: string, Amount: number)
	local CurrenciesData = Currencies:GetFromPlayer(Player)
	CurrenciesData[CurrencyName] = Amount
end
