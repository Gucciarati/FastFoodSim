local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local APIs = ReplicatedStorage.APIs
local Handler = require(APIs.handler)

local Seating = {}

function Seating.findSeatAndTray(Restaurant, NPC)
	for _,Table in pairs(Restaurant.Furniture.Tables:GetChildren()) do
		for _,ChairWrap in pairs(Table.Chairs:GetChildren()) do
			local Chair = ChairWrap.Chair.Value
			if not Chair then continue end
			for _,Seat in pairs(Chair.Seats:GetChildren()) do
				if (Seat.NPC.Value and Seat.NPC.Value ~= NPC) or Seat:GetAttribute("Occupied") or Seat:FindFirstChildWhichIsA("Seat", true).Occupant ~= nil then
					continue
				end
				local tray = Seat.Seat.Tray
				return Table, Seat, tray
			end
		end
	end
	return nil, nil, nil
end

function Seating.pickCashRegister(Restaurant)
	local CashRegisters = Restaurant.Furniture.CashRegisters:GetChildren()
	table.sort(CashRegisters, function(A,B) return #A.Lineup:GetChildren() < #B.Lineup:GetChildren() end)
	local RegisterParams = RaycastParams.new()
	RegisterParams.FilterType = Enum.RaycastFilterType.Include
	RegisterParams.FilterDescendantsInstances = Restaurant.Model.Placement.Diner:GetChildren()
	for _,reg in pairs(CashRegisters) do
		if Workspace:Raycast(reg.Order.Position, Vector3.new(0,-10,0), RegisterParams) then
			return reg
		end
	end
	return nil
end

function Seating.createLinePlacement(CashRegister, NPC)
	return Handler.create("ObjectValue", CashRegister.Lineup, #CashRegister.Lineup:GetChildren()+1, NPC)
end

return Seating


