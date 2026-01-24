local LemonSignal = require(game.ReplicatedFirst.Vendor.LemonSignal)

return {
	SnappedToKeySpot = LemonSignal.new(),
	CookingStarted = LemonSignal.new(),
	CookingFinished = LemonSignal.new(),
	CookingCancelled = LemonSignal.new(),
	FurniturePlaced = LemonSignal.new(),
	FurnitureRemoved = LemonSignal.new(),
	InteractPressed = LemonSignal.new(),
	SecondaryInteractPressed = LemonSignal.new(),
}
