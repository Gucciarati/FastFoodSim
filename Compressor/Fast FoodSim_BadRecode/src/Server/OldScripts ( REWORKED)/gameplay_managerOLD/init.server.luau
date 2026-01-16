-----< Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local Functions = ReplicatedStorage.Functions.Gameplay
local Remotes = ReplicatedStorage.Remotes.Gameplay
local Assets = ReplicatedStorage.Assets
local APIs = ReplicatedStorage.APIs
local GameplayAPI = require(APIs.gameplay)
local Settings = require(APIs.settings)
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)
local WillsAPI = require(APIs.willsAPI)
local Utilities = require(game.ReplicatedStorage.Utilities)
local Tween = Utilities.Tween 

local Animate = script.Animate
Animate.Parent = nil
Animate.Enabled = true

local OwnedRestaurants = Instance.new("Folder")
OwnedRestaurants.Name = "OwnedRestaurants"
OwnedRestaurants.Parent = workspace

local function LastParentModel(Part)
	local CurrentModel = nil
	local CurrentPart = Part

	while true do
		CurrentPart = CurrentPart.Parent

		if CurrentPart == workspace then
			return CurrentModel
		end

		if CurrentPart:IsA("Model") then
			CurrentModel = CurrentPart
		end
	end
end

-----< Rewards

Settings.RewardStringFunctions["Gameplay"] = function(Player, Reward)
	if Reward.NPC then
		return Reward.NPC.." NPC"
	elseif Reward.Package then
		return "x"..Reward.Amount.." "..Reward.Package
	end
end

Settings.RewardPlayerFunctions["Gameplay"] = function(Player, Data, Reward) 
	if Reward.NPC then
		Data.NPCs[Handler.generateGUID()] = {
			Gender = Handler.randomInt(0,1),
			Time = os.time(),
			Type = Reward.NPC,
		}
	elseif Reward.Package then
		warn("Rewarding player for gameplay")
		local Restaurant = OwnedRestaurants:WaitForChild(Player.Name)
		for Index = 1,Reward.Amount do
			local GUID = Handler.generateGUID()
			local CF = Restaurant.Spawn.CFrame*CFrame.new(Handler.random(-10,10),Handler.random(5,10),Handler.random(-10,10))
			Data.Packages[GUID] = {
				Category = Reward.Category,
				Item = Reward.Package,
				CF = tostring(Restaurant:GetPivot():ToObjectSpace(CF)),
			}
		end
	end
end

Remotes.BuyEmployee.OnServerEvent:Connect(function(Player, Employee)
	local Data = DataAPI.Data(Player)
	if not Data or not GameplayAPI.Employees[Employee] then return end
	local Employees = Handler.dictionaryLength(Data.NPCs)
	if Employees >= Data.EmployeeSlots then return end
	local Cost = GameplayAPI.Employees[Employee].Price * (1 + (Employees * GameplayAPI.PriceMultiPerEmployee))
	if Data.Cash < Cost then return end
	Data.Cash -= Cost
	Data.NPCs[Handler.generateGUID()] = {
		Gender = Handler.randomInt(0,1),
		Time = os.time(),
		Type = Employee,
	}
	DataAPI.UpdateData(Player)
end)

Remotes.DeleteEmployee.OnServerEvent:Connect(function(Player, Employee)
	local Data = DataAPI.Data(Player)
	if not Data or not Data.NPCs[Employee] then return end
	Data.NPCs[Employee] = nil
	DataAPI.UpdateData(Player)
end)

-----< Multipliers

Settings.MultiplierFunctions["Gameplay"] = function(Player, Data, Type)
	--if Type == "Weapon" then
	--	return Data.GamePasses.VIP and 2 or 1
	--end
end

-----< Purchases

Handler.productPurchaseFunctions["Gameplay"] = function(Player, Data, Product)
	--if Product == "OPWeapon" then
	--	Data.Wins += 100
	--end
end

-----< Placement boundaries

local Expansions = Assets.Expansions
Expansions.Parent = workspace

