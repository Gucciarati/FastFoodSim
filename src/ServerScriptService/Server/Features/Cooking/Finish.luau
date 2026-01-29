--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateValue = require(ReplicatedStorage.Packages.StateValue)

local function FinishHandler(UserId: number, ProcessId: string)
	local CurrentState = StateValue.Peek("ActiveCookingProcesses")

	if not CurrentState[UserId] or not CurrentState[UserId][ProcessId] then
		warn(`Couldn't find Cooking Process: {ProcessId} for user {UserId}`)
		return false
	end

	CurrentState[UserId][ProcessId] = nil
	StateValue.Set("ActiveCookingProcesses", CurrentState)
	return true
end

return FinishHandler
