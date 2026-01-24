--!strict
local CollectionService   = game:GetService("CollectionService")
local ReplicatedStorage   = game:GetService('ReplicatedStorage')

local Utils               = ReplicatedStorage:WaitForChild('Utils')
local RequireAttribute    = require(Utils.RequireAttribute)
local Visibility          = require(Utils.Visibility)

local Assets              = ReplicatedStorage:WaitForChild('Assets')
local RestaurantAssets    = Assets.Restaurants


export type RestaurantAssembly = typeof(RestaurantAssets['1'])

local module = {
	Attributes = {
		Owner = "Owner",
		OwnerId = "OwnerId",
	},
	Tags = {
		OpenRestaurant = "OpenRestaurant",
		PlacementArea  = "PlacementArea",
		Snap           = "Snap",
	}
}

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
	local char = player.Character or player.CharacterAdded:Wait()
	
	if char then
		char:PivotTo(restaurant.Spawn.CFrame)	
	end
	
end

function module.nameRestaurant(restaurant:RestaurantAssembly, name:string)
	restaurant.RestaurantName.SurfaceGui.TextLabel.Text = name
end

function module.spawnPlayerRestaurant(owner: Player, name: string, PlotFolder: Folder): RestaurantAssembly
	local restaurant = RestaurantAssets["1"]:Clone()
		
	local Base = PlotFolder:FindFirstChild("Base") :: BasePart
	restaurant:PivotTo(Base.CFrame)
	
	RequireAttribute.requireAttribute(restaurant, module.Attributes.Owner, owner.UserId)
	module.nameRestaurant(restaurant, name)
	module.toggleRestaurantOpenState(restaurant, false)
	
	local tutorialFolder = restaurant.Tutorial
	for _, tutorialStep in tutorialFolder:GetChildren() do
		module.toggleTutorialStepVisuals(restaurant, tutorialStep.Name, false)
	end
	
	
	module.hideRestaurantHelpers(restaurant)
	
	restaurant.Parent = PlotFolder
	return restaurant
end

function module.hideRestaurantHelpers(restaurant: RestaurantAssembly)
	
	for _, Snap in CollectionService:GetTagged(module.Tags.Snap) do
		if Snap:IsDescendantOf(restaurant) then
			Visibility.HideChildren(Snap)
		end
	end
	

	local Placement = restaurant:FindFirstChild("Placement", true)
	if Placement then
		Visibility.Hide(Placement)
	end
	
	local Waypoints = restaurant:FindFirstChild("Waypoints", true)
	if Waypoints then
		Visibility.Hide(Waypoints)
	end
end



return module
