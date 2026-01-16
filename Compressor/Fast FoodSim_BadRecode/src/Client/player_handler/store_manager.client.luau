-----< Variables

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PlayerHandler = require(script.Parent)
local UIHandler = PlayerHandler.UIHandler
local Player = PlayerHandler.Player
local Main = PlayerHandler.ScreenGui.main
local Data = PlayerHandler.Data
local GamePasses = Data.GamePasses
local Remotes = PlayerHandler.Remotes.Store
local PotionsAPI = PlayerHandler.APIs.potions
local Settings = PlayerHandler.APIs.settings
local Handler = PlayerHandler.APIs.handler
local Frame = Main.Frames.Store

-----< GamePasses/Product prompts and prices

local StockAPI = PlayerHandler.APIs.stock
local LimitedStock = StockAPI.Live:WaitForChild(Settings.LimitedsVersion)

Handler.descendantAdded(Main.Frames, function(Descendant)
	if not Descendant:IsA("GuiObject") then return end
	local Subscription = Settings.SubscriptionId[Descendant.Name]
	local GamePass = Settings.GamePassId[Descendant.Name]
	local Product = Settings.DevProductId["Gift"..Descendant.Name] or Settings.DevProductId[Descendant.Name]
	
	local Type = (GamePass and "GamePass") or (Product and "Product") or "Subscription"
	local Id = Subscription or GamePass or Product
	
	if Id then
		UIHandler.PressDown(Descendant, function()
			if PotionsAPI.ProductTimes[Descendant.Name] then
				Remotes.Parent.Potions.SelectPotion:FireServer(Descendant.Parent.Parent.Name)
			end
			local Gifting = Handler.gifting(Player)
			local Recipient = Gifting and Players:FindFirstChild(Gifting) or Player
			local CrossServer = Gifting and Recipient == Player
			local GamePasses = Recipient.Data.GamePasses
			local Owned = GamePasses:FindFirstChild(Descendant.Name)
			if not CrossServer and Owned and Owned.Value then UIHandler.Notify("Already owned", "Red") return end
			if Gifting and Type == "Subscription" then UIHandler.Notify("Cannot gift this", "Red") return end
			
			local GiftId = (not Gifting and (Subscription or GamePass)) or Product
			local GiftType = (GiftId == GamePass and "GamePass") or (GiftId == Product and "Product") or "Subscription"
			UIHandler.PromptPurchase(GiftId, GiftType)
		end)
		
		local Limited = Settings.Limiteds[Descendant.Name]
		if Limited then
			Handler.changed(LimitedStock:WaitForChild(Descendant.Name), function(Value)
				Descendant.Parent.Deadstock.Text = Value.."/"..Limited.Limited
				Descendant.Visible = Value > 0
			end)
		end
		
		local PriceLabel = Descendant:FindFirstChild("PriceLabel", true)
		if PriceLabel then
			PriceLabel.Text = Handler.productInfo(Id, Type).PriceString
		end
	end
end)

function UpdateStore()
	local Recipient = Players:FindFirstChild(Handler.gifting(Player) or "")
	local Subscriptions = Recipient and Recipient.Data.Subscriptions
	local GamePasses = Recipient and Recipient.Data.GamePasses
	
	for _,Descendant in pairs(Frame:GetDescendants()) do
		local Owned = Descendant:FindFirstChild("Owned")
		local Buy = Descendant:FindFirstChild("Buy")
		if not Owned or not Buy then continue end
		local Found = GamePasses and GamePasses:FindFirstChild(Descendant.Name)
		Found = Found or (Subscriptions and Subscriptions:FindFirstChild(Descendant.Name))
		Found = Found and Found.Value
		Owned.Visible = Found
		Buy.Visible = not Found
	end
end

--- potions
function Format(Int)
	return string.format("%02i", Int)
end

function convertToHMS(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	return Format(Hours)..":"..Format(Minutes)..":"..Format(Seconds)
end

local PotionUI = Player.PlayerGui:WaitForChild("main"):WaitForChild("Potions")
RunService.RenderStepped:Connect(function(...)
	if workspace:GetAttribute("GoldRush") == true then
		PotionUI["Gold Rush"].Visible = true
		PotionUI["Gold Rush"].Timer.Text = convertToHMS((workspace:GetAttribute("GoldRushTime") - (os.time() - workspace:GetAttribute("GoldRushStart"))))
	else
		PotionUI["Gold Rush"].Visible = false
	end
end)

-----< Scroll buttons

local Shop = Frame.ScrollingFrame
local Tween

function ScrollTo(Target)
	local Target = Shop[Target].AbsolutePosition + Shop.CanvasPosition - Shop.AbsolutePosition
	Tween = Handler.tween(Shop, {0.5}, {CanvasPosition = Vector2.new(Target.X,0)})
	Tween:Play()
end

function CancelTween(Input)
	if not Tween or (Input and Input.UserInputType ~= Enum.UserInputType.MouseWheel and Input.UserInputType ~= Enum.UserInputType.Touch) then return end
	Tween:Cancel()
	Tween = nil
end

for _,Button in pairs(Frame.Buttons:GetChildren()) do
	if not Button:IsA("GuiObject") then continue end
	if not Shop:FindFirstChild(Button.Name) then continue end
	UIHandler.PressDown(Button, function()
		CancelTween()
		ScrollTo(Button.Name)
	end)
end

UserInputService.InputChanged:Connect(CancelTween)

-----< Gifting

local GiftFrame = Main.Frames.Gifting
local PlayerSample,PlayerSampleParent = Handler.sample(GiftFrame.ScrollingFrame.Sample)

Handler.playerAddedFunction(function(Recipient)
	if not RunService:IsStudio() and Recipient == Player then return end
	local NewSample = PlayerSample:Clone()
	NewSample.PlayerIcon.Image = Handler.headshotAsync(Recipient.UserId)
	NewSample.PlayerName.Text = "@"..Recipient.Name
	NewSample.Parent = PlayerSampleParent
	
	Handler.onDestroy(Recipient, NewSample)
	
	UIHandler.ConnectButtonToFrame(NewSample.Gift, Frame)
	UIHandler.PressDown(NewSample.Gift, function()
		Remotes.Gift:FireServer(Recipient.Name)
	end)
end)

local Connections = {}

Handler.changed(Player:WaitForChild("GiftingUsername"), function()
	local RecipientName = Handler.gifting(Player)
	Frame.Top.Gifting.Text = "Gifting: @"..(RecipientName or "")
	Frame.Top.Gifting.Visible = RecipientName
	Frame.Buttons.Gifting.Visible = not RecipientName
	Frame.Buttons.Cancel.Visible = RecipientName
end)

UIHandler.CreateFrame(GiftFrame)
UIHandler.ConnectButtonToFrame(Frame.Buttons.Gifting, GiftFrame)
UIHandler.ConnectButtonToFrame(GiftFrame.Top.Back, Frame)

UIHandler.PressDown(Frame.Buttons.Cancel, function()
	Remotes.Gift:FireServer()
end)

-----< Potions

local PotionsFrame = Main.Potions
local PotionFrames = {}

for _,Potion in pairs(Data.ActivePotions:GetChildren()) do
	local Frame = PotionsFrame:FindFirstChild(Potion.Name)
	if not Frame then continue end
	PotionFrames[Potion] = Frame
end

Handler.heartbeat(function()
	for Potion,Frame in pairs(PotionFrames) do
		Frame.Visible = Potion.Value > 0
		Frame.Timer.Text = Handler.timer(Potion.Value, 1, 5)
	end
end)

-----< 