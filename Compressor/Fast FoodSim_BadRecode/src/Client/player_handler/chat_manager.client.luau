-----< Variables

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local PlayerHandler = require(script.Parent)
local Remotes = PlayerHandler.Remotes.Chat

-----< Chat tags

TextChatService.OnIncomingMessage = function(Message)
	if not Message.TextSource then return end
	
	local Player = Players:GetPlayerByUserId(Message.TextSource.UserId)
	local Properties = Instance.new("TextChatMessageProperties")
	local Text = ""
	
	local ChatColor = Player:WaitForChild("ChatColor")
	Text = ChatColor.Value:format(Message.PrefixText)
	
	local ChatTags = Player:WaitForChild("ChatTags")
	Text = ChatTags.Value..Text
	
	Properties.PrefixText = Text
	return Properties
end

-----< System messages

Remotes.Chat.OnClientEvent:Connect(function(Message)
	TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(Message)
end)

-----< 