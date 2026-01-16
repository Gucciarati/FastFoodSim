local module = {}
local BadgeService = game:GetService("BadgeService")
local ChatAPI = require(script.Parent.chat_manager)
local Handler = require(game:GetService("ReplicatedStorage").APIs.handler)
local DataAPI = require(game:GetService("ReplicatedStorage").APIs.data)

module.Badges = {
}

module.Meet = {
}

module.Amounts = {
}

module.Children = {
}

function module.AwardBadge(Player, Badge)
	local Data = DataAPI.Data(Player)
	if not Data then return end
	if Data.Badges[Badge] == false then
		local _,Success = Handler.forcePcall(1, .1, BadgeService.AwardBadge, BadgeService, Player.UserId, module.Badges[Badge])
		if not Success then return end
		Data.Badges[Badge] = true
		DataAPI.UpdateData(Player)
		local Info,Success = Handler.forcePcall(1, .1, BadgeService.GetBadgeInfoAsync, BadgeService, module.Badges[Badge])
		local BadgeName = Success and Info.Name or "unknown"
		ChatAPI.localSystemMessage(Player, "You have earned the '"..BadgeName.."' badge", "rgb(70,255,70)")
	end
end

return module
