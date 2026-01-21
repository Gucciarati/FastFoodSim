-- Direct function: (Hills, Player, HillId, LaneId, EmployeeId)
--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Components = ServerScriptService.PlayerData.Components
local PlayerComponents = ServerScriptService.Player.Components
local PlayerComponent = require(PlayerComponents.PlayerComponents)

local SharedTypes = require(Components.Types.HillsComponent)

type HillsComponent = SharedTypes.HillsComponent

return function(Hills: HillsComponent, Player: Player, HillId: number, LaneId: number, EmployeeId: string?)
	local Hill = Hills:GetHill(Player, HillId)
	if not Hill or not Hill.Lanes then return end

	for _, Lane in Hill.Lanes do
		if Lane.LaneId ~= LaneId then continue end
		Lane.EmployeeId = EmployeeId

		local Entity = PlayerComponent.playerInstanceToEntity(Player)
		Hills.Changed:Fire(Entity, "Lane", Hill)
		break
	end

	
end
