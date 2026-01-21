--!strict

return function(Stats: any, Player: Player, StatName: string)
	local StatsData = Stats:GetFromPlayer(Player)
	return StatsData[StatName]
end
