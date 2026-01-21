--!strict

export type ConveyorData = {
	Tier: number,
	Luck: number,
	SpawnRateMultiplier: number,
	LifetimeMultiplier: number,
}

export type ConveyorComponent = {
	get: (entity: any) -> ConveyorData?,
	Changed: any,
	GetFromPlayer: (self: ConveyorComponent, Player: Player) -> ConveyorData,
	GetTier: (self: ConveyorComponent, Player: Player) -> number,
	SetTier: (self: ConveyorComponent, Player: Player, Value: number) -> (),
	GetLuck: (self: ConveyorComponent, Player: Player) -> number,
	SetLuck: (self: ConveyorComponent, Player: Player, Value: number) -> (),
	GetSpawnRateMultiplier: (self: ConveyorComponent, Player: Player) -> number,
	SetSpawnRateMultiplier: (self: ConveyorComponent, Player: Player, Value: number) -> (),
	GetLifetimeMultiplier: (self: ConveyorComponent, Player: Player) -> number,
	SetLifetimeMultiplier: (self: ConveyorComponent, Player: Player, Value: number) -> (),
}

return nil
