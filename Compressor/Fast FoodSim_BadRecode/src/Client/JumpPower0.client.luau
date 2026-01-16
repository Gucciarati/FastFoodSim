local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

if UserInputService.TouchEnabled then
	local player = Players.LocalPlayer
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.JumpPower = 0
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	end)

	-- In case the character is already spawned
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.JumpPower = 0
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		end
	end
end
