--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')


local Shared              = ReplicatedStorage:WaitForChild('SharedModules')
local Utils               = ReplicatedStorage:WaitForChild('Utils')
local Vendor              = ReplicatedFirst.Vendor

local RequireAttribute    = require(Utils.RequireAttribute)

local Assets              = ReplicatedStorage:WaitForChild('Assets')
local RestaurantAssets    = Assets.Restaurants
local Plots               = workspace.Plots


export type RestaurantAssembly = typeof(RestaurantAssets['1'])

local module = {
	Attributes = {
		Owner = "Owner",
		VacantPlot = "VacantPlot",
	},
	Tags = {
		OpenRestaurant = "OpenRestaurant",
		PlacementArea  = "PlacementArea",
	}
}

function module.initPlots()
	local allPlots = Plots:GetChildren()
	for _, plot in allPlots do
		local isVacant = RequireAttribute.requireAttribute(plot, module.Attributes.VacantPlot, true)
	end
end

function module.toggleTutorialStepVisuals(restaurant: RestaurantAssembly, step:number, visible : boolean)
	local tutorialFolder = restaurant.Tutorial
	local stepFolder = tutorialFolder:FindFirstChild(tostring(step))
	if not stepFolder then
		warn('no step found')
		return
	end
	for _, inst:Instance in stepFolder:GetDescendants(stepFolder) do
		if inst:IsA('BasePart') then
			if visible then
				inst.Transparency = 0
			else
				inst.Transparency = 1
			end
		end
	end
end

function module.toggleRestaurantOpenState(restaurant: RestaurantAssembly, isOpen:boolean)
	if isOpen then
		restaurant:AddTag(module.Tags.OpenRestaurant)
	else
		restaurant:RemoveTag(module.Tags.OpenRestaurant)
	end
	
	local neonSign = restaurant.Sign
		

	for _, neonPart : BasePart in neonSign.Neon:GetChildren() do
		if isOpen then
			neonPart.Material = Enum.Material.Neon
		else
			neonPart.Material = Enum.Material.Plastic
		end
	end
end

function module.tpPlayerToRestaurant(player:Player, restaurant:RestaurantAssembly)
	local char = player.Character
	if char then
		char:PivotTo(restaurant.Spawn.CFrame)	
	end
	
end

function module.nameRestaurant(restaurant:RestaurantAssembly, name:string)
	restaurant.RestaurantName.SurfaceGui.TextLabel.Text = name
end

function module.spawnPlayerRestaurant(owner:Player, name:string) : RestaurantAssembly
	local restaurant = RestaurantAssets["1"]:Clone()
	-- get all vacant plots
	local allPlots = Plots:GetChildren()
	local vacantPlots = {} :: {BasePart}
	for _, plot in allPlots do
		local isVacant = RequireAttribute.requireAttribute(plot, module.Attributes.VacantPlot, true)
		if isVacant then
			table.insert(vacantPlots,plot)
		end
	end
	
	if #vacantPlots == 0 then
		owner:Kick('no vacant plots')
		error('no vacant plots')
	end
	
	local selectedPlot = vacantPlots[math.random( #vacantPlots )] :: BasePart
	-- fill the plot vacancy
	RequireAttribute.requireAttribute(selectedPlot, module.Attributes.VacantPlot, false, true)
	-- save a plot reference inside the restaurant so when we destroy the restaurant we can make the occupied plot vacant again
	restaurant.PlotRef.Value = selectedPlot
	restaurant:PivotTo(selectedPlot.CFrame)
	
	-- set metadata
	RequireAttribute.requireAttribute(restaurant,module.Attributes.Owner, owner.UserId)
	module.nameRestaurant(restaurant, name)
	-- start the restaurant as closed
	module.toggleRestaurantOpenState(restaurant, false)
	-- turn off tutorial visuals
	local tutorialFolder = restaurant.Tutorial
	for _, tutorialStep in tutorialFolder:GetChildren() do
		module.toggleTutorialStepVisuals(restaurant, tutorialStep.Name, false)
	end
	
	restaurant.Parent = workspace	
	return restaurant
end



return module
