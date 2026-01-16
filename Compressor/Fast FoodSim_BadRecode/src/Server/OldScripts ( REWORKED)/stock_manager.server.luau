-----< Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local APIs = ReplicatedStorage.APIs
local Handler = require(APIs.handler)
local StockAPI = require(APIs.stock)
local ServerId = Handler.generateGUID()

-----< Updates

function Publish()
	local Message
	for _,Group in pairs(StockAPI.Updates:GetChildren()) do
		local GroupMessage
		for _,Update in pairs(Group:GetChildren()) do
			local Stock,Increment = Update.Name,Update.Value
			Handler.destroy(Update)
			
			local Core = StockAPI.DataStores[Group.Name]
			Handler.forcePcall(1, .1, Core.IncrementAsync, Core, Update.Name, Increment)
			GroupMessage = (GroupMessage and GroupMessage.."&" or "")..Stock.."="..Increment
		end
		if not GroupMessage then continue end
		Message = (Message and Message.."&s" or "")..Group.Name.."={"..GroupMessage.."}"
	end
	if not Message then return end
	MessagingService:PublishAsync(StockAPI.Version, "Server="..ServerId.."&Groups="..Message)
end

task.spawn(function()
	while true do
		task.wait(StockAPI.Intervals)
		Publish()
	end
end)

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

-----< Save

game:BindToClose(Publish)

-----< 