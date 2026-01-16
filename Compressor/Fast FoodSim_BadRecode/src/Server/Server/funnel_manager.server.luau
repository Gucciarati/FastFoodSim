local AnalyticsService = game:GetService("AnalyticsService")

local events = {
	"Opened Computer",
	"Added Buns + Papers + Patties to Cart",
	"Bought them",
	"Dragged items to kitchen",
	"Opened Boxes",
	"Opened Store",
	"Waited for Customers",
	"Took Order",
	"Placed Tray",
	"Took 1 Paper",
	"Placed Papers",
	"Took 1 Bun",
	"Placed the Bun",
	"Took 1 Patty",
	"Placed Patty on Grill",
	"Flipped Patty",
	"Took Patty",
	"Put Patty on Burger",
	"Wrapped Burger",
	"Placed Burger",
	"Took Tray",
	"Served Tray",
	"Waited for Customer to Finish Eating",
	"Collected Money",
	"Went to Computer",
	"Bought Basic Chair",
	"Opened Basic Chair Package",
	"Placed Basic Chair on Table"
}

game.ReplicatedStorage.Remotes.Data.OnboardingFunnels.OnServerEvent:Connect(function(player, idx)
	AnalyticsService:LogOnboardingFunnelStepEvent(
		player,
		idx, -- Step number
		events[idx] -- Step name
	)
end)