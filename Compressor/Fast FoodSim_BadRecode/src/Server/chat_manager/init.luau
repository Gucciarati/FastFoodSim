local module = {}
local tags = require(script.tags)
local colors = require(script.colors)
local commands = require(script.commands)
local marketplaceService = game:GetService("MarketplaceService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local textChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local remotes = replicatedStorage.Remotes.Chat
local apis = replicatedStorage.APIs
local settings = require(apis.settings)
local handler = require(apis.handler)
local dataApi = require(apis.data)
local owns = settings.Owns
local format = "<font color='%s'>%s</font>"
local prefix = "/"

for command,_ in pairs(commands) do
	if textChatService:FindFirstChild(command) then continue end
	handler.create("TextChatCommand", textChatService, command).PrimaryAlias = prefix..command
end

function module.updateChatTags(player)
	local ownedTags = {}
	local columns = {}
	
	for index,tag in pairs(tags) do
		local columnTag = ownedTags[tag.Column]
		if columnTag and tag.Priority < tags[columnTag].Priority then continue end
		
		if owns(player, dataApi.WaitForData(player), tag) then
			if not table.find(columns, tag.Column) then
				table.insert(columns, tag.Column)
			end
			ownedTags[tag.Column] = index
		end
	end
	
	table.sort(columns, function(A,B) return A < B end)
	local tagString = ""
	
	for _,column in pairs(columns) do
		local tag = ownedTags[column]
		tagString = tagString..format:format(tags[tag].TagColor, tags[tag].TagText).." "
	end
	
	local chatTags = player:FindFirstChild("ChatTags") or handler.create("StringValue", player, "ChatTags")
	chatTags.Value = tagString
end

function module.updateChatColor(player)
	local color, priority
	
	for _,tag in pairs(colors) do
		if priority and tag.Priority < priority then continue end
		
		if owns(player, dataApi.WaitForData(player), tag) then
			color, priority = tag.Color, tag.Priority
		end
	end
	
	local chatColor = player:FindFirstChild("ChatColor") or handler.create("StringValue", player, "ChatColor")
	chatColor.Value = color and format:format(color, "%s") or "%s"
end

function module.updateChat(player)
	module.updateChatTags(player)
	module.updateChatColor(player)
end

function module.systemMessage(message, color)
	color = color or "#ffffff"
	remotes.Chat:FireAllClients(format:format(color, message))
end

function module.localSystemMessage(player, message, color)
	color = color or "#ffffff"
	remotes.Chat:FireClient(player, format:format(color, message))
end

-- @Bap - v1.0
local admins: {[number]: boolean} = require(ReplicatedStorage.Configurations.Admins)

function module.chatted(player)
	local data = dataApi.WaitForData(player)
	player.Chatted:Connect(function(message)
		message = message:match("^"..prefix.."(.+)") or ""
		message = message:gsub("%s+", " "):split(" ")
		
		local command = commands[message[1]]
		if not command then return end
		
		-- @Bap - v1.0
		local isAdmin: boolean = table.find(admins, player.UserId) ~= nil
		
		if not isAdmin and not owns(player, data, command) then
			module.localSystemMessage(player, "You do not have permission to run this command.", "#ff0000")
			return
		end
		local responseType, response, color = command.Function(player, message)
		
		if response then
			if responseType == "Local" then
				module.localSystemMessage(player, response, color)
			else
				module.systemMessage(response, color)
			end
		end
	end)
end

return module