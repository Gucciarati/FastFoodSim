local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local WillsApi = require(ReplicatedStorage.APIs.willsAPI)

local Remotes = ReplicatedStorage.Remotes
local Placement = Remotes.Placement

local Placing = {}

Placement.StartPlacing.OnServerEvent:Connect(function(Player, Item)
	if Item then
		Item:SetAttribute("Placing", true)
		Placing[Player] = Item
	end
end)

Placement.UpdatePosition.OnServerEvent:Connect(function(Player, CFrame)
	if Placing[Player] then
		ReplicatedStorage.Remotes.Placement.UpdatePosition:FireAllClients(
			Player, Placing[Player], CFrame
		)
	end
end)

Placement.StopPlacing.OnServerEvent:Connect(function(Player)
	local Item = Placing[Player]
	if Item then
		Item:SetAttribute("Placing", nil)
		Placing[Player] = nil
	end
end)

local Types = {
	["Gold10Mins"] = {
		Product = 3289847752,
		Time = 60 * 10
	},
	
	["Gold30Mins"] = {
		Product = 3289847834,
		Time = 60 * 30
	},
	
	["Gold2Hrs"] = {
		Product = 3289847878,
		Time = 60 * 60 * 2
	},
}

local function StartGoldRush(Player, Type)
	if workspace:GetAttribute("GoldRush") == true then
		Remotes.Handler.Notify:FireClient(Player, "Gold Rush already going on!", "Red")
		return
	end
	
	if Type then
		local Time = Types[Type].Time
		workspace:SetAttribute("GoldRush", true)
		workspace:SetAttribute("GoldRushTime", Time)
		workspace:SetAttribute("GoldRushStart", os.time())
		Remotes.Handler.Notify:FireAllClients(
			`Gold Rush For {Time/60} Minutes!`
		)
		
		task.delay(Time, function()
			workspace:SetAttribute("GoldRush", nil)
			Remotes.Handler.Notify:FireAllClients(
				"Gold Rush has ended!"
			)
		end)
	end
end

for i, v in WillsApi.DevProducts do
	if Types[i] then
		v:Connect(function(Plr)
			StartGoldRush(Plr, i)
		end)
	end
end

Remotes.Store.GoldRush.OnServerEvent:Connect(function(Player: Player, Type: string)
	if workspace:GetAttribute("GoldRush") == true then
		Remotes.Handler.Notify:FireClient(Player, "Gold Rush already going on!", "Red")
		return
	end
	
	if not Types[Type] then return end
	
	MarketplaceService:PromptProductPurchase(Player, Types[Type].Product)
	game.ReplicatedStorage.Remotes.Store.StartRobux:FireClient(Player)
end)