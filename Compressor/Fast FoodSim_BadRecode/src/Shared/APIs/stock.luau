local module = {}
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Handler = require(script.Parent.handler)

module.Version = "StocksV2"
module.Updates = script.Updates
module.Live = script.Live

if RunService:IsServer() then
	module.DataStores = {}
	module.Intervals = 3
	
	function module.CreateGroup(Group)
		module.DataStores[Group] = DataStoreService:GetOrderedDataStore(module.Version..Group)
		local Stocks = {}
		local Pages = module.DataStores[Group]:GetSortedAsync(false, 100)
		while true do
			for _,Data in pairs(Pages:GetCurrentPage()) do
				table.insert(Stocks, Handler.create("IntValue", nil, Data.key, Handler.clampPositive(Data.value)))
			end
			if Pages.IsFinished or #Pages:GetCurrentPage() < 1 then break end
			Pages:AdvanceToNextPageAsync()
		end
		Handler.create("Folder", module.Updates, Group)
		local Live = Handler.create("Folder", module.Live, Group)
		for _,Stock in pairs(Stocks) do
			Stock.Parent = Live
		end
	end
	
	function module.CreateStock(Group, Stock, Start)
		if not module.DataStores[Group] then return end
		if module.Live[Group]:FindFirstChild(Stock) then return end
		if select(2, Handler.forcePcall(5, .5, module.DataStores[Group].SetAsync, module.DataStores[Group], Stock, Start)) then
			Handler.create("IntValue", module.Live[Group], Stock, Handler.clampPositive(Start))
		end
	end
	
	function module.IncrementStock(Group, Stock, Increment, Updated)
		if not module.DataStores[Group] then return end
		local Live = module.Live[Group]:FindFirstChild(Stock) or Handler.create("IntValue", module.Live[Group], Stock)
		Live.Value = Handler.clampPositive(Live.Value + Increment)
		if Updated then return end
		local Update = module.Updates[Group]:FindFirstChild(Stock) or Handler.create("IntValue", module.Updates[Group], Stock)
		Update.Value += Increment
	end
end

function module.Stock(Group, Stock)
	return module.Live[Group][Stock].Value
end

return module