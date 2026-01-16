local module = {}
local GameplayAPI = require(script.Parent.gameplay)
local Settings = require(script.Parent.settings)
local Handler = require(script.Parent.handler)
local DataAPI = require(script.Parent.data)
local Remotes = script.Parent.Parent.Remotes

module.Quests = {
	["Level"] = {
		Refresh = nil,
		RefreshFromFirstJoin = false,
		RandomSessions = false,
		AutoClaim = false,

		Sessions = {
			{
				{
					Level = 1,
					Text = "Finish tutorial!",
					Rewards = {
						{Type = "XP", Amount = 10},
					},
					Progress = function(Data, Start)
						local Value = Data.Settings.Tutorial
						return Value/30, Value.."/30", Value
					end
				},
				{
					Level = 2,
					Text = "Buy a shelf!",
					Rewards = {
						{Type = "Cash", Amount = 50},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Shelf"] or 0) - (Start or 0) -- Assuming "Shelf" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 2,
					Text = "Buy Cheese Slices!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Cheese Slices"] or 0) - (Start or 0) -- Assuming "Cheese Slices" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 3,
					Text = "Buy Tomatoes!",
					Rewards = {
						{Type = "Cash", Amount = 25},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Tomatoes"] or 0) - (Start or 0) -- Assuming "Tomatoes" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 3,
					Text = "Buy Expansion 2!",
					Rewards = {
						{Type = "XP", Amount = 10},
					},
					Progress = function(Data, Start)
						local Value = math.clamp(Data.Expansions - 1, 0, 1) -- Target is expansion 2, so we check if it's reached
						return Value, Value.."/1", Value
					end
				},
				{
					Level = 4,
					Text = "Buy a Fridge!",
					Rewards = {
						{Type = "XP", Amount = 8},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Fridge"] or 0) - (Start or 0) -- Assuming "Fridge" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 5,
					Text = "Buy a Table!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Table"] or 0) - (Start or 0) -- Assuming "Table" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 6,
					Text = "Buy Drink Cups!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Drink Cups"] or 0) - (Start or 0) -- Assuming "Drink Cups" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 6,
					Text = "Buy a Drink Dispenser!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Drink Dispenser"] or 0) - (Start or 0) -- Assuming "Drink Dispenser" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 7,
					Text = "Buy a 2nd Register!",
					Rewards = {
						{Type = "XP", Amount = 10},
					},
					Progress = function(Data, Start)
						local Value = math.clamp((Data.BoughtCount["Register"] or 0) - 1, 0, 1) -- Check if the count is at least 2
						return Value, Value.."/1", Value
					end
				},
				{
					Level = 8,
					Text = "Buy an Order Screen!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Order Screen"] or 0) - (Start or 0) -- Assuming "Order Screen" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 8,
					Text = "Hire your first employee!",
					Rewards = {
						{Type = "XP", Amount = 10},
					},
					Progress = function(Data, Start)
						local Value = math.clamp(Handler.dictionaryLength(Data.NPCs) - 0, 0, 1) -- Check if the employee count is at least 1
						return Value, Value.."/1", Value
					end
				},
				{
					Level = 9,
					Text = "Buy Fry Boxes!",
					Rewards = {
						{Type = "Cash", Amount = 20},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Fry Boxes"] or 0) - (Start or 0) -- Assuming "Fry Boxes" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 9,
					Text = "Buy a Fry Pack!",
					Rewards = {
						{Type = "Cash", Amount = 50},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Fry Pack"] or 0) - (Start or 0) -- Assuming "Fry Pack" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 9,
					Text = "Buy a Frier!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Frier"] or 0) - (Start or 0) -- Assuming "Frier" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 10,
					Text = "Buy Expansion 3!",
					Rewards = {
						{Type = "Cash", Amount = 20},
					},
					Progress = function(Data, Start)
						local Value = math.clamp(Data.Expansions - 2, 0, 1) -- Target is expansion 3
						return Value, Value.."/1", Value
					end
				},
				{
					Level = 12,
					Text = "Buy Lettuce!",
					Rewards = {
						{Type = "Cash", Amount = 20},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Lettuce"] or 0) - (Start or 0) -- Assuming "Lettuce" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 15,
					Text = "Buy Onions!",
					Rewards = {
						{Type = "XP", Amount = 10},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Onions"] or 0) - (Start or 0) -- Assuming "Onions" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 15,
					Text = "Buy Expansion 4!",
					Rewards = {
						{Type = "Cash", Amount = 50},
					},
					Progress = function(Data, Start)
						local Value = math.clamp(Data.Expansions - 3, 0, 1) -- Target is expansion 4
						return Value, Value.."/1", Value
					end
				},
				{
					Level = 15,
					Text = "Hire your second employee!",
					Rewards = {
						{Type = "Cash", Amount = 125},
					},
					Progress = function(Data, Start)
						local Value = math.clamp(Handler.dictionaryLength(Data.NPCs) - 1, 0, 1) -- Check if the employee count is at least 2
						return Value, Value.."/1", Value
					end
				},
				{
					Level = 18,
					Text = "Buy a Nugget Box!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Nugget Box"] or 0) - (Start or 0) -- Assuming "Nugget Box" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 18,
					Text = "Buy a Nugget Pack!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Nugget Pack"] or 0) - (Start or 0) -- Assuming "Nugget Pack" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 20,
					Text = "Buy Pickles!",
					Rewards = {
						{Type = "Cash", Amount = 50},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Pickles"] or 0) - (Start or 0) -- Assuming "Pickles" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 20,
					Text = "Hire your third employee!",
					Rewards = {
						{Type = "XP", Amount = 10},
					},
					Progress = function(Data, Start)
						local Value = math.clamp(Handler.dictionaryLength(Data.NPCs) - 2, 0, 1) -- Check if the employee count is at least 3
						return Value, Value.."/1", Value
					end
				},
				{
					Level = 20,
					Text = "Buy Expansion 5!",
					Rewards = {
						{Type = "Cash", Amount = 25},
					},
					Progress = function(Data, Start)
						local Value = math.clamp(Data.Expansions - 4, 0, 1) -- Target is expansion 5
						return Value, Value.."/1", Value
					end
				},
				{
					Level = 24,
					Text = "Buy an Ice cream & Milkshake Machine!",
					Rewards = {
						{Type = "Cash", Amount = 50},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Ice cream & Milkshake Machine"] or 0) - (Start or 0) -- Assuming the full name is used
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 24,
					Text = "Buy Milkshake Cups!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Milkshake Cups"] or 0) - (Start or 0) -- Assuming "Milkshake Cups" is the item name
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 25,
					Text = "Hire your fourth employee!",
					Rewards = {
						{Type = "Cash", Amount = 100},
					},
					Progress = function(Data, Start)
						local Value = math.clamp(Handler.dictionaryLength(Data.NPCs) - 3, 0, 1)  --check for 4 employees
						return Value, Value.."/1", Value
					end
				},
				{
					Level = 25,
					Text = "Buy Expansion 6!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = math.clamp(Data.Expansions - 5, 0, 1)
						return Value, Value.."/1", Value
					end
				},
				{
					Level = 26,
					Text = "Buy Ice Cream Cones!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Ice Cream Cones"] or 0) - (Start or 0)
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 30,
					Text = "Buy an Onion Ring Pack!",
					Rewards = {
						{Type = "Cash", Amount = 100},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Onion Ring Pack"] or 0) - (Start or 0)
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 30,
					Text = "Buy an Onion Ring Tray!",
					Rewards = {
						{Type = "Cash", Amount = 50},
					},
					Progress = function(Data, Start)
						local Value = (Data.BoughtCount["Onion Ring Tray"] or 0) - (Start or 0)
						return Value/1, Value.."/1", Value
					end
				},
				{
					Level = 30,
					Text = "Serve 10 Onion Rings!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.ServedItemCount["Onion Rings"] or 0) - (Start or 0)
						return Value/10, Value.."/10", Value
					end
				},
				{
					Level = 30,
					Text = "Buy Expansion 7!",
					Rewards = {
						{Type = "XP", Amount = 30},
					},
					Progress = function(Data, Start)
						local Value = math.clamp(Data.Expansions - 6, 0, 1)
						return Value, Value.."/1", Value
					end
				},
			},
		}
	},
	["Quests"] = {
		Refresh = nil,
		RefreshFromFirstJoin = true,
		RandomSessions = true,
		AutoClaim = false,
		QuestCount = 4,

		Rewards = nil,

		Sessions = {
			{
				{
					Text = "Serve 3x customers!",
					Rewards = {
						{Type = "Cash", Amount = 30},
					},
					Progress = function(Data, Start)
						local Value = Data.CustomersServed - (Start or 0)
						return Value/3, Value.."/3", Value
					end
				},
				{
					Text = "Serve 5x customers!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = Data.CustomersServed - (Start or 0)
						return Value/5, Value.."/5", Value
					end
				},
				{
					Text = "Serve 7x customers!",
					Rewards = {
						{Type = "Cash", Amount = 15},
					},
					Progress = function(Data, Start)
						local Value = Data.CustomersServed - (Start or 0)
						return Value/7, Value.."/7", Value
					end
				},
				{
					Text = "Serve 10x customers!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = Data.CustomersServed - (Start or 0)
						return Value/10, Value.."/10", Value
					end
				},
				{
					Text = "Serve 15x customers!",
					Rewards = {
						{Type = "Cash", Amount = 35},
					},
					Progress = function(Data, Start)
						local Value = Data.CustomersServed - (Start or 0)
						return Value/15, Value.."/15", Value
					end
				},
				{
					Text = "Serve 3x burgers!",
					Rewards = {
						{Type = "Cash", Amount = 15},
					},
					Progress = function(Data, Start)
						local Value = (Data.ServedItemCount["Burger"] or 0) - (Start or 0)
						return Value/3, Value.."/3", Value
					end
				},
				{
					Text = "Serve 5x burgers!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.ServedItemCount["Burger"] or 0) - (Start or 0)
						return Value/5, Value.."/5", Value
					end
				},
				{
					Text = "Serve 8x burgers!",
					Rewards = {
						{Type = "Cash", Amount = 20},
					},
					Progress = function(Data, Start)
						local Value = (Data.ServedItemCount["Burger"] or 0) - (Start or 0)
						return Value/8, Value.."/8", Value
					end
				},
				{
					Text = "Serve 10x burgers!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = (Data.ServedItemCount["Burger"] or 0) - (Start or 0)
						return Value/10, Value.."/10", Value
					end
				},
				{
					Text = "Serve 15x burgers!",
					Rewards = {
						{Type = "Cash", Amount = 15},
					},
					Progress = function(Data, Start)
						local Value = (Data.ServedItemCount["Burger"] or 0) - (Start or 0)
						return Value/15, Value.."/15", Value
					end
				},
				{
					Text = "Earn $100 total!",
					Rewards = {
						{Type = "Cash", Amount = 15},
					},
					Progress = function(Data, Start)
						local Value = Data.TotalCash - (Start or 0)
						return Value/100, "$"..math.floor(Value).."/100", Value
					end
				},
				{
					Text = "Earn $250 total!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = Data.TotalCash - (Start or 0)
						return Value/250, "$"..math.floor(Value).."/250", Value
					end
				},
				{
					Text = "Earn $400 total!",
					Rewards = {
						{Type = "Cash", Amount = 34},
					},
					Progress = function(Data, Start)
						local Value = Data.TotalCash - (Start or 0)
						return Value/400, "$"..math.floor(Value).."/400", Value
					end
				},
				{
					Text = "Earn $600 total!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = Data.TotalCash - (Start or 0)
						return Value/600, "$"..math.floor(Value).."/600", Value
					end
				},
				{
					Text = "Play for 1 minute!",
					Rewards = {
						{Type = "Cash", Amount = 10},
					},
					Progress = function(Data, Start)
						local Value = Data.PlayTime - (Start or 0)
						return Value/(60*1), math.floor(Value/60).."m/1m", Value
					end
				},
				{
					Text = "Play for 2 minutes!",
					Rewards = {
						{Type = "XP", Amount = 10},
					},
					Progress = function(Data, Start)
						local Value = Data.PlayTime - (Start or 0)
						return Value/(60*2), math.floor(Value/60).."m/2m", Value
					end
				},
				{
					Text = "Play for 3 minutes!",
					Rewards = {
						{Type = "Cash", Amount = 10},
					},
					Progress = function(Data, Start)
						local Value = Data.PlayTime - (Start or 0)
						return Value/(60*3), math.floor(Value/60).."m/3m", Value
					end
				},
				{
					Text = "Play for 5 minutes!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = Data.PlayTime - (Start or 0)
						return Value/(60*5), math.floor(Value/60).."m/5m", Value
					end
				},
				{
					Text = "Complete 2x in-game days!",
					Rewards = {
						{Type = "Cash", Amount = 10},
					},
					Progress = function(Data, Start)
						local Value = Data.DaysCompleted - (Start or 0)
						return Value/2, Value.."/2", Value
					end
				},
				{
					Text = "Complete 4x in-game days!",
					Rewards = {
						{Type = "XP", Amount = 5},
					},
					Progress = function(Data, Start)
						local Value = Data.DaysCompleted - (Start or 0)
						return Value/4, Value.."/4", Value
					end
				},
			}
		}
	},
}


