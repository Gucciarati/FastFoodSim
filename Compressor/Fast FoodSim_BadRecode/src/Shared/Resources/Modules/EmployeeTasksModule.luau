local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Chat = game:GetService("Chat")

local APIs = ReplicatedStorage.APIs
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)
local Settings = require(APIs.settings)
local GameplayAPI = require(APIs.gameplay)
local Helpers = require(ReplicatedStorage.Resources.Modules.HelpersModule)
local SnapModule = require(ReplicatedStorage.Resources.Modules.SnapModule)

local M = {}

local function FindPath(Restaurant, Start, Target, Path)
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

local function WalkTo(Restaurant, NPC, Target, Yield, Turn)
	Yield = Yield == nil and true or Yield
	task.spawn(function()
		local Path = FindPath(Restaurant, NPC.HumanoidRootPart, Target.Position)
		for Index = 1,#Path do NPC.Humanoid:MoveTo(Path[Index]) NPC.Humanoid.MoveToFinished:Wait() end
		if Turn then
			task.wait(0.2)
			Handler.tween(NPC.HumanoidRootPart, {0.2}, {CFrame = Target + Vector3.new(0,NPC.HumanoidRootPart.Position.Y-Target.Y,0)}):Play()
		end
		Yield = false
	end)
	while Yield do task.wait() end
end

function M.bind(Folder, Restaurant, Player, Data, Animate, Employees)
	local CurrentMissingIngredients = {}
	Handler.childAdded(Folder.NPCs, function(Employee)
		local Type = Employee.Type.Value
		local Character = Employees[Type][Employee.Gender.Value]:Clone()
		local HRP,Humanoid = Character.HumanoidRootPart,Character.Humanoid
		Animate:Clone().Parent = Character
		Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		Humanoid.WalkSpeed = Settings.Multiplier(Player, "NPCWalkSpeed")
		Character.Parent = Restaurant.Employees
		HRP.CFrame = Restaurant.Spawn.CFrame * CFrame.new(0,3,0)
		Handler.onDestroy(Employee, Character)
		local ChatDebounce = false
		local function ChatBubble(Text)
			if ChatDebounce then return end; ChatDebounce = true; task.delay(10,function() ChatDebounce=false end)
			Chat:Chat(HRP, Text, Enum.ChatColor.White); Helpers.notifyPlayer(Player, Text, "Red")
		end
		local function FindIngredient(TargetItem)
			local Ingredient
			for Name,Food in pairs(Data.Foods) do
				local Item = Food.Item
				if Item ~= TargetItem then continue end
				Ingredient = SnapModule.TakeIngredient(Player, Restaurant.Ingredients[Name], true)
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
									local FinishedIngredient = SnapModule.SnapIngredient(Player, Ingredient, Snap, true)
									local Ingredient2 = FindIngredient(FoodMatchup[FoodLeft.Name][2])
									if Ingredient2 then
										SnapModule.SnapIngredient(Player, FinishedIngredient, Ingredient2.Part, true)
										SnapModule.SnapIngredient(Player, Ingredient2, Tray.Snap, true)
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
									local CookedPatty = SnapModule.SnapIngredient(Player, Patty, Snap, true)
									local Paper = FindIngredient("Papers")
									if Paper then
										local Bun = FindIngredient("Burger Buns")
										if Bun then
											SnapModule.SnapIngredient(Player, Bun, Paper.Part, true)
											SnapModule.SnapIngredient(Player, CookedPatty, Paper.Part, true)
											local MissingIngredient = false
											for _,FoodIngredient in pairs(FoodLeft:GetChildren()) do
												if FoodIngredient.Name == "Burger Bun" or FoodIngredient.Name == "Cooked Patty" then continue end
												local Ingredient = FindIngredient(FoodMatchup[FoodIngredient.Name])
												if Ingredient then
													SnapModule.SnapIngredient(Player, Ingredient, Paper.Part, true)
												else
													MissingIngredient = true
												end
											end
											if not MissingIngredient then
												Paper.Part["Cooked Patty"].EmployeeWrap:Fire()
											end
											SnapModule.SnapIngredient(Player, Paper, Tray.Snap, true)
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
end

return M


