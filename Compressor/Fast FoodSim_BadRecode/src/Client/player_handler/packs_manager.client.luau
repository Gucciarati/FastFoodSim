-----< Variables

local PlayerHandler = require(script.Parent)
local Settings = PlayerHandler.APIs.settings
local Handler = PlayerHandler.APIs.handler
local UIHandler = PlayerHandler.UIHandler
local PacksAPI = PlayerHandler.APIs.packs
local Data = PlayerHandler.Data
local Main = PlayerHandler.ScreenGui.main

-----< Pack frames

local Packs = {}

for Pack,Information in pairs(PacksAPI) do
	local Frame = Main.Frames:FindFirstChild(Pack)
	local Button = Main:FindFirstChild(Pack)
	if not Frame or not Button then continue end
	Information.Frame = Frame
	Information.Button = Button
	Packs[Pack] = Information
end

-----< Timers

Handler.heartbeat(function()
	for Pack,Information in pairs(Packs) do
		local Delay = Information.Delay or 0
		local FirstJoin = Data.FirstJoin.Value + Delay
		local End = Information.End or (FirstJoin + (Information.Duration or math.huge))
		local Start = Information.Start or FirstJoin
		local Remaining = math.clamp(End - os.time(), 0, Information.End and End-Start or (Information.Duration or math.huge))
		local Found = Data.Packs:FindFirstChild(Pack)
		Information.Button.Visible = os.time() > Start and os.time() < End and (not Found or Found.Value < Information.Purchases)
		--Information.Button.Timer.Text = Handler.timer(Remaining,1,4)
		--Information.Frame.Timer.Text = Handler.timer(Remaining,1,4)
	end
end)

-----< UI

for Pack,Information in pairs(Packs) do
	UIHandler.PressDown(Information.Frame.Buy, function()
		local Delay = Information.Delay or 0
		local FirstJoin = Data.FirstJoin.Value + Delay
		local End = Information.End or (FirstJoin + (Information.Duration or math.huge))
		local Remaining = End - os.time()
		local Start = Information.Start or FirstJoin

		if os.time() < Start then
			UIHandler.Notify("This pack is not available yet", "Red")
			return
		end
		if Remaining < 1 then
			UIHandler.Notify("This pack is no longer available", "Red")
			return
		end
		local Found = Data.Packs:FindFirstChild(Pack)
		if Found and Found.Value >= Information.Purchases then
			UIHandler.Notify("You have already bought this pack", "Red")
			return
		end
		UIHandler.PromptPurchase(Settings.DevProductId[Pack], "Product")
	end)

	UIHandler.CreateFrame(Information.Frame)
	UIHandler.ConnectButtonToFrame(Information.Button, Information.Frame)

	Information.Frame.Buy.Center.Price.Text = Handler.productInfo(Settings.DevProductId[Pack], "Product").PriceString
end

-----< 