module.HighestLevelQuest = 0

for _,Quest in pairs(module.Quests.Level.Sessions[1]) do
	module.HighestLevelQuest = Quest.Level > module.HighestLevelQuest and Quest.Level or module.HighestLevelQuest
end

function module.Elapsed(Data, Type)
	return module.Quests[Type].RefreshFromFirstJoin and (os.time() - Data.FirstJoin) or os.time()
end

function module.GetVersion(Data, Type)
	if not module.Quests[Type].Refresh then return 1 end
	return math.floor(module.Elapsed(Data, Type) / module.Quests[Type].Refresh) + 1
end

function module.GetSession(Data, Type)
	return Data.Quests[Type].Session
end

function module.SetSession(Data, Type)
	local Sessions = module.Quests[Type].Sessions
	local Current = module.GetSession(Data, Type)
	local Next = Current
	
	while Next == Current do
		Next = module.Quests[Type].RandomSessions and math.random(#Sessions) or (Current % #Sessions + 1)
		if #Sessions <= 1 then break end
	end
	Data.Quests[Type].Session = Next
	
	local Available = {}
	for Index,_ in pairs(Sessions[Next]) do
		table.insert(Available, Index)
	end
	
	for Quest,Info in pairs(Data.Quests[Type].Quests) do
		local Chosen = math.random(#Available)
		Info.Quest = Available[Chosen]
		Info.Start = select(3, module.Quests[Type].Sessions[Next][Info.Quest].Progress(Data))
		Info.Tracking = true
		Info.Claimed = false
		if #Available > 1 then table.remove(Available, Chosen) end
	end
end

function module.SessionInfo(Data, Type)
	return module.Quests[Type].Sessions[module.GetSession(Data, Type)]
end

function module.QuestInfo(Data, Type, Quest)
	return module.SessionInfo(Data, Type)[Quest]
end

function module.TimeRemaining(Data, Type)
	if not module.Quests[Type].Refresh then return 0 end
	return module.GetVersion(Data, Type) * module.Quests[Type].Refresh - module.Elapsed(Data, Type)
end

function module.RewardQuest(Player, Type, Quest)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	
	local Quests = Data.Quests[Type].Quests
	local DataInfo = Quests[tostring(Quest)]
	local QuestInfo = module.QuestInfo(Data, Type, DataInfo.Quest)
	
	if DataInfo.Claimed then return end
	local SessionInfo = module.SessionInfo(Data, Type)
	
	DataInfo.Claimed = true
	DataAPI.UpdateData(Player)
	if QuestInfo.Rewards then
		Remotes.Handler.Notify:FireClient(Player, Settings.RewardPlayer(Player, QuestInfo.Rewards), "Green")
	end
	
	local ClaimedAll = true
	for _,Info in pairs(Quests) do
		if not Info.Claimed then ClaimedAll = false break end
	end
	
	if SessionInfo.Rewards and ClaimedAll then
		Remotes.Handler.Notify:FireClient(Player, Settings.RewardPlayer(Player, SessionInfo.Rewards), "Green")
	end
	
	if module.Quests[Type].Refresh then return end
	if Type == "Level" then
		Data.Quests[Type].Quests[Quest] = nil
		DataAPI.UpdateData(Player)
		return
	end
	module.SetSession(Data, Type)
	DataAPI.UpdateData(Player)
end

function module.ClaimQuest(Player, Type, Quest)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local Quests = Data.Quests[Type].Quests
	local DataInfo = Quests[tostring(Quest)]
	local QuestInfo = module.QuestInfo(Data, Type, DataInfo.Quest)
	
	if QuestInfo.Progress(Data, DataInfo.Start) < 1 then return end
	
	module.RewardQuest(Player, Type, Quest)
end

return module