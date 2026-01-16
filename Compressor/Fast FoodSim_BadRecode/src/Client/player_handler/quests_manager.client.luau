-----< Variables

local PlayerHandler = require(script.Parent)
local GameplayAPI = PlayerHandler.APIs.gameplay
local Settings = PlayerHandler.APIs.settings
local QuestsAPI = PlayerHandler.APIs.quests
local Handler = PlayerHandler.APIs.handler
local UIHandler = PlayerHandler.UIHandler
local Remotes = PlayerHandler.Remotes.Quests
local Player = PlayerHandler.Player
local RealData = PlayerHandler.RealData
local Data = PlayerHandler.Data
local Main = PlayerHandler.ScreenGui.main
local Frame = Main.Frames.Quests

-----< Update

local FrameSample = Handler.sample(Frame.Quests.Sample)
local TrackFrameSample = Handler.sample(Main.QuestsTracking.Quests.Sample)

Handler.heartbeat(function()
	local Index = 0
	
	for _,Type in pairs({"Level", "Quests"}) do
		local TypeInfo = QuestsAPI.Quests[Type]
		local TimeRemaining = Handler.timer(QuestsAPI.TimeRemaining(RealData, Type), 1, 4)
		local CurrentSession = QuestsAPI.GetSession(RealData, Type)
		local Quests = RealData.Quests[Type].Quests
		
		if Type == "Quests" or Type == "Level" then
			for Quest,Info in pairs(Quests) do
				local QuestFrame = Frame.Quests:FindFirstChild(Type..Quest)
				if not QuestFrame then
					QuestFrame = FrameSample:Clone()
					QuestFrame.Name = Type..Quest
					QuestFrame.Parent = Frame.Quests
					UIHandler.PressDown(QuestFrame.Claim, function()
						Remotes.ClaimQuest:FireServer(Type, Quest)
					end)
					UIHandler.PressDown(QuestFrame.Track, function()
						Remotes.TrackQuest:FireServer(Type, Quest)
					end)
					UIHandler.PressDown(QuestFrame.Skip, function()
						Remotes.SkipQuest:FireServer(Type, Quest)
						UIHandler.PromptPurchase(Settings.DevProductId["SkipQuest"], "Product")
					end)
					Handler.onDestroy(Data.Quests[Type].Quests:WaitForChild(Quest), QuestFrame)
				end
				local TrackFrame = Main.QuestsTracking.Quests:FindFirstChild(Type..Quest)
				if not TrackFrame then
					TrackFrame = TrackFrameSample:Clone()
					TrackFrame.Name = Type..Quest
					TrackFrame.Parent = Main.QuestsTracking.Quests
					Handler.onDestroy(Data.Quests[Type].Quests:WaitForChild(Quest), TrackFrame)
				end
				local Claimed = Info.Claimed
				local QuestInfo = QuestsAPI.QuestInfo(RealData, Type, Info.Quest)
				QuestFrame.Visible = QuestInfo and Index <= 3
				TrackFrame.Visible = QuestInfo and Info.Tracking and Index <= 3
				if not QuestInfo then continue end
				Index += 1
				local Progress,Text = QuestInfo.Progress(RealData, Info.Start)
				
				if TypeInfo.AutoClaim and not Claimed and Progress >= 1 then
					Remotes.ClaimQuest:FireServer(Type, tonumber(Quest))
				end
				
				local Icon = QuestInfo.Rewards[1].Type == "XP" and "rbxassetid://138558356985281" or "rbxassetid://136225517640148"
				local Format = (QuestInfo.Rewards[1].Type == "XP" and "%s XP" or "$%s")
				QuestFrame.ImageLabel.Image = Icon
				QuestFrame.ImageLabel.ImageLabel.Image = Icon
				QuestFrame.Label.Text = QuestInfo.Text
				QuestFrame.Amount.Text = Format:format(Handler.abbreviate(QuestInfo.Rewards[1].Amount, "K"))
				QuestFrame.Claim.Visible = Progress >= 1
				QuestFrame.Skip.Visible = Progress < 1
				QuestFrame.Progress.TextLabel.Text = Text
				QuestFrame.Progress.Bar.Size = UDim2.new(Handler.clampOne(Progress),0,1,0)
				TrackFrame.ImageLabel.Image = Icon
				TrackFrame.ImageLabel.ImageLabel.Image = Icon
				TrackFrame.Label.Text = QuestInfo.Text
				TrackFrame.Amount.Text = Format:format(Handler.abbreviate(QuestInfo.Rewards[1].Amount, "K"))
				TrackFrame.Progress.TextLabel.Text = Text
				TrackFrame.Progress.Bar.Size = UDim2.new(Handler.clampOne(Progress),0,1,0)
			end
		end
	end
end)

-----< 