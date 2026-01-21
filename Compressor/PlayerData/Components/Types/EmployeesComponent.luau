--!strict

export type EmployeeData = {
	EmployeeId: string,
	Name: string,
	HiredAt: number,
	AssignedHillId: number?,
	AssignedLaneId: number?,
}

export type EmployeesComponent = {
	get: (entity: any) -> { [string]: EmployeeData }?,
	Changed: any,
	GetFromPlayer: (self: EmployeesComponent, Player: Player) -> { [string]: EmployeeData },
	Generate: (self: EmployeesComponent, Player: Player, RollerName: string) -> string,
	RemoveEmployee: (self: EmployeesComponent, Player: Player, EmployeeId: string) -> boolean,
	GetEmployee: (self: EmployeesComponent, Player: Player, EmployeeId: string) -> EmployeeData?,
	GetEmployeeCount: (self: EmployeesComponent, Player: Player) -> number,
}

return nil
