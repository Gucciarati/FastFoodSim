--!strict

return function(Stats: any, Player: Player, StatName: string, Value: any)
	local StatsData = Stats:GetFromPlayer(Player)
	StatsData[StatName] = Value
end
