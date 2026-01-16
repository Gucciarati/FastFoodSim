--[[

> If you'd like to receive automatic updates make sure to enable
`AutoUpdate` within PackageLink (inside the Icon).

> I recommend enabling auto updates as the application constantly
receives bug fixes, improvements, etc.

> All updates (within this version of TopbarPlus) will be backwards
compatible so you don't need to worry about updates interfering
with your code.

> Try not to modify any code within Icon. For instance, don't accept
"This script is part of a package. Click here to modify." when
viewing the source code otherwise it will break the package link.
If you want to add your own themes I recommend cloning the `Default`
module outside of the package then requiring and applying that.

> DISCLAIMER: as of 27th March 2024 public packages haven't been fully
rolled out so you won't be able to retrieve the latest version
for the time being.

> READ_ME is Script with RunContext set to 'Client' meaning you can
store it in ReplicatedStorage and Workspace and it will still run 
like a normal LocalScript. DO NOT PLACE place in StarterPlayerScripts
(because this is a Script with RunContext). You need to create a separate
LocalScript for anything under StarterPlayerScripts. 

> You're welcome to move `Icon` and require it yourself. You can
then delete this folder and READ_ME.

> Have feedback? Post it to ``devforum.roblox.com/t/topbarplus/1017485``
which I actively monitor. Enjoy! ~ForeverHD

--]]

local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local socialService = game:GetService("SocialService")
local soundService = game:GetService("SoundService")

local container = script.Parent
local Icon = require(container.Icon)

-- Function to open the Invite Friends UI
local function openInviteUI()
	local success, err = pcall(function()
		socialService:PromptGameInvite(players.LocalPlayer)
	end)
	if not success then
		warn("Failed to open invite UI:", err)
	end
end

-- Keybind: Press "N" to open Invite UI
uis.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.N then
		openInviteUI()
	end
end)

-- Invite Friends Icon
local invite = Icon.new()
	:setImage(70676176930991)
	:setCaption("Invite Friends")
	:setLabel("Invite Friends")
	:bindEvent("selected", function()
		openInviteUI()
	end)

if uis.KeyboardEnabled then
	invite:setLabel("Invite Friends - N")
end

-- Music Toggle Icon
Icon.new()
	:setImage(74409119311372, "Selected")
	:setImage(73446898438142, "Deselected")
	:setCaption("Music")
	:bindEvent("selected", function()
		for _, v in ipairs(soundService.Music:GetChildren()) do
			if v:IsA("Sound") then
				v.Volume = 0
			end
		end
	end)
	:bindEvent("deselected", function()
		for _, v in ipairs(soundService.Music:GetChildren()) do
			if v:IsA("Sound") then
				v.Volume = 0.25
			end
		end
	end)
