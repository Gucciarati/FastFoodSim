local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local APIs = ReplicatedStorage.APIs
local Handler = require(APIs.handler)
local DataAPI = require(APIs.data)
local GameplayAPI = require(APIs.gameplay)
local Helpers = require(ReplicatedStorage.Resources.Modules.HelpersModule)

local M = {}

function M.bind(Player, Restaurant, Folder, Data, TalkingSample, Assets)
	local CurrentModel = Restaurant.Model
	local Talking = TalkingSample and TalkingSample:Clone() or nil

	if Talking then
		Handler.childrenChanged(Restaurant.NPCs, function()
			if not Restaurant.Parent then return end
			Talking.Volume = math.clamp((#Restaurant.NPCs:GetChildren()-1)/10,0,1)
		end)
	end

	Handler.changed(Folder.XP, function(XP)
		local Level = GameplayAPI.XPToLevel(XP)
		for Slot,Requirement in pairs(GameplayAPI.EmployeeSlots) do
			if Data.EmployeeSlots >= Slot then continue end
			if Level < Requirement then continue end
			Data.EmployeeSlots = Slot
		end
	end)

	Handler.changed(Folder.Expansions, function(Upgrade)
		if Talking then Talking.Parent = nil end
		CurrentModel:Destroy()
		CurrentModel = Assets.Expansions[Upgrade]:Clone()
		CurrentModel.Name = "Model"
		CurrentModel:PivotTo(Restaurant:GetPivot())
		CurrentModel.Parent = Restaurant
		if Talking then Talking.Parent = CurrentModel.Placement.Diner:FindFirstChildOfClass("BasePart") end
		for _,Neon in pairs(Restaurant.Model.Sign.Neon:GetChildren()) do
			local H = Neon.Color:ToHSV()
			Neon.Color = Color3.fromHSV(H,1,Data.Settings.Open and 1 or 0.35)
		end
		Restaurant.Model.RestaurantName.SurfaceGui.TextLabel.Text = Data.Settings.RestaurantName
	end)

	Handler.childAdded(Folder.Furniture, function(Furniture)
		local FurnitureModel = Assets.Furniture:FindFirstChild(Furniture.Item.Value)
		if not FurnitureModel then return end
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

	Handler.changed(Folder.ActivePotions["Customer Rush"], function(Value)
		Data.Popularity = Value > 0 and 100 or 0
		DataAPI.UpdateData(Player)
	end)

	Handler.changed(Folder.ActivePotions["Speed Up"], function(Value)
		local Speed = Settings and Settings.Multiplier and Settings.Multiplier(Player, "NPCWalkSpeed") or 16
		for _,NPC in pairs(Restaurant.NPCs:GetChildren()) do NPC.Humanoid.WalkSpeed = Speed end
		for _,NPC in pairs(Restaurant.Employees:GetChildren()) do NPC.Humanoid.WalkSpeed = Speed end
	end)

	Handler.childAdded(Restaurant.Furniture.CashRegisters, function(Register)
		PhysicsService:RegisterCollisionGroup(Register.Name)
		PhysicsService:CollisionGroupSetCollidable(Register.Name, Register.Name, false)
		Helpers.setCollisionGroupForModelParts(Register, Register.Name)
	end)

	if Talking then
		Talking.Parent = Restaurant.Model.Placement.Diner:FindFirstChildOfClass("BasePart")
	end
end

return M


