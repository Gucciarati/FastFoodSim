--!strict
local MarketplaceService = game:GetService("MarketplaceService")



local function PopulateBoostsList()

    for _, BoostData in BoostsRegistry.registry do
        local BoostFrame = BoostTemplate:Clone()
        BoostFrame.Parent = BoostsScrollFrame
        BoostFrame.Name = BoostData.Name

        local NameLabel = BoostFrame.Name
        local DescriptionLabel = BoostFrame.Description
        local IconImage = BoostFrame.Icon
        local ActivateButton = BoostFrame.ActivateButton

        NameLabel.Text = BoostData.Name
        DescriptionLabel.Text = BoostData.Description
        IconImage.Image = BoostData.Icon

        for DurationName, DurationValue in BoostData.Durations do
            local PriceInRobux = MarketplaceService:GetProductInfo(DurationValue.ProductId).PriceInRobux

            local DurationButton = BoostFrame.DurationsFrame.Template:Clone()
            local DurationLabel = DurationButton.DurationLabel
            local PriceLabel = DurationButton.PriceLabel

                DurationLabel.Text = DurationName
                PriceLabel.Text = ` {PriceInRobux}`

                DurationButton.Activated:Connect(function()
                    MarketplaceService:PromptProductPurchase(LocalPlayer, DurationValue.ProductId)
                end)

                DurationButton.Parent = BoostFrame.DurationsFrame
        end

        ActivateButton.Activated:Connect(function()
            
        end)
    end

end


    