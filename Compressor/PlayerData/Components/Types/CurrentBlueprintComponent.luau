export type CurrentBlueprintComponent = {
	get: (entity: any) -> any,
	GetFromPlayer: (self: CurrentBlueprintComponent, Player: Player) -> any,
	Set: (self: CurrentBlueprintComponent, Player: Player, BlueprintName: string) -> (),
	Clear: (self: CurrentBlueprintComponent, Player: Player) -> (),
	AddSnow: (self: CurrentBlueprintComponent, Player: Player, Amount: number) -> (),
}

return {}
