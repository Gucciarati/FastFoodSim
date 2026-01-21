--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.EmployeesComponent)

type EmployeesComponent = SharedTypes.EmployeesComponent

return function(Employees: EmployeesComponent, Player: Player): number
	local EmployeesData = Employees:GetFromPlayer(Player)
	local Count = 0
	for _ in EmployeesData do
		Count += 1
	end
	return Count
end
