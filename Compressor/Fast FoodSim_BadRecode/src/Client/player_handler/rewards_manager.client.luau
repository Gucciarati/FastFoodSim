-----< Variables

local PlayerHandler = require(script.Parent)
local RewardsAPI = PlayerHandler.APIs.rewards
local Settings = PlayerHandler.APIs.settings
local Handler = PlayerHandler.APIs.handler
local UIHandler = PlayerHandler.UIHandler
local Functions = PlayerHandler.Functions.Rewards
local Player = PlayerHandler.Player
local Data = PlayerHandler.Data
local Main = PlayerHandler.ScreenGui.main

-----< Daily rewards

local DailyFrame = Main.Frames.Daily

function UpdateDailyRewards()
	local Ready = 0
	local NextReward
	for Day,Reward in pairs(RewardsAPI.DailyRewards) do
		local Frame = DailyFrame.DaysContainer:FindFirstChild("Day"..Day, true)
		if not Frame then continue end
		local Claimed = Data.DailyRewards[Day].Value
		local TimeLeft = Handler.timeFromVersion(86400, nil, Handler.version(86400) - Data.LoginStreak.Value + Day) - os.time()
		NextReward = ((not NextReward or TimeLeft < NextReward) and TimeLeft > 0 and TimeLeft) or NextReward
		Ready += (not Claimed and TimeLeft < 1) and 1 or 0
		Frame.Bottom.ClaimButton.Visible = not Claimed and TimeLeft < 1
		Frame.Bottom.Status.Text = Claimed and "CLAIMED!" or TimeLeft < 1 and "" or "Day "..Day
	end
	Player:SetAttribute("RewardsReady", Ready)
	--Main.Left.DailyRewards.Notification.Label.Text = Ready
	--Main.Left.DailyRewards.Notification.UIAspectRatioConstraint.AspectRatio = 0.5+(#tostring(Ready)*0.5)
	--Main.Left.DailyRewards.Notification.Visible = Ready > 0
	DailyFrame.BottomBar.NextReward.Shadow.Size = UDim2.new(NextReward and (1-Handler.clampOne(NextReward/86400)) or 1,0,1,0)
	DailyFrame.BottomBar.NextReward.Title.Text = NextReward and "Next Reward In: "..Handler.timer(NextReward, 2, 5) or "Completed!"
	DailyFrame.BottomBar.ClaimAll.Visible = NextReward
end

for Day,Reward in pairs(RewardsAPI.DailyRewards) do
	local Frame = DailyFrame.DaysContainer:FindFirstChild("Day"..Day, true)
	if not Frame then continue end
	
	UIHandler.PressDown(Frame.Bottom.ClaimButton, function()
		UIHandler.Notify(Functions.ClaimDailyReward:InvokeServer(Day), "Green")
	end)
	
	Data.DailyRewards[Day].Changed:Connect(UpdateDailyRewards)
end

Handler.changed(Data.PlayTime, UpdateDailyRewards)
UIHandler.CreateProduct(DailyFrame.BottomBar.ClaimAll, Settings.DevProductId["ClaimAllDailyRewards"], "Product")

-----< 