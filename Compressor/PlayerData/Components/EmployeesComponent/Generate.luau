--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local RollerConfigs = require(ReplicatedStorage.Config.Rollers).registry
local GenerateUniqueId = require(ReplicatedStorage.Util.Registry.GenerateUniqueId)
local SharedTypes = require(Components.Types.EmployeesComponent)

type EmployeesComponent = SharedTypes.EmployeesComponent

return function(Employees: EmployeesComponent, Player: Player, RollerName: string, Boost: number?)
	print(`[EmployeesComponent.Generate] Generating employee for {Player.Name}: {RollerName}`)
	assert(RollerConfigs[RollerName], "Invalid RollerName: " .. tostring(RollerName))

	local EmployeesData = Employees:GetFromPlayer(Player)
	local EmployeeId = `ROLLER_{GenerateUniqueId(EmployeesData)}`

	EmployeesData[EmployeeId] = {
		EmployeeId = EmployeeId,
		Name = RollerName,
		HiredAt = os.time(),
		AssignedHillId = nil,
		AssignedLaneId = nil,
	}

	print(`[EmployeesComponent.Generate] Successfully created employee {EmployeeId} for {Player.Name}`)
	return EmployeeId
end
