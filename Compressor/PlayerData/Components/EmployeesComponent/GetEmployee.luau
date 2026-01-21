--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local SharedTypes = require(Components.Types.EmployeesComponent)

type EmployeesComponent = SharedTypes.EmployeesComponent

return function(Employees: EmployeesComponent, Player: Player, EmployeeId: string)
	local EmployeesData = Employees:GetFromPlayer(Player)
	return EmployeesData[EmployeeId]
end
