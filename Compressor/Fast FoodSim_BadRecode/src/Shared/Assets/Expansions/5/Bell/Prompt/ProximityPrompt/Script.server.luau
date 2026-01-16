script.Parent.Triggered:Connect(function(p)
	game.MarketplaceService:PromptProductPurchase(p, 3288470102)
	
	game.ReplicatedStorage.Remotes.Store.StartRobux:FireClient(p)
end)