--[[
	Stock Sync Module
	----------------
	Syncs limited stock updates across servers via MessagingService.

	Created by: Guinogue — Modified on October 27, 2025
]]

local StockSyncModule = {}

-----< Module Setup >

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local APIs = ReplicatedStorage.APIs
local Handler = require(APIs.handler)
local StockAPI = require(APIs.stock)
local ServerId = Handler.generateGUID()

-----< Publish >

local function Publish()
	local Message
	for _,Group in pairs(StockAPI.Updates:GetChildren()) do
		local GroupMessage
		for _,Update in pairs(Group:GetChildren()) do
			local Stock,Increment = Update.Name, Update.Value
			Handler.destroy(Update)
			local Core = StockAPI.DataStores[Group.Name]
			Handler.forcePcall(1, .1, Core.IncrementAsync, Core, Update.Name, Increment)
			GroupMessage = (GroupMessage and GroupMessage.."&" or "")..Stock.."="..Increment
		end
		if GroupMessage then
			Message = (Message and Message.."&s" or "")..Group.Name.."={"..GroupMessage.."}"
		end
	end
	if Message then MessagingService:PublishAsync(StockAPI.Version, "Server="..ServerId.."&Groups="..Message) end
end

-----< Subscribe >

local function Subscribe()
	MessagingService:SubscribeAsync(StockAPI.Version, function(Message)
		local Server,Stocks = Message.Data:match("Server=(.+)&Groups=(.+)")
		if Server == ServerId then return end
		for _,GroupInformation in pairs(Stocks:split("&s")) do
			local Group,Updates = GroupInformation:match("(.+)={(.+)}")
			for _,Information in pairs(Updates:split("&")) do
				local Stock,Increment = Information:match("(.+)=(.+)")
				StockAPI.IncrementStock(Group, Stock, Increment, true)
			end
		end
	end)
end

-----< Loop & Save >

local Connection

local function StartLoop()
	Connection = task.spawn(function()
		while true do task.wait(StockAPI.Intervals); Publish() end
	end)
end

function StockSyncModule.Initialize()
	Subscribe(); StartLoop(); game:BindToClose(Publish); return true
end

return StockSyncModule
