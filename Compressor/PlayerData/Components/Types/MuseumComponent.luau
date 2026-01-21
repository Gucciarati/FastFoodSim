export type MuseumComponent = {
	get: (entity: any) -> any,
	GetFromPlayer: (self: MuseumComponent, Player: Player) -> any,
	GetSlot: (self: MuseumComponent, Player: Player, SlotId: number) -> any,
	IsSlotEmpty: (self: MuseumComponent, Player: Player, SlotId: number) -> boolean,
	PlaceSnowman: (self: MuseumComponent, Player: Player, SlotId: number, SnowmanName: string) -> boolean,
	RemoveSnowman: (self: MuseumComponent, Player: Player, SlotId: number) -> string?,
	CalculateTotalIncome: (self: MuseumComponent, Player: Player) -> number,
}

return {}
