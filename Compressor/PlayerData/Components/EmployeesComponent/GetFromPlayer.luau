--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local PlayerComponents = require(ServerScriptService.Player.Components.PlayerComponents)
local SharedTypes = require(Components.Types.EmployeesComponent)

type EmployeesComponent = SharedTypes.EmployeesComponent

return function(Employees: EmployeesComponent, Player: Player)
	local Entity = PlayerComponents.playerInstanceToEntity(Player)
	if not Entity then return {} end
	return Employees.get(Entity) or {}
end
