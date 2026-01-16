local module = {}
local Lighting = game:GetService("Lighting")

module.Ingredients = require(script.ingredients)
module.Expansions = require(script.expansions)
module.Messages = require(script.messages)
module.Orders = require(script.orders)
module.Items = require(script.items)
module.NPCs = require(script.npcs)

module.InteractionDistance = 16

module.MaxPopularity = 100
module.MaxLevel = 50

module.Employees = {
	["Cashier"] = {
		Price = 1700,
		Icon = "rbxassetid://121700556675629",
		Product = "Cashier",
	},
	["Server"] = {
		Price = 2000,
		Icon = "rbxassetid://133312720930520",
		Product = "Server",
	},
	["Fry"] = {
		Price = 3500,
		Icon = "rbxassetid://100867955798298",
		Product = "FryChef",
	},
	["Grill"] = {
		Price = 3250,
		Icon = "rbxassetid://134436868380551",
		Product = "GrillChef",
	},
	["Janitor"] = {
		Price = 950,
		Icon = "rbxassetid://134436868380551",
		Product = "Janitor",
	},
}

module.PriceMultiPerEmployee = 0.75

module.EmployeeSlots = {
	[1] = 8,
	[2] = 15,
	[3] = 20,
	[4] = 25,
	[5] = 30,
	[6] = 36,
	[7] = 42,
	[8] = 50,
}

--------------------------------------------------------------------
--  🔧  SHARED HELPERS – 
--------------------------------------------------------------------
local IGNORE_FOR_OVERLAP = { }         
local OVERLAP_PARAMS     = OverlapParams.new()
OVERLAP_PARAMS.FilterType = Enum.RaycastFilterType.Exclude
--------------------------------------------------------------------

local function GetOpaqueBoundingBoxSize(model: Model): Vector3
	assert(typeof(model) == "Instance" and model:IsA("Model"),
		"GetOpaqueBoundingBoxSize expects a Model")

	local minVec, maxVec  -- world‑space AABB corners we’ll grow

	for _, inst in ipairs(model:GetDescendants()) do
		if inst:IsA("BasePart") and inst.Transparency == 0 and inst.Name ~= 'Arrow' then
			-- Convert the 8 corners of this part into world space
			local half = inst.Size * 0.5
			local cf   = inst.CFrame
			local corners = {
				cf *  Vector3.new( half.X,  half.Y,  half.Z),
				cf *  Vector3.new(-half.X,  half.Y,  half.Z),
				cf *  Vector3.new( half.X, -half.Y,  half.Z),
				cf *  Vector3.new(-half.X, -half.Y,  half.Z),
				cf *  Vector3.new( half.X,  half.Y, -half.Z),
				cf *  Vector3.new(-half.X,  half.Y, -half.Z),
				cf *  Vector3.new( half.X, -half.Y, -half.Z),
				cf *  Vector3.new(-half.X, -half.Y, -half.Z),
			}

			for _, pt in ipairs(corners) do
				if not minVec then
					-- First point seen → initialize both corners
					minVec, maxVec = pt, pt
				else
					minVec = Vector3.new(
						math.min(minVec.X, pt.X),
						math.min(minVec.Y, pt.Y),
						math.min(minVec.Z, pt.Z)
					)
					maxVec = Vector3.new(
						math.max(maxVec.X, pt.X),
						math.max(maxVec.Y, pt.Y),
						math.max(maxVec.Z, pt.Z)
					)
				end
			end
		end
	end

	if not minVec then
		-- No fully‑opaque parts found
		return Vector3.zero
	end

	return maxVec - minVec
end

