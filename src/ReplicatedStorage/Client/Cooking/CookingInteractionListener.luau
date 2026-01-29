--!strict
--[[
	CookingInteractionListener
	
	Listens for player interactions with cooking snaps.
	When player presses E on a cooking snap with an action,
	fires the appropriate cooking keypoint registration.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local StateValue = require(ReplicatedStorage.Packages.StateValue)
local Net = require(ReplicatedStorage.Packages.Net)
local RegisterKeypointRE = Net:RemoteEvent("RegisterCookingKeypoint")

local Events = require(ReplicatedStorage.SharedModules.Events)

-- Cooking actions that trigger keypoint registration
local COOKING_ACTIONS = {
	["Flip"] = true,
	["Fry"] = true,
	["Fill"] = true,
	["Mix"] = true,
}

local function OnInputBegan(input: InputObject, gameProcessed: boolean)


	-- Get current interactable from UI state
	local CurrentInteractable = StateValue.Peek("CurrentInteractable")
	if not CurrentInteractable then return end

	-- Check if this interactable has cooking CustomHoverData
	local CustomHoverData = StateValue.Peek("CustomHoverData")[CurrentInteractable]
	if not CustomHoverData then return end

	-- Check if any actions are cooking actions
	local hasCookingAction = false
	for _, Action in CustomHoverData.ActionList do
		if COOKING_ACTIONS[Action.Action] then
			hasCookingAction = true
			break
		end
	end

	if not hasCookingAction then return end

	-- Fire keypoint registration if we have ProcessId and KeypointIndex
	if CustomHoverData.ProcessId and CustomHoverData.KeypointIndex then
		print(`[COOKING] Interaction: Registering keypoint {CustomHoverData.KeypointIndex + 1} for process {CustomHoverData.ProcessId}`)
		RegisterKeypointRE:FireServer(CustomHoverData.ProcessId, CustomHoverData.KeypointIndex)
	end
end

Events.InteractPressed:Connect(OnInputBegan)

return true
