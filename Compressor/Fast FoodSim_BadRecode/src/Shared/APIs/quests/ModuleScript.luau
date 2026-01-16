local templates = {
	{
	Level = 1,
	Text = "Finish tutorial!",
	Rewards = {
		{Type = "Cash", Amount = 1000}, --change "Cash" to "XP" if it's XP.
	},
	Progress = function(Data, Start)
		local Value = Data.Settings.Tutorial
		return Value/30, Value.."/30", Value
	end
},
{
	Level = 1,
	Text = "Buy 2x patty buns!",
	Rewards = {
		{Type = "Cash", Amount = 1000}, --change "Cash" to "XP" if it's XP.
	},
	Progress = function(Data, Start)
		local Value = (Data.BoughtCount["Burger Buns"] or 0) - (Start or 0) --change burger buns to the item name
		return Value/2, Value.."/2", Value --change both numbers to the total you want them to buy
	end
},
{
	Level = 1,
	Text = "Serve 2x burgers!",
	Rewards = {
		{Type = "Cash", Amount = 1000}, --change "Cash" to "XP" if it's XP.
	},
	Progress = function(Data, Start)
		local Value = (Data.ServedItemCount["Burger"] or 0) - (Start or 0) --change burger to the food item name
		return Value/2, Value.."/2", Value --change both numbers to the total you want them to buy
	end
},
{
	Level = 1,
	Text = "Serve 2x burgers with onions!",
	Rewards = {
		{Type = "Cash", Amount = 1000}, --change "Cash" to "XP" if it's XP.
	},
	Progress = function(Data, Start)
		local Value = (Data.ServedIngredientCount["Onions"] or 0) - (Start or 0) --change onions to the ingredient name
		return Value/2, Value.."/2", Value --change both numbers to the total you want them to buy
	end
},
{
	Level = 2,
	Text = "Buy expansion 3!",
	Rewards = {
		{Type = "Cash", Amount = 1000}, --change "Cash" to "XP" if it's XP.
	},
	Progress = function(Data, Start)
		local Value = math.clamp(Data.Expansions - 2, 0, 1) --change number to one less than your target expansion
		return Value, Value.."/1", Value --change both numbers to the total you want them to buy
	end
},
{
	Level = 2,
	Text = "Buy 3rd employee!",
	Rewards = {
		{Type = "Cash", Amount = 1000}, --change "Cash" to "XP" if it's XP.
	},
	Progress = function(Data, Start)
		local Value = math.clamp(Handler.dictionaryLength(Data.NPCs) - 2, 0, 1) --change number to one less than your target employee
		return Value, Value.."/1", Value --change both numbers to the total you want them to buy
	end
},
}