function module.CanPlaceFurniture(Data, Restaurant, PlacingModel, CF, PlacementType, Ignore)
	--------------------------------------------------------------
	-- 1.  ROTATION MUST BE ON 0°, 90°, 180°, 270° ONLY
	--------------------------------------------------------------
	local _, rotY, _ = CF:ToEulerAnglesYXZ()
	if (math.round(math.deg(rotY)*100)/100) % 90 ~= 0 then
		return false, "Invalid rotation"
	end

	--------------------------------------------------------------
	-- 2.  BUILD OVERLAP PARAMS SO WE DON’T HIT OUR OWN PARTS
	--------------------------------------------------------------
	table.clear(IGNORE_FOR_OVERLAP)
	table.insert(IGNORE_FOR_OVERLAP, PlacingModel) -- the ghost itself
	
	if Ignore then table.insert(IGNORE_FOR_OVERLAP, Ignore) end -- for replacement
	OVERLAP_PARAMS.FilterDescendantsInstances = IGNORE_FOR_OVERLAP

	--------------------------------------------------------------
	-- 3.  QUERY EVERYTHING INSIDE THE MODEL’S TRUE BOUNDING BOX
	--------------------------------------------------------------
	local bboxSize = GetOpaqueBoundingBoxSize(PlacingModel)
	local hitParts = workspace:GetPartBoundsInBox(CF, bboxSize, OVERLAP_PARAMS)

	local isOnValidFloor  = false
	
	local test = game:GetService('RunService'):IsStudio()

	for _, part in ipairs(hitParts) do
		-- 3‑A  ⛔  BUMPS INTO UNPLACEMENT ZONE?  OUT OF BOUNDS
		if part:IsDescendantOf(Restaurant.Model.Unplacement[PlacementType]) then
			warn("mhm1")
			return false, "Out of bounds"
		end

		-- 3‑B  ✅  TOUCHING AT LEAST ONE VALID PLACEMENT PAD?
		if part.Parent == Restaurant.Model.Placement[PlacementType] then
			isOnValidFloor = true
		end

		-- 3‑C  ⛔  COLLIDING WITH ANY EXISTING FURNITURE (NO FILTER)
		if part:IsDescendantOf(Restaurant.Furniture) and part.Parent ~= Ignore and part.Name ~= "Placement" and part.Name ~= "Arrow" then
			if part.Transparency < 1 then 
				return false, "Not enough space" .. (test and " (" .. part:GetFullName() .. ")" or "")
			end
		end
	end

	--------------------------------------------------------------
	-- 4.  MUST BE ON A “GREEN” FLOOR PAD, OTHERWISE STILL OOB
	--------------------------------------------------------------
	if not isOnValidFloor then
		warn("mhm2")
		return false, "Out of bounds"
	end

	return true
end

function module.XPToLevel(XP)
	local level = 1
	local baseXP = 40   -- was 8 → now 8 × 5 = 40
	local growthPerLevel = 8  -- was 4 → now 4 × 5 = 20
	local currentXP = baseXP

	while XP >= currentXP and level < module.MaxLevel do
		XP = XP - currentXP
		level = level + 1
		currentXP = currentXP + growthPerLevel
	end

	return level
end

--[[function module.LevelToXP(Level)
	local totalXP = 0
	local baseXP = 25
	local growthPerLevel = 4*(Level/3)
	local currentXP = baseXP

	for i = 1, Level - 1 do
		totalXP = totalXP + currentXP
		currentXP = currentXP + growthPerLevel
	end

	return totalXP
end]]

function module.LevelToXP(Level)
	local totalXP = 0
	local baseXP = 40
	local growthPerLevel = 8
	local currentXP = baseXP

	for i = 1, Level - 1 do
		totalXP = totalXP + currentXP
		currentXP = currentXP + growthPerLevel
	end

	return totalXP
end

function module.ClockTime()
	local Value = Lighting.ClockTime
	local Hours = math.floor(Value)%12
	local Minutes = math.floor(Value%1*60)
	if Hours == 0 then
		Hours = 12
	end
	return string.format("%02d:%02d %s", Hours, Minutes, Value >= 12 and "PM" or "AM")
end

return module