--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.EmployeesComponent)

type EmployeesComponent = SharedTypes.EmployeesComponent

return function(Employees: EmployeesComponent, Player: Player, EmployeeId: string): boolean
	local EmployeesData = Employees:GetFromPlayer(Player)
	if not EmployeesData[EmployeeId] then return false end

	EmployeesData[EmployeeId] = nil
	return true
end
