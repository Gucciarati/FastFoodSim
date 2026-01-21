export type HillsComponent = {
	get: (entity: any) -> any,
	Changed: any,
	GetFromPlayer: (self: HillsComponent, Player: Player) -> any,
	GetHill: (self: HillsComponent, Player: Player, HillId: number) -> any,
	AddSnowToHill: (self: HillsComponent, Player: Player, HillId: number, Amount: number) -> (),
	SetHillBlueprint: (self: HillsComponent, Player: Player, HillId: number, BlueprintName: string, Goal: number) -> (),
	GetHillBlueprint: (self: HillsComponent, Player: Player, HillId: number) -> any,
	BuyNewHill: (self: HillsComponent, Player: Player) -> any,
	UpgradeHill: (self: HillsComponent, Player: Player, HillId: number) -> any,
	AssignEmployeeToLane: (self: HillsComponent, Player: Player, HillId: number, LaneId: number, EmployeeId: string) -> any,
	AddLaneToHill: (self: HillsComponent, Player: Player, HillId: number) -> any,
}

return {}
