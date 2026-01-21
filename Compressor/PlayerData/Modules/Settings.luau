local ServerScriptService = game:GetService("ServerScriptService")
local DataRegistry =
	require(ServerScriptService.PlayerData.Interfaces.DataRegistry)

return DataRegistry.register("Settings", {
	volume = 0.5,
	onlyFriendsCanJoin = false,
	canReceiveGifts = false,

	enableDebugMode = false,
	enableScreenLogs = false,
})