for _,Level in pairs(Expansions:GetChildren()) do
	local Unplacement = Handler.create("Folder", Level, "Unplacement")
	for _,Category in pairs(Level.Placement:GetChildren()) do
		local NewCategory = Handler.create("Folder", Unplacement, Category.Name)
		local AreaParams = OverlapParams.new()
		AreaParams.FilterType = Enum.RaycastFilterType.Include
		AreaParams.FilterDescendantsInstances = Category:GetChildren()
		for _,Area in pairs(Category:GetChildren()) do
			local CF,Size = Area.CFrame,Area.Size
			for Side = -0.5,0.5 do
				local Length = Size.Z
				local Width = Size.X
				local Streak = false
				local Segments = {}
				for Index = 1,Length do
					local CurrentCF = CF * CFrame.new(Side*Width+Side,0,-Length/2-0.5+Index)
					if workspace:GetPartBoundsInBox(CurrentCF, Vector3.one * 0.8, AreaParams)[1] then Streak = false continue end
					if not Streak then
						Streak = true
						table.insert(Segments, {})
					end
					table.insert(Segments[#Segments], Index)
				end
				for _,Segment in pairs(Segments) do
					local FirstIndex = Segment[1]
					local LastIndex = Segment[#Segment]
					local NewArea = Area:Clone()
					local CurrentCF = CF * CFrame.new(Side*Width+Side,0,-Length/2-0.5+(FirstIndex+LastIndex)/2)
					NewArea.Size = NewArea.Size * Vector3.new(0,1,0) + Vector3.new(1,0,1+LastIndex-FirstIndex)
					NewArea.CFrame = CurrentCF
					NewArea.Parent = NewCategory
					NewArea.Color = Color3.fromRGB(0,255,0)
				end
			end
			for Side = -0.5,0.5 do
				local Length = Size.X
				local Width = Size.Z
				local Streak = false
				local Segments = {}
				for Index = 1,Length do
					local CurrentCF = CF * CFrame.new(-Length/2-0.5+Index,0,Side*Width+Side)
					if workspace:GetPartBoundsInBox(CurrentCF, Vector3.one * 0.8, AreaParams)[1] then Streak = false continue end
					if not Streak then
						Streak = true
						table.insert(Segments, {})
					end
					table.insert(Segments[#Segments], Index)
				end
				for _,Segment in pairs(Segments) do
					local FirstIndex = Segment[1]
					local LastIndex = Segment[#Segment]
					local NewArea = Area:Clone()
					local CurrentCF = CF * CFrame.new(-Length/2-0.5+(FirstIndex+LastIndex)/2,0,Side*Width+Side)
					NewArea.Size = NewArea.Size * Vector3.new(0,1,0) + Vector3.new(1+LastIndex-FirstIndex,0,1)
					NewArea.CFrame = CurrentCF
					NewArea.Parent = NewCategory
					NewArea.Color = Color3.fromRGB(0,255,0)
				end
			end
		end
	end
end

Expansions.Parent = Assets

-----< Generating stores

local SampleRestaurant,Restaurants = Handler.sample(workspace.UnownedRestaurants.Sample)
local NewModel = Assets.Expansions["1"]:Clone()
NewModel.Name = "Model"
NewModel:PivotTo(SampleRestaurant:GetPivot())
NewModel.Parent = SampleRestaurant

for _,Plot in pairs(Restaurants:GetChildren()) do
	local Restaurant = SampleRestaurant:Clone()
	Restaurant:PivotTo(Plot.CFrame)
	Restaurant.Parent = Restaurants
	Plot:Destroy()
end

-----< Snaps

Handler.tagAdded("Snap", function(Snap)
	if not Snap:IsDescendantOf(workspace) then return end
	for _,Child in pairs(Snap:GetChildren()) do
		Handler.invisible(Child)
		if Child:GetAttribute("Time") then
			Handler.create("IntValue", Child, "Timer", 0)
		end
	end
end)

-----< Pathfinding

function FindPath(Restaurant, Start, Target, Path)
	Path = Path or {}
	local StartPos = Start.Position
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {Restaurant.Model}
	local Corners = Restaurant.Model.Waypoints:GetChildren()
	table.sort(Corners, function(A,B) return (StartPos-A.Position).Magnitude < (StartPos-B.Position).Magnitude end)
	table.insert(Corners, 1, Start)
	for _,Corner in pairs(Corners) do
		local Pos = Corner.Position
		if not workspace:Blockcast(CFrame.new(Pos, Target), Vector3.new(2,0.5,0.5), Target - Pos, Params) then
			local Last = Corner == Start
			table.insert(Path, Last and Target or Pos)
			return Last and Path or FindPath(Restaurant, Corner, Target, Path)
		end
	end
	table.insert(Path, Target)
	return Path
end

function WalkTo(Restaurant, NPC, Target, Yield, Turn)
	task.spawn(function()
		local Path = FindPath(Restaurant, NPC.HumanoidRootPart, Target.Position)
		for Index = 1,#Path do
			NPC.Humanoid:MoveTo(Path[Index])
			NPC.Humanoid.MoveToFinished:Wait()
		end
		if Turn then
			task.wait(0.2)
			local Final = Target + Vector3.new(0,NPC.HumanoidRootPart.Position.Y-Target.Y,0)
			Handler.tween(NPC.HumanoidRootPart, {0.2}, {CFrame = Final}):Play()
		end
		Yield = false
	end)
	while Yield do
		task.wait()
	end
end
-----< Friends

Handler.playerAddedFunction(function(Player)
	local FriendIds = Handler.create("Folder", Player, "FriendIds")
	local PlayersFriends = Players:GetFriendsAsync(math.max(1, Player.UserId))

	while true do
		local Page = PlayersFriends:GetCurrentPage()
		for _,Info in pairs(Page) do
			Handler.create("StringValue", FriendIds, Info.Id, Info.Username)
		end
		if PlayersFriends.IsFinished then break end
		PlayersFriends:AdvanceToNextPageAsync()
	end
	if #FriendIds:GetChildren() < 1 then
		Handler.create("StringValue", FriendIds, 1, "Roblox")
	end
end)

-----< Assigning stores

local activeTrucksByRestaurant = {}

Handler.playerAddedFunction(function(Player)
	local Restaurant = Restaurants:GetChildren()[math.random(#Restaurants:GetChildren())]
	Restaurant.Parent = OwnedRestaurants
	Restaurant.Name = Player.Name
	Handler.create("StringValue", Restaurant.Whitelist, Player.Name)
	local Folder = Handler.waitForData(Player)
	local Data = DataAPI.WaitForData(Player)
	if not Folder or not Data then return end
	Handler.changed(Folder.XP, function(XP)
		local Level = GameplayAPI.XPToLevel(XP)
		for Slot,Requirement in pairs(GameplayAPI.EmployeeSlots) do
			if Data.EmployeeSlots >= Slot then continue end
			if Level < Requirement then continue end
			Data.EmployeeSlots = Slot
		end
	end)
	local CurrentModel = Restaurant.Model
	local Talking = script.Talking:Clone()
	Handler.childrenChanged(Restaurant.NPCs, function()
		if not Restaurant.Parent then return end
		Talking.Volume = math.clamp((#Restaurant.NPCs:GetChildren()-1)/10,0,1)
	end)
	Handler.changed(Folder.Expansions, function(Upgrade)
		Talking.Parent = nil
		CurrentModel:Destroy()
		CurrentModel = Assets.Expansions[Upgrade]:Clone()
		CurrentModel.Name = "Model"
		CurrentModel:PivotTo(Restaurant:GetPivot())
		CurrentModel.Parent = Restaurant
		Talking.Parent = CurrentModel.Placement.Diner:FindFirstChildOfClass("BasePart")
		for _,Neon in pairs(Restaurant.Model.Sign.Neon:GetChildren()) do
			local H = Neon.Color:ToHSV()
			Neon.Color = Color3.fromHSV(H,1,Data.Settings.Open and 1 or 0.35)
		end
		Restaurant.Model.RestaurantName.SurfaceGui.TextLabel.Text = Data.Settings.RestaurantName
	end)
	Handler.childAdded(Folder.Furniture, function(Furniture)
		local FurnitureModel = Assets.Furniture:FindFirstChild(Furniture.Item.Value)
		if not FurnitureModel then warn("No furniture for: "..Furniture.Item.Value) return end
		local NewFurniture = FurnitureModel:Clone()
		NewFurniture.Name = Furniture.Name
		NewFurniture.Parent = Restaurant.Furniture:FindFirstChild(NewFurniture:GetAttribute("Type") or "Other")
		Handler.changed(Furniture.CF, function(Value)
			NewFurniture:PivotTo(Restaurant:GetPivot() * CFrame.new(table.unpack(Value:split(","))))
			if NewFurniture:GetAttribute("Type") == "Chairs" then
				local CF,Size = NewFurniture.Placement.CFrame,NewFurniture.Placement.Size
				local Parts = workspace:GetPartBoundsInBox(CF, Size - Vector3.one*0.2)
				for _,Part in pairs(Parts) do
					if Part.Name == "Placement" and Part:IsDescendantOf(Restaurant.Furniture.Tables) then
						if Part.Parent.Parent.Name == "Chairs" then
							if CF.LookVector:Dot(Part.CFrame.LookVector) > 0.99 and Size == Part.Size then
								Part.Parent.Chair.Value = NewFurniture
								Handler.onDestroy(NewFurniture, function()
									if not Part:IsDescendantOf(workspace) then return end
									Part.Parent.Chair.Value = nil
								end)
								break
							end
						end
					end
				end
			elseif NewFurniture:GetAttribute("Type") == "Tables" then
				for _,Chair in pairs(NewFurniture.Chairs:GetChildren()) do
					local CF,Size = Chair.Placement.CFrame,Chair.Placement.Size
					local Parts = workspace:GetPartBoundsInBox(CF, Size - Vector3.one*0.2)
					for _,Part in pairs(Parts) do
						if Part.Name == "Placement" and Part:IsDescendantOf(Restaurant.Furniture.Chairs) then
							if CF.LookVector:Dot(Part.CFrame.LookVector) > 0.99 and Size == Part.Size then
								Chair.Chair.Value = Part.Parent
								Handler.onDestroy(Part.Parent, function()
									if not Chair.Parent then return end
									Chair.Chair.Value = nil
								end)
								break
							end
						end
					end
				end
			end
		end)
		Handler.onDestroy(Furniture, NewFurniture)
	end)
	Handler.changed(Folder.Settings.Open, function(Value)
		for _,Neon in pairs(Restaurant.Model.Sign.Neon:GetChildren()) do
			local H = Neon.Color:ToHSV()
			Neon.Color = Color3.fromHSV(H,1,Value and 1 or 0.35)
		end
	end)
	Handler.changed(Folder.Settings.RestaurantName, function(Value)
		Restaurant.Model.RestaurantName.SurfaceGui.TextLabel.Text = Value
	end)
	--Handler.changed(Folder.GamePasses.MaxPopularity, function(Value)
	--	Data.Popularity = Value and 100 or 0
	--	DataAPI.UpdateData(Player)
	--end)
	Handler.changed(Folder.ActivePotions["Customer Rush"], function(Value)
		Data.Popularity = Value > 0 and 100 or 0
		DataAPI.UpdateData(Player)
	end)
	Handler.changed(Folder.ActivePotions["Speed Up"], function(Value)
		local Speed = Settings.Multiplier(Player, "NPCWalkSpeed")
		for _,NPC in pairs(Restaurant.NPCs:GetChildren()) do
			NPC.Humanoid.WalkSpeed = Speed
		end
		for _,NPC in pairs(Restaurant.Employees:GetChildren()) do
			NPC.Humanoid.WalkSpeed = Speed
		end
	end)
	--Handler.childAdded(Restaurant.Furniture.Trash, function(Trash)
	--	Trash.Trash.Touched:Connect(function(Part)
	--		if Part:IsDescendantOf(Restaurant.Trash) then
	--			Handler.destroy(Handler.findFirstAncestorOfChild(Part, Restaurant.Trash))
	--			Remotes.Parent.Handler.Audio:FireClient(Player, "Trash")
	--		elseif Part:IsDescendantOf(Restaurant.Ingredients) then
	--			local Model = Handler.findFirstAncestorOfChild(Part, Restaurant.Ingredients)
	--			Data.Foods[Model and Model.Name or ""] = nil
	--			Handler.destroy(Model)
	--			DataAPI.UpdateData(Player)
	--			Remotes.Parent.Handler.Audio:FireClient(Player, "Trash")
	--		end
	--	end)
	--end)
	Handler.childAdded(Restaurant.Furniture.CashRegisters, function(Register)
		PhysicsService:RegisterCollisionGroup(Register.Name)
		PhysicsService:CollisionGroupSetCollidable(Register.Name, Register.Name, false)
		for _,Descendant in pairs(Register:GetDescendants()) do
			if not Descendant:IsA("BasePart") then continue end
			Descendant.CollisionGroup = Register.Name
		end
	end)
	task.wait(1)

	local DELIVERY_TIME = 5

	local function RunTruckDelivery(CF)
		-- mhmmm lets make the truck do its stuff!!

		-- script: basically, im going to make the packages exist but invisible
		-- so that the rest of the game works (i.e onboarding)
		-- then, later on, they will be visible

		local vehicle = nil 
		local closestLane: string = ''

		if not activeTrucksByRestaurant[Restaurant] then 
			vehicle = game.ReplicatedStorage.DeliveryTruck:Clone()
			vehicle:SetAttribute('ForPlayer', Player.Name)
			activeTrucksByRestaurant[Restaurant] = vehicle

			-- get the closest lane to the restaurant 

			local distanceFromL1ToRestaurant = (workspace.VehicleSpawns:FindFirstChild('L1').Position - Restaurant:GetPivot().Position).Magnitude
			local distanceFromR2ToRestaurant = (workspace.VehicleSpawns:FindFirstChild('R2').Position - Restaurant:GetPivot().Position).Magnitude

			local closestSpawnPoint = nil

			if distanceFromL1ToRestaurant < distanceFromR2ToRestaurant then 
				-- left lane is closer to restaurant
				closestSpawnPoint = workspace.VehicleSpawns:FindFirstChild('L1')
				closestLane = 'L'
			elseif distanceFromR2ToRestaurant < distanceFromL1ToRestaurant then 
				-- right lane closer to restaurant
				closestSpawnPoint = workspace.VehicleSpawns:FindFirstChild('R1')
				closestLane = 'R'
			end

			vehicle.Parent = workspace
			vehicle:PivotTo(closestSpawnPoint.CFrame * CFrame.new(0, -1, 0))
			vehicle:SetAttribute('Status', 'Began')

			for _, v in next, vehicle:GetDescendants() do 
				pcall(function()
					v.CollisionGroup = "Players"
				end)
			end

			local vehicleCF = vehicle:GetPivot()

			local laneDir = (workspace.VehicleSpawns:FindFirstChild(`{closestLane}1`).Position - workspace.VehicleSpawns:FindFirstChild(`{closestLane}2`).Position).Unit

			-- positions you already know
			local orangePos = CF.Position -- Vector3.new(...)
			local bluePos   = closestSpawnPoint.Position -- Vector3.new(...), on the road

			-- vector from blue → orange
			local toOrange  = orangePos - bluePos

			-- scalar projection length (dot product)
			local t         = toOrange:Dot(laneDir)

			-- closest point on the infinite line
			local pinkPos   = bluePos + laneDir * t

			Tween(DELIVERY_TIME, 'easeOutCubic', function(a)
				vehicle:PivotTo(vehicleCF:Lerp(CFrame.new(pinkPos, vehicleCF.Position + vehicleCF.LookVector * 10000), a))
			end)

			Remotes.Parent.Handler.Audio:FireClient(Player, "PackagesArrived")
			Remotes.Parent.Handler.Audio:FireClient(Player, "TruckHorn")
			Remotes.Parent.Handler.Notify:FireClient(Player, "Packages have arrived out front!", "Green")
		end

		-- vehicle go away 

		task.delay(2, function()
			if vehicle then 
				local vehicleCF = vehicle:GetPivot()
				local endCFrame = workspace.VehicleSpawns:FindFirstChild(`{closestLane}2`).CFrame

				Tween(5, 'easeInCubic', function(a)
					vehicle:PivotTo(vehicleCF:Lerp(endCFrame, a))
				end)

				pcall(function()
					vehicle:Destroy()
				end)

				activeTrucksByRestaurant[Restaurant] = nil 
			end
		end)
	end

	Handler.childAdded(Folder.Packages, function(Package)
		if Package.Item.Value == nil then 
			return
		end

		warn("Package")
		print(Package.Item.Value)

		local PackageModel = Assets.Packages:FindFirstChild("Furniture Box")
		if Package.Category.Value == "Food" then
			PackageModel = Assets.Packages:FindFirstChild(Package.Item.Value)
		elseif GameplayAPI.Items[Package.Category.Value][Package.Item.Value].GamePass then
			PackageModel.Box.Material   = Enum.Material.Metal
			PackageModel.Box.BrickColor = BrickColor.new("Gold")
		end

		if not PackageModel then
			warn("No package for: " .. Package.Item.Value)
			if Assets.Ingredients:FindFirstChild(Package.Item.Value) then
				Data.Packages[Package.Name] = nil
				Data.Foods[Package.Name] = {
					CF     = Package.CF.Value,
					Amount = GameplayAPI.Items.Food[Package.Item.Value].Unit,
					Item   = Package.Item.Value,
				}
				DataAPI.UpdateData(Player)
			end
			return
		end

		-- position inside restaurant bounds
		local TargetCF = CFrame.new(table.unpack(Package.CF.Value:split(",")))
		local S, P     = Restaurant.PrimaryPart.Size, TargetCF.Position
		local Clamped  = Vector3.new(
			math.clamp(P.X, -S.X/2, S.X/2),
			math.clamp(P.Y,     0,    50),
			math.clamp(P.Z, -S.Z/2, S.Z/2)
		)
		local CF       = Restaurant:GetPivot() * (TargetCF - TargetCF.Position + Clamped)

		-- clone model + hide everything
		local NewPackage             = PackageModel:Clone()
		NewPackage.Name              = Package.Name

		local transparencyByDescendant = {}
		local enabledByDescendant = {}
		for _, d in ipairs(NewPackage:GetDescendants()) do
			if d:IsA("TextLabel") and Package.Category.Value ~= "Food" then
				d.Text = Package.Item.Value
			elseif (d:IsA("BasePart") or d:IsA("MeshPart")) and d.Transparency < 1 then
				transparencyByDescendant[d] = d.Transparency
				d.Transparency = 1
			elseif d:IsA("SurfaceGui") then 
				enabledByDescendant[d] = d.Enabled
				d.Enabled = false  
			end
		end

		NewPackage.Parent = Restaurant.Packages
		NewPackage:PivotTo(CF)
		NewPackage.Drag:SetNetworkOwner(nil)
		Handler.onDestroy(Package, NewPackage)

		-- wait until player is not loading anymore

		-- start the truck and SCHEDULE reveal after it arrives

		if Player:GetAttribute("FinishedLoading") then
			warn("Running truck delivery for PACKAGE:")
			print(Package.Item.Value)
			task.delay(DELIVERY_TIME, function()
				for part, oldTrans in pairs(transparencyByDescendant) do
					if part and part.Parent then
						part.Transparency = oldTrans
					end
				end
				for part, e in pairs(enabledByDescendant) do
					if part and part.Parent then
						part.Enabled = e
					end
				end
			end)
			RunTruckDelivery(CF)

		else 
			for part, oldTrans in pairs(transparencyByDescendant) do
				if part and part.Parent then
					part.Transparency = oldTrans
				end
			end
			for part, e in pairs(enabledByDescendant) do
				if part and part.Parent then
					part.Enabled = e
				end
			end
		end
	end)

	--  FOODS
	task.wait(1)  

	Handler.childAdded(Folder.Foods, function(Food)
		local FoodModel = Assets.Ingredients:FindFirstChild(Food.Item.Value)
		if not FoodModel then
			warn("No ingredients for: " .. Food.Item.Value)
			return
		end

		-- clone model + hide everything
		local NewFood = FoodModel:Clone()
		NewFood.Name  = Food.Name
		NewFood.Parent = Restaurant.Ingredients

		local CF = Restaurant:GetPivot() * CFrame.new(table.unpack(Food.CF.Value:split(",")))
		NewFood:PivotTo(CF)
		NewFood.Drag:SetNetworkOwner(nil)

		local transparencyByDescendant = {}
		for _, d in ipairs(NewFood:GetDescendants()) do
			if (d:IsA("BasePart") or d:IsA("MeshPart")) then
				transparencyByDescendant[d] = d.Transparency
				d.Transparency = 1
			end
		end

		-- script: when packages are opened, they turn into foods
		-- thus, this function gets executed and thats not good 
		-- so ill just simulate it :L

		if Player:GetAttribute("FinishedLoading") then
			--RunTruckDelivery(CF)
			local d = 0 
			if activeTrucksByRestaurant[Restaurant] then 
				d = DELIVERY_TIME
			end
			task.delay(d, function()
				warn("Reverting old transparency now")
				for part, oldTrans in pairs(transparencyByDescendant) do
					if part and part.Parent then
						part.Transparency = oldTrans
					end
				end
			end)
		else 
			for part, oldTrans in pairs(transparencyByDescendant) do
				if part and part.Parent then
					part.Transparency = oldTrans
				end
			end
		end

		-- set up food amount visibility handling
		Handler.changed(Food.Amount, function(Value)
			for _, child in ipairs(NewFood:GetChildren()) do
				local num = tonumber(child.Name)
				if num then
					if num > Value then
						Handler.invisible(child)
					else
						Handler.visible(child)
					end
				end
			end
		end)

		Handler.onDestroy(Food, NewFood)
	end)
	Handler.childAdded(Restaurant.Trash, function(Trash)
		if not Trash.Parent or not Trash:FindFirstChild("Drag") then return end
		Trash.Drag:SetNetworkOwner(nil)
	end)
	task.wait(1)
	local CurrentMissingIngredients = {}
	Handler.childAdded(Folder.NPCs, function(Employee)
		local Type = Employee.Type.Value
		local Character = script.Employees[Type][Employee.Gender.Value]:Clone()
		local HRP,Humanoid = Character.HumanoidRootPart,Character.Humanoid
		Animate:Clone().Parent = Character
		Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		Humanoid.WalkSpeed = Settings.Multiplier(Player, "NPCWalkSpeed")
		Character.Parent = Restaurant.Employees
		HRP.CFrame = Restaurant.Spawn.CFrame * CFrame.new(0,3,0)
		Handler.onDestroy(Employee, Character)
		local ChatDebounce = false
		local function ChatBubble(Text)
			if ChatDebounce then return end
			ChatDebounce = true
			task.delay(10, function()
				ChatDebounce = false
			end)
			Chat:Chat(HRP, Text, Enum.ChatColor.White)
			Remotes.Parent.Handler.Notify:FireClient(Player, Text, "Red")
		end
		local function FindIngredient(TargetItem)
			local Ingredient
			for Name,Food in pairs(Data.Foods) do
				local Item = Food.Item
				if Item ~= TargetItem then continue end
				Ingredient = TakeIngredient(Player, Restaurant.Ingredients[Name], true)
				break
			end
			if Ingredient then
				CurrentMissingIngredients[TargetItem] = nil
			elseif not CurrentMissingIngredients[TargetItem] then
				CurrentMissingIngredients[TargetItem] = ""
				ChatBubble("I need "..TargetItem.."!")
			end
			return Ingredient
		end
		local Using
		while Restaurant.Parent and Character and Character.Parent do
			if Type == "Cashier" then
				if not Using or not Using:IsDescendantOf(workspace) then
					Using = nil
					for _,Register in pairs(Restaurant.Furniture.CashRegisters:GetChildren()) do
						if Register:GetAttribute("Using") then continue end
						Register:SetAttribute("Using", true)
						local CF = Register:GetPivot() * CFrame.new(0,3,-4) * CFrame.Angles(0,math.rad(180),0)
						WalkTo(Restaurant, Character, CF, true, true)
						Using = Register
						break
					end
				end
				if Using then
					Using.EmployeeTakeOrder:Fire()
				else
					ChatBubble("I need an empty Cash Register!")
				end
			--[[elseif Type == "Janitor" then
				for _, Trash in Restaurant.DirtyTrays:GetChildren() do
					local CF = Trash:GetPivot() * CFrame.new(0,3,4) * CFrame.Angles(0,math.rad(0),0)
					WalkTo(Restaurant, Character, CF, true, true)
					
					Trash:Destroy()
				end]]
			elseif Type == "Fry" then
				if not Using or not Using:IsDescendantOf(workspace) then
					Using = nil
					for _,Fryer in pairs(Restaurant.Furniture.Fryer:GetChildren()) do
						if Fryer:GetAttribute("Using") then continue end
						Fryer:SetAttribute("Using", true)
						local CF = Fryer:GetPivot() * CFrame.new(0,3,4) * CFrame.Angles(0,math.rad(0),0)
						WalkTo(Restaurant, Character, CF, true, true)
						Using = Fryer
						break
					end
				end
				local FoodMatchup = {
					["Nuggets"] = {"Nugget-Box", "Nugget-Pack"},
					["Fries"] = {"Fry-Pack", "Fry-Box"},
					["Onion Rings"] = {"Onion Ring Pack", "Onion Ring Tray"},
				}
				if Using then
					for _,Tray in pairs(Restaurant.Trash:GetChildren()) do
						if Tray.Name ~= "Tray" then continue end
						for _,FoodLeft in pairs(Tray.FoodsLeft:GetChildren()) do
							if FoodLeft.Name ~= "Nuggets" and FoodLeft.Name ~= "Fries" and FoodLeft.Name ~= "Onion Rings" then continue end
							if FoodLeft:GetAttribute("Occupied") then continue end
							for _,Snap in pairs(Using:GetDescendants()) do
								if not Snap:HasTag("Snap") or Snap["Raw Fries"]:GetAttribute("Occupied") then continue end
								local Ingredient = FindIngredient(FoodMatchup[FoodLeft.Name][1])
								if Ingredient then
									FoodLeft:SetAttribute("Occupied", true)
									local FinishedIngredient = SnapIngredient(Player, Ingredient, Snap, true)
									local Ingredient = FindIngredient(FoodMatchup[FoodLeft.Name][2])
									if Ingredient then
										SnapIngredient(Player, FinishedIngredient, Ingredient.Part, true)
										SnapIngredient(Player, Ingredient, Tray.Snap, true)
									end
								end
								break
							end
						end
					end
				else
					ChatBubble("I need an empty Fryer!")
				end
			elseif Type == "Grill" then
				if not Using or not Using:IsDescendantOf(workspace) then
					Using = nil
					for _,Cooktop in pairs(Restaurant.Furniture.Cooktop:GetChildren()) do
						if Cooktop:GetAttribute("Using") then continue end
						Cooktop:SetAttribute("Using", true)
						local CF = Cooktop:GetPivot() * CFrame.new(0,3,4) * CFrame.Angles(0,math.rad(0),0)
						WalkTo(Restaurant, Character, CF, true, true)
						Using = Cooktop
						break
					end
				end
				local FoodMatchup = {
					["Lettuce"] = "Lettuce",
					["Onion"] = "Onions",
					["Cheese"] = "Cheese Slices",
					["Tomato"] = "Tomatoes",
					["Pickle"] = "Pickles",
				}
				if Using then
					for _,Tray in pairs(Restaurant.Trash:GetChildren()) do
						if Tray.Name ~= "Tray" then continue end
						for _,FoodLeft in pairs(Tray.FoodsLeft:GetChildren()) do
							if FoodLeft.Name ~= "Burger" then continue end
							if FoodLeft:GetAttribute("Occupied") then continue end
							for _,Snap in pairs(Using:GetChildren()) do
								if not Snap:HasTag("Snap") or Snap["Raw Patty"]:GetAttribute("Occupied") then continue end
								local Patty = FindIngredient("Patties")
								if Patty then
									FoodLeft:SetAttribute("Occupied", true)
									local CookedPatty = SnapIngredient(Player, Patty, Snap, true)
									local Paper = FindIngredient("Papers")
									if Paper then
										local Bun = FindIngredient("Burger Buns")
										if Bun then
											SnapIngredient(Player, Bun, Paper.Part, true)
											SnapIngredient(Player, CookedPatty, Paper.Part, true)
											local MissingIngredient = false
											for _,FoodIngredient in pairs(FoodLeft:GetChildren()) do
												if FoodIngredient.Name == "Burger Bun" or FoodIngredient.Name == "Cooked Patty" then continue end
												local Ingredient = FindIngredient(FoodMatchup[FoodIngredient.Name])
												if Ingredient then
													SnapIngredient(Player, Ingredient, Paper.Part, true)
												else
													MissingIngredient = true
												end
											end
											if not MissingIngredient then
												Paper.Part["Cooked Patty"].EmployeeWrap:Fire()
											end
											SnapIngredient(Player, Paper, Tray.Snap, true)
										end
									end
								end
								break
							end
						end
					end
				else
					ChatBubble("I need an empty Cooktop!")
				end
			elseif Type == "Server" then
				if not Using or not Using:IsDescendantOf(workspace) then
					Using = nil
					for _,Tray in pairs(Restaurant.Trash:GetChildren()) do
						if Tray.Name ~= "Tray" or #Tray.FoodsLeft:GetChildren() > 0 then continue end
						if Tray:GetAttribute("Occupied") then continue end
						Tray:SetAttribute("Occupied", true)
						local CF = Tray.TrayHitbox.Value:GetPivot() * CFrame.new(0,3,4) * CFrame.Angles(0,math.rad(0),0)
						WalkTo(Restaurant, Character, CF, true, true)
						Using = Tray
						break
					end
				end
				if Using then
					Using.Drag.CFrame = Using.TrayHitbox.Value.CFrame * CFrame.new(0,Using.Drag.Size.Y/2,0)
				else
					ChatBubble("I need a completed Tray!")
				end
			end
			DataAPI.UpdateData(Player)
			task.wait(1)
		end
	end)
end)

Handler.playerRemovingFunction(function(Player)
	local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
	if not Restaurant then return end
	local NewRestaurant = SampleRestaurant:Clone()
	NewRestaurant:PivotTo(Restaurant:GetPivot())
	NewRestaurant.Parent = Restaurants
end)

-----< Expansion

Remotes.BuyExpansion.OnServerEvent:Connect(function(Player)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local ExpansionInfo = GameplayAPI.Expansions[Data.Expansions + 1]
	if not ExpansionInfo then return end
	if Data.Cash < ExpansionInfo.Price or GameplayAPI.XPToLevel(Data.XP) < ExpansionInfo.Lvl then return end
	Data.Cash -= ExpansionInfo.Price
	Data.Expansions += 1
	DataAPI.UpdateData(Player)
end)

Remotes.RobuxExpansion.OnServerEvent:Connect(function(Player, Expansion)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	if Data.Expansions + 1 ~= Expansion then
		Remotes.Parent.Handler.Notify:FireClient(
			Player, "This expansion is locked! Buy the next one", "Red"
		)
		return
	end
	game.MarketplaceService:PromptProductPurchase(Player, 3289954104)
	game.ReplicatedStorage.Remotes.Store.StartRobux:FireClient(Player)
end)

WillsAPI.DevProducts.NewExpansion:Connect(function(Player)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local ExpansionInfo = GameplayAPI.Expansions[Data.Expansions + 1]
	if not ExpansionInfo then return end
	Data.Expansions += 1
	DataAPI.UpdateData(Player)
end)

-----< Open package

Remotes.OpenPackage.OnServerEvent:Connect(function(Player, Package)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local Restaurant = LastParentModel(Package)
	if not Restaurant then return end
	if Restaurant.Name ~= Player.Name then
		if not Restaurant.Whitelist:FindFirstChild(Player.Name) then
			Remotes.Parent.Handler.Notify:FireClient(Player, "Not whitelisted!", "Red")
		end
	end
	if not Package or Package.Parent ~= Restaurant.Packages then return end
	local Item = Data.Packages[Package.Name].Item
	Data.Packages[Package.Name] = nil
	Data.Foods[Package.Name] = {
		CF = tostring(Restaurant:GetPivot():ToObjectSpace(Package.Drag.CFrame)),
		Amount = GameplayAPI.Items.Food[Item].Unit,
		Item = Item,
		FromPackage = true,
	}
	DataAPI.UpdateData(Player)
end)

-----< Sell package

Remotes.SellPackage.OnServerEvent:Connect(function(Player, Package)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
	if not Restaurant or not Package or Package.Parent ~= Restaurant.Packages then return end
	local ItemInfo = GameplayAPI.Items[Data.Packages[Package.Name].Category][Data.Packages[Package.Name].Item]
	Data.Cash += ItemInfo.Unit*ItemInfo.UnitPrice/2
	Data.Packages[Package.Name] = nil
	DataAPI.UpdateData(Player)
end)

Remotes.TrashItem.OnServerEvent:Connect(function(Player, Item)
	if not Item then return end
	local Restaurant = Item.Parent.Parent
	if Restaurant.Parent ~= OwnedRestaurants then return end
	local Data = DataAPI.Data(Players:FindFirstChild(Restaurant.Name))
	if not Data then return end
	if not Restaurant.Whitelist:FindFirstChild(Player.Name) then return end
	if Item.Parent == Restaurant.Trash then
		Handler.destroy(Item)
		Remotes.Parent.Handler.Audio:FireClient(Player, "Trash")
	elseif Item.Parent == Restaurant.Ingredients then
		Data.Foods[Item and Item.Name or ""] = nil
		Handler.destroy(Item)
		DataAPI.UpdateData(Player)
		Remotes.Parent.Handler.Audio:FireClient(Player, "Trash")
	end
end)

-----< Ingredients

for _,Ingredient in pairs(Assets.Food:GetChildren()) do
	local Drag = Instance.new("Part")
	local CF,Size = Ingredient:GetBoundingBox()
	Drag.Size = Size
	Drag.CFrame = CF
	Drag.CanCollide = false
	Drag.CanQuery = false
	Drag.CanTouch = false
	Drag.Transparency = 1
	Drag.Parent = Ingredient
	Drag.Name = "Drag"
	local Padding = Drag:Clone()
	Padding.Size = Size * Vector3.new(1,0,1) + Vector3.new(0,0.1,0)
	Padding.CFrame *= CFrame.new(0,-Drag.Size.Y/2-0.05,0)
	Padding.Name = "Padding"
	Padding.CanCollide = true
	Padding.Parent = Ingredient
	Ingredient.PrimaryPart = Drag
	for _,Descendant in pairs(Ingredient:GetDescendants()) do
		if not Descendant:IsA("BasePart") then continue end
		Descendant.CollisionGroup = "Ingredients"
		Descendant.Anchored = false--Descendant == Drag
		local Weld = Instance.new("Weld")
		Weld.C0 = Drag.CFrame:ToObjectSpace(Descendant.CFrame)
		Weld.Part0 = Drag
		Weld.Part1 = Descendant
		Weld.Parent = Descendant
	end
	local Ingredients = Handler.create("Folder", Ingredient, "Ingredients")
	Handler.create("StringValue", Ingredients, Ingredient.Name, "")
end

for _,Ingredient in pairs(Assets.Ingredients:GetChildren()) do
	local Drag = Instance.new("Part")
	local CF,Size = Ingredient:GetBoundingBox()
	Instance.new("Attachment", Drag)
	Drag.Size = Size
	Drag.CFrame = CF
	Drag.CanCollide = false
	Drag.CanQuery = false
	Drag.CanTouch = false
	Drag.Transparency = 1
	Drag.Parent = Ingredient
	Drag.Name = "Drag"
	Ingredient.PrimaryPart = Drag
	for _,Descendant in pairs(Ingredient:GetDescendants()) do
		if not Descendant:IsA("BasePart") then continue end
		Descendant.CollisionGroup = "Ingredients"
		Descendant.Anchored = false--Descendant == Drag
		local Weld = Instance.new("Weld")
		Weld.C0 = Drag.CFrame:ToObjectSpace(Descendant.CFrame)
		Weld.Part0 = Drag
		Weld.Part1 = Descendant
		Weld.Parent = Descendant
	end
end

for _,Ingredient in pairs(Assets.Packages:GetChildren()) do
	local Drag = Instance.new("Part")
	local CF,Size = Ingredient:GetBoundingBox()
	Instance.new("Attachment", Drag)
	Drag.Size = Size
	Drag.CFrame = CF
	Drag.CanCollide = false
	Drag.CanQuery = false
	Drag.CanTouch = false
	Drag.Transparency = 1
	Drag.Parent = Ingredient
	Drag.Name = "Drag"
	Ingredient.PrimaryPart = Drag
	for _,Descendant in pairs(Ingredient:GetDescendants()) do
		if not Descendant:IsA("BasePart") then continue end
		Descendant.CollisionGroup = "Ingredients"
		Descendant.Anchored = false
		local Weld = Instance.new("Weld")
		Weld.C0 = Drag.CFrame:ToObjectSpace(Descendant.CFrame)
		Weld.Part0 = Drag
		Weld.Part1 = Descendant
		Weld.Parent = Descendant
	end
end

function TakeIngredient(Player, Food, Employee)
	if not Food or not Food.Parent or not Food.Parent.Parent then return end
	local Restaurant = Food.Parent.Parent
	if Restaurant.Parent ~= OwnedRestaurants then return end
	local Data = DataAPI.Data(Players:FindFirstChild(Restaurant.Name))
	if not Data then return end
	if Food.Parent ~= Restaurant.Ingredients then return end
	if not Restaurant.Whitelist:FindFirstChild(Player.Name) then return end
	local Item = GameplayAPI.Items.Food[Data.Foods[Food.Name].Item].Food
	local Ingredient = Assets.Food[Item]:Clone()
	Ingredient:PivotTo(Food:GetPivot())
	Ingredient.Parent = Restaurant.Trash
	Data.Foods[Food.Name].Amount -= 1
	if not Employee then
		Remotes.Parent.Handler.Audio:FireClient(Player, Food:FindFirstChild("Bag") and "PickUpBag" or "PickUp2")
		if Data.Foods[Food.Name].Amount > 0 or Food:FindFirstChild("Bag") then
			Remotes.DragItem:FireClient(Player, Ingredient, Item)
		end
	end
	if Data.Foods[Food.Name].Amount <= 0 then
		Data.Foods[Food.Name] = nil
	elseif not Food:FindFirstChild("Bag") and Data.Foods[Food.Name].Amount == 1 then
		TakeIngredient(Player, Food, Employee)
	end
	DataAPI.UpdateData(Player)
	return Ingredient
end

Remotes.TakeIngredient.OnServerEvent:Connect(TakeIngredient)
Remotes.PickUpItem.OnServerEvent:Connect(function(Player, Item)
	local Restaurant = Handler.findFirstAncestorOfChild(Item, OwnedRestaurants)
	if not Restaurant or not Restaurant.Whitelist:FindFirstChild(Player.Name) then return end
	Remotes.PickUpItem:FireAllClients(Player, Item)
end)

function SnapIngredient(Player, Ingredient, Snap, Employee)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local Restaurant = LastParentModel(Snap)
	print(Restaurant)
	if not Restaurant then return end
	if Restaurant.Name ~= Player.Name then
		if not Restaurant.Whitelist:FindFirstChild(Player.Name) then
			Remotes.Parent.Handler.Notify:FireClient(
				Player, "Not whitelisted!", "Red"
			)
		end
	end
	if not Ingredient or not Ingredient:IsDescendantOf(Restaurant) then return end
	if not Snap or not Snap:HasTag("Snap") or not Snap:IsDescendantOf(Restaurant) then return end
	local Snappable = Snap:FindFirstChild(Ingredient.Name)
	if not Snappable or Snappable:GetAttribute("Occupied") then return end
	local Requirement = Snappable:GetAttribute("Requirement")
	if Requirement and not Snap.Parent.Ingredients:FindFirstChild(Requirement) then return end
	if Snap.Parent.Name == "Tray" then
		local Found = Snap.Parent.FoodsLeft:FindFirstChild(Ingredient.Name)
		if Found then
			local Ingredients = Ingredient.Ingredients:GetChildren()
			local IngredientsLeft = Snap.Parent.FoodsLeft[Ingredient.Name]:GetChildren()
			local IngredientsFound = 0
			for _,IngredientLeft in pairs(IngredientsLeft) do
				for _,Ingredient in pairs(Ingredients) do
					if Ingredient.Name ~= IngredientLeft.Value then continue end
					IngredientsFound += 1
					table.remove(Ingredients, table.find(Ingredients, Ingredient))
					break
				end
			end
			if #Ingredients > 0 or IngredientsFound < #IngredientsLeft then return end
		else
			return
		end
		Found:Destroy()
	end
	local Ingredients = Ingredient.Ingredients:GetChildren()
	Snappable:SetAttribute("Occupied", true)
	Handler.visible(Snappable)
	Ingredient:Destroy()
	local Time = Snappable:GetAttribute("Time")
	if Time then
		Time *= Settings.Multiplier(Player, "WorkerSpeed")
		if Snappable.Name == "Raw Patty" then
			Snap.Cooktop:Play()
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play()
			Handler.tween(Snappable.Patty, {Time, "Linear"}, {Color = Color3.fromRGB(141, 65, 54)}):Play()
			task.wait(Time)
			if not Employee then
				Snappable.Flip.OnServerEvent:Wait()
			end
			Handler.tween(Snappable.Timer, {0}, {Value = 0}):Play()
			Handler.tween(Snappable.Patty, {0}, {Color = Color3.fromRGB(255, 89, 89)}):Play()
			local Flipped = Snap["Flipped Raw Patty"]
			local FlipTime = Flipped:GetAttribute("Time") * Settings.Multiplier(Player, "WorkerSpeed")
			Flipped:SetAttribute("Occupied", true)
			Handler.visible(Flipped)
			Handler.invisible(Snappable)
			Handler.tween(Flipped.Patty, {0.1, "Linear"}, {CFrame = Flipped:GetPivot()*CFrame.Angles(math.rad(90),0,0)}):Play()
			Handler.tween(Flipped.Timer, {FlipTime, "Linear"}, {Value = 100}):Play()
			Handler.tween(Flipped.Patty, {Time, "Linear"}, {Color = Color3.fromRGB(80, 42, 7)}):Play()
			task.wait(FlipTime)
			Snap.Cooktop:Stop()
			Handler.invisible(Flipped)
			Handler.tween(Flipped.Patty, {0}, {CFrame = Flipped:GetPivot()}):Play()
			Handler.tween(Flipped.Timer, {0}, {Value = 0}):Play()
			Handler.tween(Snappable.Patty, {0}, {Color = Color3.fromRGB(141, 65, 54)}):Play()
			local Ingredient = Assets.Food["Cooked Patty"]:Clone()
			Ingredient:PivotTo(CFrame.new(Flipped:GetPivot().Position))
			Ingredient.Parent = Restaurant.Trash
			Snappable:SetAttribute("Occupied", false)
			Flipped:SetAttribute("Occupied", false)
			if Employee then
				return Ingredient
			end
		elseif Snappable.Name == "Empty Soda" then
			Snappable.SelectingFlavor.Value = true
			local EventPlayer,Flavor = Snappable.SelectFlavor.OnServerEvent:Wait()
			Snappable.SelectingFlavor.Value = false
			Flavor = Snap.Parent.Flavors:FindFirstChild(Flavor or "") or Snap.Parent.Flavors.Water
			local Original = Assets.Furniture["Drink Dispenser"]
			local DrinkCF = Flavor:GetPivot():ToWorldSpace(Original.Flavors.Water:GetPivot():ToObjectSpace(Original.Part.CFrame))
			for _,Descendant in pairs(Snap:GetDescendants()) do
				if not Descendant:IsA("BasePart") then continue end
				local Offset = Original.Part.CFrame:ToObjectSpace(Original.Part:FindFirstChild(Descendant.Name, true).CFrame)
				Handler.tween(Descendant, {0.2, "Linear"}, {CFrame = DrinkCF * Offset}):Play()
			end
			task.wait(0.25)
			local Color = Flavor:GetAttribute("DrinkColor")
			Snappable.PouringStart.Color = Color
			Snappable.FillStart.Color = Color
			local FillClone = Snappable.FillStart:Clone()
			FillClone.Parent = Snappable
			FillClone.Transparency = 0
			local PourClone = Snappable.PouringStart:Clone()
			PourClone.Parent = Snappable
			PourClone.Transparency = 0
			Snap.DrinkFill:Play()
			Handler.tween(PourClone, {0.1, "Linear"}, {Size = Snappable.PouringEnd.Size, CFrame = Snappable.PouringEnd.CFrame}):Play()
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play()
			Handler.tween(FillClone, {Time, "Linear"}, {Size = Snappable.FillEnd.Size, CFrame = Snappable.FillEnd.CFrame}):Play()
			task.wait(Time)
			Snap.DrinkFill:Stop()
			Handler.tween(PourClone, {0.1, "Linear"}, {Size = Snappable.PouringStart.Size, CFrame = Snappable.PouringStart.CFrame}):Play()
			task.delay(0.1, function()
				PourClone.Transparency = 1
			end)
			if not Employee then
				Snappable.Finish.OnServerEvent:Wait()
			end
			Handler.tween(Snappable.Timer, {0}, {Value = 0}):Play()
			local Ingredient = Assets.Food["Large Soda"]:Clone()
			Ingredient:PivotTo(Snappable.Base:GetPivot())
			Ingredient.Name = "Large "..Flavor.Name
			Ingredient.DrinkColor.Color = Color
			Ingredient.Ingredients["Large Soda"].Name = "Large "..Flavor.Name
			Ingredient.Parent = Restaurant.Trash
			FillClone:Destroy()
			PourClone:Destroy()
			Handler.invisible(Snappable)
			Snappable:SetAttribute("Occupied", false)
		elseif Snappable.Name == "Ice Cream Cone" then
			Snappable.SelectingFlavor.Value = true
			local Player,Flavor = Snappable.SelectFlavor.OnServerEvent:Wait()
			Snappable.SelectingFlavor.Value = false
			Flavor = Snap.Parent.Flavors:FindFirstChild(Flavor or "") or Snap.Parent.Flavors.Vanilla
			local Original = Assets.Furniture["Icecream & Milkshake Maker"]
			local DrinkCF = Flavor:GetPivot():ToWorldSpace(Original.Flavors.Vanilla:GetPivot():ToObjectSpace(Original.IceCream.CFrame))
			for _,Descendant in pairs(Snap:GetDescendants()) do
				if not Descendant:IsA("BasePart") then continue end
				local Offset = Original.IceCream.CFrame:ToObjectSpace(Original.IceCream:FindFirstChild(Descendant.Name, true).CFrame)
				Handler.tween(Descendant, {0.2, "Linear"}, {CFrame = DrinkCF * Offset}):Play()
			end
			task.wait(0.25)
			local Color = Flavor:GetAttribute("IceCreamColor")
			Snappable.FillStart.Color = Color
			local FillClone = Snappable.FillStart:Clone()
			FillClone.Parent = Snappable
			FillClone.Transparency = 0
			--Snap.IceCreamFilling:Play()
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play()
			Handler.tween(FillClone, {Time, "Linear"}, {Size = Snappable.FillEnd.Size, CFrame = Snappable.FillEnd.CFrame}):Play()
			task.wait(Time)
			Handler.tween(Snappable.Timer, {0}, {Value = 0}):Play()
			local Ingredient = Assets.Food["Ice Cream"]:Clone()
			Ingredient:PivotTo(Snappable.Base:GetPivot())
			Ingredient.Name = Flavor.Name.." Ice Cream"
			Ingredient.IceCreamColor.Color = Color
			Ingredient.Ingredients["Ice Cream"].Name = Flavor.Name.." Ice Cream"
			Ingredient.Parent = Restaurant.Trash
			FillClone:Destroy()
			Handler.invisible(Snappable)
			Snappable:SetAttribute("Occupied", false)
		elseif Snappable.Name == "Milkshake Cup" then
			Snappable.CanStart.Value = true
			if not Employee then
				Snappable.Start.OnServerEvent:Wait()
			end
			Snappable.CanStart.Value = false
			local Flavor = "Vanilla"
			local Color = Color3.fromRGB(255,255,255)
			Snappable.FillStart.Color = Color
			local FillClone = Snappable.FillStart:Clone()
			FillClone.Parent = Snappable
			FillClone.Transparency = 0
			local Mixer = Snap.Parent.Mixer
			Snap.Milkshake:Play()
			Handler.tween(Mixer, {0.5, "Linear"}, {CFrame = Snap.Parent.MixerEnd.CFrame}):Play()
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play()
			Handler.tween(FillClone, {Time, "Linear"}, {Size = Snappable.FillEnd.Size, CFrame = Snappable.FillEnd.CFrame}):Play()
			task.wait(Time)
			Handler.tween(Mixer, {0.5, "Linear"}, {CFrame = Snap.Parent.MixerStart.CFrame}):Play()
			if not Employee then
				Snappable.Finish.OnServerEvent:Wait()
			end
			Snap.Milkshake:Stop()
			Handler.tween(Snappable.Timer, {0}, {Value = 0}):Play()
			local Ingredient = Assets.Food["Milkshake"]:Clone()
			Ingredient:PivotTo(Snappable.Base:GetPivot())
			Ingredient.Name = Flavor.." Milkshake"
			Ingredient.MilkColor.Color = Color
			Ingredient.Ingredients["Milkshake"].Name = Flavor.." Milkshake"
			Ingredient.Parent = Restaurant.Trash
			FillClone:Destroy()
			Handler.invisible(Snappable)
			Snappable:SetAttribute("Occupied", false)
		elseif Snappable.Name == "Raw Nuggets" or Snappable.Name == "Raw Onion Rings" or Snappable.Name == "Raw Fries" then
			Snap.Frying:Play()
			Handler.invisible(Snap.Parent.Model)
			local Original = Assets.Furniture["Fryer"]
			local Parent = Original[Snap.Parent.Name]
			for _,Descendant in pairs(Snap:GetDescendants()) do
				if not Descendant:IsA("BasePart") then continue end
				Handler.tween(Descendant, {0.4, "Linear"}, {CFrame = Descendant.CFrame - Vector3.new(0,0.9,0)}):Play()
			end
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play()
			task.wait(Time)
			for _,Descendant in pairs(Snap:GetDescendants()) do
				if not Descendant:IsA("BasePart") then continue end
				local Offset = Parent.Part.CFrame:ToObjectSpace(Parent.Part:FindFirstChild(Descendant.Name, true).CFrame)
				Handler.tween(Descendant, {0.4, "Linear"}, {CFrame = Descendant.CFrame + Vector3.new(0,0.9,0)}):Play()
			end
			Snap.Frying:Stop()
			task.wait(0.5)
			Handler.tween(Snappable.Timer, {0}, {Value = 0}):Play()
			local Ingredient = Assets.Food[Snappable.Name:gsub("Raw ", "Cooked ")]:Clone()
			Ingredient:PivotTo(Snappable:GetPivot())
			Ingredient.Parent = Restaurant.Trash
			Handler.invisible(Snappable)
			Handler.visible(Snap.Parent.Model)
			Snappable:SetAttribute("Occupied", false)
			if Employee then
				return Ingredient
			end
		else
			Handler.tween(Snappable.Timer, {Time, "Linear"}, {Value = 100}):Play()
			task.wait(Time)
			Handler.invisible(Snappable)
			Snappable:SetAttribute("Occupied", false)
		end
	else
		for _,Ingredient in pairs(Ingredients) do
			Handler.create("StringValue", Snap.Parent.Ingredients, Ingredient.Name, "")
		end
		if Snap.Parent.Name == "Tray" then
			Handler.destroy(Snap.Parent.Ingredients:FindFirstChild("Tray"))
		elseif Snappable.Name == "Cooked Patty" then
			Snappable.Finished.Value = true
			task.spawn(function()
				if Employee then
					Snappable.EmployeeWrap.Event:Wait()
				else
					Snappable.Wrap.OnServerEvent:Wait()
				end
				if not Snap or not Snap.Parent then return end
				Snap.Parent:SetAttribute("Wrapped", true)
				for _,Food in pairs(Snap:GetChildren()) do
					Handler.invisible(Food)
				end
				Handler.invisible(Snap.Parent.Paper)
				Handler.visible(Snap["Wrapped Burger"])
				Snappable.Finished.Value = false
			end)
		elseif Snappable.Name == "Burger Bun" then
			Snap.Parent.Ingredients["Paper"]:Destroy()
			Snap.Parent.Name = "Burger"
		elseif Snappable.Name == "Cooked Nuggets" then
			Snappable.Closeable.Value = true
			if not Employee then
				Snappable.Close.OnServerEvent:Wait()
			end
			Snappable.Closeable.Value = false
			Handler.invisible(Snap.Parent["Nugget Box"])
			Handler.visible(Snap["Closed Nugget Box"])
			Snap.Parent.Ingredients["Cooked Nuggets"]:Destroy()
			Snap.Parent.Name = "Nuggets"
		elseif Snappable.Name == "Cooked Fries" then
			Snap.Parent.Ingredients["Cooked Fries"]:Destroy()
			Snap.Parent.Name = "Fries"
		elseif Snappable.Name == "Cooked Onion Rings" then
			Snap.Parent.Ingredients["Cooked Onion Rings"]:Destroy()
			Snap.Parent.Name = "Onion Rings"
		end
	end
end

Remotes.SnapIngredient.OnServerEvent:Connect(SnapIngredient)

-----< Reset

Remotes.Reset.OnServerEvent:Connect(function(Player)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	for Name,_ in pairs(Data) do
		Data[Name] = DataAPI.ProfileTemplate[Name]
	end
	for Name,Value in pairs(DataAPI.ProfileTemplate) do
		Data[Name] = Value
	end
	Player:Kick("Please rejoin!")
end)

-----< Whitelist

Remotes.SetWhitelist.OnServerEvent:Connect(function(Player, Other, Value)
	if Player == Other then return end
	local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
	if Value and not Restaurant.Whitelist:FindFirstChild(Other.Name) then
		Handler.create("StringValue", Restaurant.Whitelist, Other.Name)
		Remotes.TeleportPrompt:FireClient(Other, Player)
	elseif not Value then
		Handler.destroy(Restaurant.Whitelist:FindFirstChild(Other.Name))
	end
end)

-----< Day/Night cycle

local NightDuration = 10
local DayDuration = 600
Lighting.ClockTime = 9

task.spawn(function()
	while true do
		Handler.tween(Lighting, {DayDuration, "Linear"}, {ClockTime = 23.99}):Play()
		task.wait(DayDuration)
		for _,Player in pairs(Players:GetPlayers()) do
			local Data = DataAPI.Data(Player)
			if not Data then continue end
			Remotes.EndOfDay:FireClient(Player, Data.Day, Data.DailyStats)
			Data.Day += 1
			Data.DailyStats = {
				Customers = 0,
				CustomersServed = 0,
				StartXP = Data.XP,
				StartPopularity = Data.Popularity,
				StartCash = Data.Cash,
			}
			DataAPI.UpdateData(Player)
		end
		Lighting.ClockTime = 0
		Handler.tween(Lighting, {NightDuration, "Linear"}, {ClockTime = 9}):Play()
		task.wait(NightDuration)
	end
end)

-----< Buying

Remotes.Buy.OnServerEvent:Connect(function(Player, Cart)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
	if not Restaurant then return end
	for _,Info in pairs(Cart) do
		local ItemInfo = GameplayAPI.Items[Info.Category][Info.Item]
		if not ItemInfo then continue end
		local Discount = Info.Category == "Food" and Settings.Multiplier(Player, "FoodDiscount") or 1
		if GameplayAPI.XPToLevel(Data.XP) < ItemInfo.Lvl then continue end
		for Index = 1,Info.Amount do
			local InTutorial = Data.Settings.Tutorial <= 3
			if InTutorial and Data.Packages[Info.Item] then continue end

			local Cost = (ItemInfo.Unit * ItemInfo.UnitPrice) * Discount

			if Data.Cash < Cost or GameplayAPI.XPToLevel(Data.XP) < ItemInfo.Lvl then break end
			if Handler.dictionaryLength(Data.Packages) >= 25 then break end

			Data.Cash -= Cost
			Data.BoughtCount[Info.Item] = (Data.BoughtCount[Info.Item] or 0) + 1

			local GUID = InTutorial and Info.Item or Handler.generateGUID()
			local CF = Restaurant.Spawn.CFrame*CFrame.new(Handler.random(-10,10),Handler.random(5,10),Handler.random(-10,10))

			Data.Packages[GUID] = {
				Category = Info.Category,
				Item = Info.Item,
				CF = tostring(Restaurant:GetPivot():ToObjectSpace(CF)),
			}

		end
	end

	DataAPI.UpdateData(Player)
	Remotes.Parent.Handler.Notify:FireClient(Player, "Packages are arriving out front!", "Yellow")
end)

-----< Placing items

Remotes.PlaceItem.OnServerEvent:Connect(function(Player, Item, CF)
	local Restaurant = Handler.findFirstAncestorOfChild(Item, OwnedRestaurants)
	if not Restaurant or not Restaurant.Whitelist:FindFirstChild(Player.Name) then return end
	if Item.Parent ~= Restaurant.Trash and Item.Parent ~= Restaurant.Packages and Item.Parent ~= Restaurant.Ingredients then return end
	Item.Drag.CFrame = CF
	Remotes.PlaceItem:FireAllClients(Player, Item)
end)

-----< Group reward

Remotes.ClaimGroup.OnServerEvent:Connect(function(Player)
	local Data = DataAPI.Data(Player)
	if not Data or Data.ClaimedGroupReward then return end
	Data.ClaimedGroupReward = true
	Data.Cash += 1000
	DataAPI.UpdateData(Player)
end)

-----< Placing furniture

Remotes.PlaceFurniture.OnServerEvent:Connect(function(Player, Placing, CF)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
	if not Restaurant then return end
	local FurnitureModel = Restaurant.Furniture:FindFirstChild(Placing.Name, true)
	if FurnitureModel and FurnitureModel:GetAttribute("Occupied") then return end
	local PlacementType = GameplayAPI.Items[Placing.Category.Value][Placing.Item.Value].Placement
	local PlacingModel = Assets.Furniture[Placing.Item.Value]:Clone()
	PlacingModel:PivotTo(CF)
	PlacingModel.Parent = workspace
	local Valid = GameplayAPI.CanPlaceFurniture(Data, Restaurant, PlacingModel, CF, PlacementType, FurnitureModel)
	PlacingModel:Destroy()
	if Valid then
		local GUID = Handler.generateGUID()
		Data.Furniture[Placing.Name] = {
			Category = Placing.Category.Value,
			Item = Placing.Item.Value,
			CF = tostring(Restaurant:GetPivot():ToObjectSpace(CF)),
		}
		Data.Packages[Placing.Name] = nil
		DataAPI.UpdateData(Player)
	end
end)

-----< Delete furniture

local BlackListed = {
	"Register", "CashRegister", "Trashbin", "Bin", "Gold"
}

Remotes.DeleteFurniture.OnServerEvent:Connect(function(Player, Placing)
	local HasTag = false
	for _, Item in BlackListed do
		if Placing:HasTag(Item) then HasTag = true break end
	end
	if HasTag or table.find(BlackListed, Placing.Name) then
		Remotes.Parent.Handler.Notify:FireClient(Player, `Cannot sell {Placing.Name}!`, "Red")
		return
	end
	
	local Data = DataAPI.Data(Player)
	if not Data then return end
	local Restaurant = OwnedRestaurants:FindFirstChild(Player.Name)
	if not Restaurant then return end
	local FurnitureModel = Restaurant.Furniture:FindFirstChild(Placing.Name, true)
	if not FurnitureModel or FurnitureModel:GetAttribute("Occupied") then return end
	Data.Furniture[Placing.Name] = nil
	DataAPI.UpdateData(Player)
end)

-----< NPCs

local wanderingNPCWaypoints = {}

for _, v in next, workspace.WanderingNPCWaypoints:GetChildren() do 
	table.insert(wanderingNPCWaypoints, v)
end

function GetRandomWanderingSpawn()
	--local i = math.random(#wanderingNPCWaypoints)
	--local occupied = wanderingNPCWaypoints[i]
	--while occupied do 
	--	i = math.random(#wanderingNPCWaypoints)
	--	occupied = wanderingNPCWaypoints[i]
	--	task.wait()
	--end

	--wanderingNPCWaypoints[i] = true 

	--return wanderingNPCWaypoints[i]

	return wanderingNPCWaypoints[math.random(#wanderingNPCWaypoints)]
end

local OrderSample = Handler.sample(Assets.NPCOrder.Container.Requirements.Sample)
local IngredientSample = Handler.sample(OrderSample.Ingredients.Sample)

local OrderScreenSample = Handler.sample(Assets.CustomerOrder.Order.Sample)
local IngredientScreenSample = Handler.sample(OrderScreenSample.Ingredients.Sample)

function FormatNumber(Number)
	return string.format("%s.%02d", Handler.abbreviate(Number), Number%1*100)
end

function GetPath(pos: Vector3, destination: Vector3)
	local destination_waypoint = {
		Position = destination
	}

	local path = game:GetService('PathfindingService'):CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true,
		WaypointSpacing = 15,
		Costs = {
			Snow = math.huge,
			Water = math.huge,
			StairPole = math.huge
		},
	})


	local success, errorMessage = pcall(function()
		path:ComputeAsync(pos, destination)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		return path:GetWaypoints()
	end

	return {PathWaypoint.new(destination, Enum.PathWaypointAction.Walk)} -- failsafe
end

function ScriptsWalkTo(NPC: Model, dest: Vector3)
	local pathWaypoints = GetPath(NPC.HumanoidRootPart.Position, dest)
	local speed = NPC.Humanoid.WalkSpeed

	for _, waypoint: PathWaypoint in next, pathWaypoints do 
		NPC.Humanoid:MoveTo(waypoint.Position)
		local startTime = tick()
		local dist = math.abs((NPC.HumanoidRootPart.Position - waypoint.Position).Magnitude)
		local taken = dist / speed
		local size = NPC:GetExtentsSize().Y
		
		while true do
			local distNow = math.abs((NPC.HumanoidRootPart.Position - waypoint.Position).Magnitude)
			if tick() - startTime >= taken then
				if (dist - distNow) > 14 then
					print("Too far, fixing", dist - distNow)
					NPC:PivotTo(CFrame.new(waypoint.Position) * NPC:GetPivot().Rotation)
				end
				
				break
			end
			
			task.wait(.5)
		end
	end
end

local wanderingNPCsByPlayer = {}

local function ReserveLineupSlot(CashRegister, npc)
	-- 1) wait for the previous coroutine – if any – to finish reserving
	while CashRegister:GetAttribute("LineupLock") do
		task.wait()                 -- yields only a frame or two
	end
	CashRegister:SetAttribute("LineupLock", true)

	-- 2) create / name the slot *atomically*
	local lineup = CashRegister.Lineup
	local index  = #lineup:GetChildren() + 1      -- 1‑based FIFO
	local placement = Instance.new("ObjectValue")
	placement.Name  = tostring(index)
	placement.Value = npc
	placement.Parent = lineup

	CashRegister:SetAttribute("LineupLock", nil)  -- 3) release lock
	return placement                               -- give it back
end

local PER_PLAYER_CAP       = 6
local perPlayerCount       = {}  -- [userId] = integer

local function totalWandering()  
	local count = 0 
	for player, wanderingNPCs in wanderingNPCsByPlayer do 
		count += #wanderingNPCs
	end
	return count 
end

local function playerWandering(p): number
	return perPlayerCount[p.UserId] or 0 
end

local function incPlayer(p)             
	perPlayerCount[p.UserId] = playerWandering(p) + 1 
end

local function decPlayer(p)      
	warn("Decremented wanderer")
	perPlayerCount[p.UserId] = math.max(0, playerWandering(p) - 1) 
end

function MakeNPCGoIntoRestaurant(NPCData, Restaurant, i)
	local NPC = NPCData.NPC 
	local Information = NPCData.Information
	local NPCType = NPCData.NPCType 

	local Player = Players:FindFirstChild(Restaurant.Name)
	local Data = DataAPI.Data(Player)

	local FoundTable,FoundSeat,Tray = nil,nil,nil
	local Increment = 1

	warn("Making "..NPC:GetFullName() .. " go into restaurant ")
	local function SearchForTablesChairsTrays()
		FoundTable,FoundSeat,Tray = nil,nil,nil

		for _,Table in pairs(Restaurant.Furniture.Tables:GetChildren()) do
			if FoundSeat then break end
			for _,Chair in pairs(Table.Chairs:GetChildren()) do
				Chair = Chair.Chair.Value
				if not Chair then continue end
				if FoundSeat then break end
				for _,Seat in pairs(Chair.Seats:GetChildren()) do
					if (Seat.NPC.Value and Seat.NPC.Value ~= NPC) or Seat:GetAttribute("Occupied") or Seat:FindFirstChildWhichIsA("Seat", true).Occupant ~= nil then 
						continue 
					end
					FoundTable,FoundSeat,Tray = Table,Seat,Seat.Seat.Tray
					local Model = Seat:FindFirstAncestorOfClass("Model")
					if FoundSeat and Model then
						if Model:HasTag("Gold") then
							Increment += .2
						end
					end
					if FoundTable then
						if FoundSeat:HasTag("Gold") then
							Increment += .3
						end
					end
					break
				end
			end
		end
	end

	local CashRegisters = Restaurant.Furniture.CashRegisters:GetChildren()
	table.sort(CashRegisters, function(A,B) return #A.Lineup:GetChildren() < #B.Lineup:GetChildren() end)

	local RegisterParams = RaycastParams.new()
	RegisterParams.FilterType = Enum.RaycastFilterType.Include
	RegisterParams.FilterDescendantsInstances = Restaurant.Model.Placement.Diner:GetChildren()

	local CashRegister
	for _,OtherRegister in pairs(CashRegisters) do
		if not workspace:Raycast(OtherRegister.Order.Position, Vector3.new(0,-10,0), RegisterParams) then continue end
		CashRegister = OtherRegister
		break
	end

	if not CashRegister then return end

	CashRegister:SetAttribute("Occupied", true)

	if FoundTable then 
		FoundTable:SetAttribute("Occupied", true)
	end

	local Humanoid = NPC.Humanoid
	local HRP = NPC.HumanoidRootPart

	NPC.Parent = Restaurant.NPCs
	NPC:SetAttribute("IsWandering", false) -- npc no longer wandering

	if Data then
		Data.Customers += 1
		Data.DailyStats.Customers += 1
		DataAPI.UpdateData(Player)
	end

	local Placement = Handler.create("ObjectValue", CashRegister.Lineup, #CashRegister.Lineup:GetChildren()+1, NPC)

	local Spawns = Restaurant.Model.NPCSpawns:GetChildren()

	-- claim the seat long before
	SearchForTablesChairsTrays()

	FoundSeat.NPC.Value = NPC

	while tonumber(Placement.Name) ~= 1 do
		ScriptsWalkTo(
			NPC,
			(CashRegister.Order.CFrame * CFrame.new(0, 0,
				2.5 * (tonumber(Placement.Name) - 1))).Position
		)
		if tonumber(Placement.Name) == 1 then 
			break 
		end
		while task.wait(0.1) do 
			if tonumber(Placement.Name) == 1 then 
				break 
			end
		end
		task.wait()
	end

	warn("NPC walking to order.position")
	--WalkTo(Restaurant, NPC, CashRegister.Order.CFrame, true, true)
	ScriptsWalkTo(NPC, CashRegister.Order.Position)

	NPC:SetAttribute("IsInRegister", true)
	Remotes.Parent.Handler.Audio:FireClient(Player, "NewAtRegister")
	Information.InLine.Value = true
	local OrderScreenFrame = Assets.CustomerOrder:Clone()
	local OrderFrame = Assets.NPCOrder:Clone()
	local EmptyTray = Assets.Food.Tray:Clone()
	EmptyTray.TrayHitbox.Value = Tray
	EmptyTray.NPCBeam.Attachment1.Parent = Tray
	local OrderItems = {}
	local Order = {}
	local Total,TotalXP = 0,0
	for Category,Items in pairs(GameplayAPI.Orders) do
		local Item = Handler.chance(Items)
		local ItemInfo = Items[Item]
		if Item == "Nothing" or GameplayAPI.XPToLevel(Data.XP) < ItemInfo.Lvl then continue end
		local FoodLeft = Handler.create("StringValue", EmptyTray.FoodsLeft, Item, "")
		for Index = 1,Handler.randomInt(ItemInfo.Amount) do
			local ItemFrame = OrderSample:Clone()
			local ItemScreenFrame = OrderScreenSample:Clone()
			local Price = ItemInfo.Price
			for _,IngredientInfo in pairs(ItemInfo.Ingredients) do
				if GameplayAPI.XPToLevel(Data.XP) < IngredientInfo.Lvl then continue end
				if Handler.random(0,100) > IngredientInfo.Chance then continue end
				local IngredientLeft = Handler.create("StringValue", FoodLeft, IngredientInfo.Item, IngredientInfo.Item)
				local IngredientFrame = IngredientSample:Clone()
				local IngredientScreenFrame = IngredientScreenSample:Clone()
				if GameplayAPI.Ingredients[IngredientInfo.Item] then
					IngredientFrame.Icon.Image = GameplayAPI.Ingredients[IngredientInfo.Item].Icon
					IngredientScreenFrame.Icon.Image = GameplayAPI.Ingredients[IngredientInfo.Item].Icon
				else
					warn("Missing Icon: "..IngredientInfo.Item)
				end
				IngredientFrame.Parent = ItemFrame.Ingredients
				IngredientScreenFrame.Parent = ItemScreenFrame.Ingredients
				Price += IngredientInfo.Price
				table.insert(Order, IngredientInfo.Item)
			end
			table.insert(OrderItems, Item)
			ItemScreenFrame.Item.Text = Item.." - "
			ItemScreenFrame.Parent = OrderScreenFrame.Order
			local Rows = math.ceil((#ItemFrame.Ingredients:GetChildren()-3)/6)
			ItemFrame.Ingredients.UIAspectRatioConstraint.AspectRatio /= Rows
			ItemFrame.Ingredients.UIGridLayout.CellSize = UDim2.new(0.166,0,1/Rows,0)
			ItemFrame.Ingredients.UICorner.CornerRadius = UDim.new(0.5/Rows,0)
			ItemFrame.Item.Text = `{Item} - <font color="rgb(0,172,0)">${FormatNumber(Price)}</font>`
			ItemFrame.Parent = OrderFrame.Container.Requirements
			Total += Price
		end
	end
	local Multiplier = GameplayAPI.NPCs[NPCType].CashMultiplier
	Total *= Multiplier
	TotalXP = Total * 0.5 * Increment
	OrderFrame.Container.TotalPriceContainer.TotalPrice.Text = "Total: $"..FormatNumber(Total).." ("..Multiplier.."x)"
	OrderFrame.Parent = CashRegister.CustomerOrder
	OrderScreenFrame.Top.OrderGain.Text = "$"..FormatNumber(Total).." ("..Multiplier.."x)"
	OrderScreenFrame.Top.Time.Text = GameplayAPI.ClockTime()
	OrderScreenFrame.Top.TableNumber.Text = "Customer No. "..Data.DailyStats.Customers + 1
	OrderScreenFrame.Parent = script

	local OrderTaken,Bindable,Remote,Cashier = false,nil,nil,nil
	Bindable = CashRegister.EmployeeTakeOrder.Event:Once(function()
		OrderTaken = true
	end)
	Remote = CashRegister.TakeOrder.OnServerEvent:Once(function(Player)
		OrderTaken = true
		Cashier = Player
		Remotes.Parent.Handler.Audio:FireClient(Player, "OrderTaken")
	end)

	while not OrderTaken do
		task.wait(.1)
	end

	-- at this point, the order has been taken 

	Bindable:Disconnect()
	Remote:Disconnect()
	EmptyTray:PivotTo(CashRegister:GetPivot() * CFrame.new(-2.3,3,0) * CFrame.Angles(0,math.rad(90),0))
	EmptyTray.Parent = Restaurant.Trash
	OrderFrame.Container.Title.Visible = false
	OrderFrame.Container.TotalPriceContainer.Visible = false
	OrderFrame.Container.BackgroundTransparency = 0.5
	OrderFrame.StudsOffsetWorldSpace = Vector3.new(0,(#OrderFrame.Container.Requirements:GetChildren()-1)*0.4,0)
	OrderFrame.Parent = EmptyTray.Drag
	for _,Appliance in pairs(Restaurant.Furniture.OrderScreens:GetChildren()) do
		for _,Descendant in pairs(Appliance:GetDescendants()) do
			if Descendant:IsA("SurfaceGui") and Descendant.Name == "CustomerOrders" then
				local Frame = OrderScreenFrame:Clone()
				Frame.Parent = Descendant.CustomerOrders.ScrollingFrame
				Handler.onDestroy(OrderScreenFrame, Frame)
			end
		end
	end
	if Cashier then
		Remotes.DragItem:FireClient(Cashier, EmptyTray, "Tray")
	end
	Information.Ordered.Value = true
	Information.OrderTime.Value = Lighting.ClockTime
	task.delay(0.5, function()
		Placement:Destroy()
		for _,Lineup in pairs(CashRegister.Lineup:GetChildren()) do
			Lineup.Name -= 1
		end
		CashRegister:SetAttribute("Occupied", #CashRegister.Lineup:GetChildren() > 0 or nil)
	end)

	WalkTo(Restaurant, NPC, FoundSeat.Seat.CFrame, true)

	if FoundSeat.Seat.Occupant then
		FoundSeat.Seat.Occupant.Jump = true
	end

	FoundSeat.Seat:Sit(Humanoid)

	decPlayer(NPCData.Owner) -- allow more wanderers after that

	local OrderReceived = false
	local Connection
	local Debounce = false
	Connection = game:GetService("RunService").Heartbeat:Connect(function()
		if Debounce then return end
		Debounce = true
		task.delay(0.1, function()
			Debounce = false
		end)
		if not table.find(workspace:GetPartBoundsInBox(Tray.CFrame, Tray.Size), EmptyTray.Padding) then return end
		local VerifyingOrder = table.clone(Order)
		for _,Ingredient in pairs(EmptyTray.Ingredients:GetChildren()) do
			local Found = table.find(VerifyingOrder, Ingredient.Name)
			if not Found then VerifyingOrder = nil return end
			if Found then
				table.remove(VerifyingOrder, Found)
			end
		end
		if VerifyingOrder[1] then VerifyingOrder = nil return end
		VerifyingOrder = nil
		OrderReceived = true
		for _,Ingredient in pairs(Order) do
			Data.ServedIngredientCount[Ingredient] = (Data.ServedIngredientCount[Ingredient] or 0) + 1
		end
		for _,Item in pairs(OrderItems) do
			Data.ServedItemCount[Item] = (Data.ServedItemCount[Item] or 0) + 1
		end
	end)

	while not OrderReceived and EmptyTray:IsDescendantOf(workspace) do
		task.wait()
	end

	Connection:Disconnect()
	OrderScreenFrame:Destroy()
	if OrderReceived then -- start eating
		local NewTray = EmptyTray:Clone()
		EmptyTray:Destroy()
		NewTray:PivotTo(Tray.CFrame * CFrame.new(0,NewTray:GetExtentsSize().Y/2,0) * CFrame.Angles(0,math.rad(180),0))
		NewTray.Snap:RemoveTag("Snap")
		NewTray.Drag.Anchored = true
		NewTray.Parent = Tray.Parent
		Humanoid:LoadAnimation(script.EatingAnimation):Play()
		task.wait(10)
		local DirtyTray = Assets.Food["Dirty Tray"]:Clone()
		DirtyTray:PivotTo(Tray.CFrame * CFrame.new(0,DirtyTray:GetExtentsSize().Y/2,0) * CFrame.Angles(0,math.rad(180),0))
		DirtyTray.Parent = Restaurant.DirtyTrays
		NewTray:Destroy()
		if Data.GamePasses["AutoCollect"] then
			DirtyTray:Destroy()
		else
			DirtyTray.Collect.OnServerEvent:Connect(function()
				DirtyTray:Destroy()
			end)
		end
	else
		EmptyTray:Destroy()
	end
	if not NPC:IsDescendantOf(workspace) then return end
	FoundSeat.NPC.Value = nil
	local MessageOptions = GameplayAPI.Messages[OrderReceived and "Satisfied" or "Unsatisfied"]
	Chat:Chat(HRP, MessageOptions[Handler.randomInt(#MessageOptions)], Enum.ChatColor.White)
	if Data and OrderReceived then
		Data.CustomersServed += 1
		Data.DailyStats.CustomersServed += 1
		Data.Cash += Total * Settings.Multiplier(Player, "Cash")
		local XP = TotalXP * Settings.Multiplier(Player, "XP")
		Data.XP += XP
		Remotes.Parent.Handler.Notify:FireClient(Player, "You gained "..math.round(XP).." XP!", "Green")
		Remotes.Parent.Handler.Audio:FireClient(Player, "XPGained")
		DataAPI.UpdateData(Player)
	end
	if Humanoid.Sit then
		if FoundSeat and FoundSeat.Seat.Occupant == Humanoid then
			FoundSeat.Seat:Sit(nil)
		end
		Humanoid.Sit = false
		Humanoid.Jump = true           -- quick “hop” guarantees weld break
	end
	task.wait(0.5)
	Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	local ChairOccupied = nil
	for _,Seat in pairs(FoundSeat.Parent:GetChildren()) do
		if not Seat.NPC.Value then continue end
		ChairOccupied = true
		break
	end
	FoundSeat.Parent.Parent:SetAttribute("Occupied", ChairOccupied)
	local TableOccupied = nil
	for _,Chair in pairs(FoundTable.Chairs:GetChildren()) do
		Chair = Chair.Chair.Value
		if not Chair then continue end
		if TableOccupied then break end
		for _,Seat in pairs(Chair.Seats:GetChildren()) do
			if not Seat.NPC.Value then continue end
			TableOccupied = true
			break
		end
	end

	FoundTable:SetAttribute("Occupied", TableOccupied)

	--WalkTo(Restaurant, NPC, Spawns[Handler.randomInt(#Spawns)].CFrame, true)
	task.wait(1)

	game:GetService('Debris'):AddItem(NPC, 8)

	WalkTo(Restaurant, NPC, Spawns[Handler.randomInt(#Spawns)].CFrame, true)
	--ScriptsWalkTo(NPC, Spawns[Handler.randomInt(#Spawns)].CFrame.Position)
	NPC,Humanoid,HRP,Information = nil,nil,nil,nil
	FoundSeat.Parent.Parent:SetAttribute("Occupied", false)
end

function SpawnWanderingNPC(Player, Type)
	warn("Spawning wandering npc for " .. Player:GetFullName())
	local NPCType = Type and Type or Handler.chance(GameplayAPI.NPCs)
	local NPC = Type and script.VIP:Clone() or script.Rig:Clone()
	NPC.Name = NPCType
	NPC:SetAttribute("NPC", true)
	Animate:Clone().Parent = NPC

	local Humanoid = NPC.Humanoid
	local HRP = NPC.HumanoidRootPart
	local Information = Handler.tableToObject({
		Order = {},
		OrderTime = 0,
		InLine = false,
		Ordered = false,
	}, "Information")
	Information.Parent = NPC

	for _,Descendant in pairs(NPC:GetDescendants()) do
		if not Descendant:IsA("BasePart") then continue end
		Descendant.CollisionGroup = "Players"
	end

	local originalWanderingSpawn = GetRandomWanderingSpawn()
	local ocf = originalWanderingSpawn.CFrame
	NPC:PivotTo(ocf)

	if not wanderingNPCsByPlayer[Player] then 
		wanderingNPCsByPlayer[Player] = {}
	end

	table.insert(wanderingNPCsByPlayer[Player], { NPC = NPC, Owner = Player, Information = Information, NPCType = NPCType })

	Humanoid.WalkSpeed = Settings.Multiplier(Player, "NPCWalkSpeed")
	Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	NPC.Parent = workspace

	print("Player.FriendIds -->", Player.FriendIds)
	local friendIdsChildrenCount = #Player.FriendIds:GetChildren()
	if not Type then
		if friendIdsChildrenCount > 0 then
			local FriendId = Player.FriendIds:GetChildren()[math.random(friendIdsChildrenCount)]
			if FriendId then
				NPC.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(tonumber(FriendId.Name)))
			end
		end
	end

	game.ReplicatedStorage.Remotes.Gameplay.UpdateNPCAppearances:FireAllClients()

	for _,Descendant in pairs(NPC:GetDescendants()) do
		if Descendant:IsA("BasePart") then
			Descendant.CollisionGroup = "Players"
		end
	end

	local newDestination = GetRandomWanderingSpawn()
	while newDestination == originalWanderingSpawn do
		newDestination = GetRandomWanderingSpawn()
		task.wait()
	end

	local pathWaypoints = GetPath(HRP.CFrame, newDestination.Position)  -- FIX #1
	NPC:SetAttribute("IsWandering", true)

	local oldDestination
	
	print("test")

	while NPC:GetAttribute("IsWandering") do
		for _, waypoint in ipairs(pathWaypoints) do
			Humanoid:MoveTo(waypoint.Position)
			Humanoid.MoveToFinished:Wait()
			if not NPC:GetAttribute("IsWandering") then break end
		end

		task.wait(math.random(1, 3))

		repeat
			newDestination = GetRandomWanderingSpawn()
			task.wait()
		until newDestination ~= oldDestination or not NPC:GetAttribute("IsWandering")

		pathWaypoints = GetPath(HRP.CFrame, newDestination.Position)     -- FIX #2
		oldDestination = newDestination
	end

	return NPC   

end

local MAX_WANDERING_NPCS = 50
local function popClosestNPC(player, restaurantModel)
	local registers = restaurantModel.Furniture.CashRegisters
	local reg = registers and registers:GetChildren()[1]
	if not reg then return nil end

	local targetPos = reg.Placement.Position
	if not wanderingNPCsByPlayer[player] or #wanderingNPCsByPlayer[player] == 0 then print(player, wanderingNPCsByPlayer[player]) return nil end

	local bestIdx, bestDist
	for i, npcData in ipairs(wanderingNPCsByPlayer[player]) do 
		local npc = npcData.NPC
		if not npc then continue end
		local rootpart = npc:FindFirstChild("HumanoidRootPart")
		if not rootpart then continue end
		if npc and npc:GetAttribute("IsWandering") then
			local dist = (rootpart.Position - targetPos).Magnitude
			if not bestDist or dist < bestDist then
				bestDist = dist
				bestIdx = i
			end
		end
	end

	if bestIdx then
		local npcData = table.remove(wanderingNPCsByPlayer[player], bestIdx)
		--decPlayer(npcData.Owner) -- delay until they finish eating
		return npcData
	end

	return nil
end

------------------------------------------------------------------
-- ✂️  Replace everything from here down to the bottom   ✂️
------------------------------------------------------------------

------------------------------------------------------------------------
--  MAIN GAME LOOP
------------------------------------------------------------------------
local nextSpawnPlayerIdx = 1     -- keeps round-robin position

local RushHour = false

task.spawn(function()
	while true do
		--------------------------------------------------------------------
		--  STEP 1: Move wanderers into their owner’s restaurant
		--------------------------------------------------------------------
		if Lighting.ClockTime >= 9 and Lighting.ClockTime <= 21 then
			if Lighting.ClockTime > 17 and Lighting.ClockTime < 18 then
				if not RushHour then
					RushHour = true
					Remotes.Parent.Handler.Notify:FireAllClients(
						"RUSH HOUR! Lots of customers will spawn"
					)
					PER_PLAYER_CAP = 10
					
					task.spawn(function()
						repeat task.wait(.4)
						until Lighting.ClockTime > 18
						
						Remotes.Parent.Handler.Notify:FireAllClients(
							"Rush hour has ended"
						)
						
						RushHour = false
						PER_PLAYER_CAP = 6
					end)
				end
			end
			
			for _, restaurant in ipairs(OwnedRestaurants:GetChildren()) do
				local player = Players:FindFirstChild(restaurant.Name)
				if not player then warn("There was no player for " .. restaurant.Name) continue end

				local data = DataAPI.Data(player)
				if not (data and data.Settings.Open) then continue end

				-- Only need >=1 wanderer and at least one open seat
				if playerWandering(player) > 0 then
					local function seatAvailable()
						for _, tbl in pairs(restaurant.Furniture.Tables:GetChildren()) do
							for _, chairWrap in pairs(tbl.Chairs:GetChildren()) do
								local chair = chairWrap.Chair.Value
								if not chair then continue end
								for _, seat in pairs(chair.Seats:GetChildren()) do
									if   seat.NPC.Value            == nil
										and not seat:GetAttribute("Occupied")
										and seat:FindFirstChildWhichIsA("Seat", true).Occupant == nil then
										return true
									end
								end
							end
						end
						return false
					end

					-- Pop in up to two NPCs (or as many as we have wanderers)
					local moved = 0
					while moved < PER_PLAYER_CAP
						and playerWandering(player) > 0
						and seatAvailable() do

						warn("popping closest npc for player " .. player.Name)
						local npcData = popClosestNPC(player, restaurant)
						if not npcData then break end

						task.spawn(MakeNPCGoIntoRestaurant, npcData, restaurant)
						moved += 1
						task.wait(0.25)        -- small physics buffer
					end
				end
			end
		end

		--------------------------------------------------------------------
		--  STEP 2: Keep the global & per-player wanderer populations topped up
		--------------------------------------------------------------------
		local players = Players:GetPlayers()
		if totalWandering() < --[[math.min(MAX_WANDERING_NPCS, #players * PER_PLAYER_CAP)]] #players * PER_PLAYER_CAP then
			--// ???? Why check a constant against a non constant ?? should it be the other way round

			-- Advance round-robin pointer
			if nextSpawnPlayerIdx > #players then nextSpawnPlayerIdx = 1 end
			local ownerCandidate = players[nextSpawnPlayerIdx]
			nextSpawnPlayerIdx += 1            -- move pointer for next tick

			if ownerCandidate and playerWandering(ownerCandidate) < PER_PLAYER_CAP then
				incPlayer(ownerCandidate)      -- optimistic reservation
				task.spawn(function()
					if workspace:GetAttribute("GoldRush") == true then
						local Chance = 25
						local Rnd = Random.new(tick())
						local Num = Rnd:NextNumber(0, 100)
						if Num < Chance then
							SpawnWanderingNPC(ownerCandidate, "VIP")
						else
							SpawnWanderingNPC(ownerCandidate)
						end
					else
						SpawnWanderingNPC(ownerCandidate)
					end
				end)
			end
		end

		task.wait(2) -- master tick
	end
end)

WillsAPI.DevProducts["VIPCustomer"]:Connect(function(Player, Data)
	task.spawn(function()
		SpawnWanderingNPC(Player, "VIP")
	end)
	Remotes.Parent.Handler.Notify:FireClient(Player, "VIP Customer has spawned outside of your restaurant!")
end)

task.spawn(function()
	while true do
		for _, Player in Players:GetPlayers() do
			local Data = DataAPI.Data(Player)
			if Data then Data.Cash += 8 end
			DataAPI.UpdateData(Player)
		end
		
		task.wait(60)
	end
end)

------------------------------------------------------------------
--  Helper fix: ALWAYS use pairs for dictionary-style tables
------------------------------------------------------------------
-- (If you still have the old loop that looked like
--  `for player, list in ipairs(wanderingNPCsByPlayer) do ...`
--  change that `ipairs` to `pairs`.)
------------------------------------------------------------------

-----< 

-- Shut the fuck up ur code sucks

--// Will Edit
game.Players.PlayerRemoving:Connect(function(Player: Player)
	perPlayerCount[Player.UserId] = nil
	if wanderingNPCsByPlayer[Player] then
		for _, Data in wanderingNPCsByPlayer[Player] do
			if Data.NPC then
				Data.NPC:Destroy()
			end
		end
		
		table.clear(wanderingNPCsByPlayer[Player])
		wanderingNPCsByPlayer[Player] = nil
	end
end)

game.Players.PlayerAdded:Connect(function(Player: Player)
	wanderingNPCsByPlayer[Player] = {}
end)

task.spawn(function()
	for _, Player in Players:GetPlayers() do
		if not wanderingNPCsByPlayer[Player] then
			wanderingNPCsByPlayer[Player] = {}
		end
	end
end)