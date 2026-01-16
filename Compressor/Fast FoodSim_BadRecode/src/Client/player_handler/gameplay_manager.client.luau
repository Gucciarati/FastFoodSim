-----< Variables

local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerHandler = require(script.Parent)
local Functions = PlayerHandler.Functions.Gameplay
local Remotes = PlayerHandler.Remotes.Gameplay
local UIHandler = PlayerHandler.UIHandler
local Assets = PlayerHandler.Assets
local APIs = PlayerHandler.APIs
local GameplayAPI = APIs.gameplay
local Settings = APIs.settings
local Handler = APIs.handler
local RealData = PlayerHandler.RealData
local Camera = PlayerHandler.Camera
local Player = PlayerHandler.Player
local Mouse = PlayerHandler.Mouse
local Data = PlayerHandler.Data
local Main = PlayerHandler.Main
local OwnedRestaurants = workspace:WaitForChild("OwnedRestaurants")
local Restaurant = OwnedRestaurants:WaitForChild(Player.Name)
local Character,HRP,Humanoid
local Dragging

-- Wills variables
local WillsIncrement = 1

-----< Custom playerlist

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

local PlayerlistSample,PlayerlistSampleParent = Handler.sample(Main.Playerlist.ScrollingFrame.Sample)

Handler.childAdded(Players, function(Joined)
	local Data = Handler.waitForData(Joined)
	if not Data then return end
	local Frame = PlayerlistSample:Clone()
	Handler.changed(Data.Cash, function(Value)
		Frame.Cash.Text = string.lower(Handler.abbreviate(Value, "K"))
	end)
	Handler.changed(Data.XP, function(Value)
		Frame.Level.Text = string.format("%02d", GameplayAPI.XPToLevel(Value))
	end)
	Frame.Username.Text = Joined.DisplayName
	Frame.Parent = PlayerlistSampleParent
	Handler.onDestroy(Joined, Frame)
end)

Main.Playerlist.Header.Title.Text = "PLAYERS ["..#Players:GetChildren().."/ 5]"

Handler.childrenChanged(Players, function()
	Main.Playerlist.Header.Title.Text = "PLAYERS ["..#Players:GetChildren().."/ 5]"
end)

-----< Clock

Handler.propertyChanged(Lighting, "ClockTime", function(Value)
	Main.Topbar.Container.Time.Title.Text = GameplayAPI.ClockTime()
end)

-----< Day

Handler.changed(Data.Day, function(Value)
	Main.Topbar.Container.Day.Title.Text = string.format("DAY %02d", Value)
end)

-----< Top stats

function FormatNumber(Number)
	return string.format("%s.%02d", Handler.abbreviate(Number), Number%1*100)
end

Handler.changed(Data.Cash, function(Value)
	Main.Topbar.Container.Cash.Text = "$"..FormatNumber(Value)
	Main.Frames.Computer.Frames.Market.Info.YourMoney.Text = "$"..FormatNumber(Value)
	Main.Frames.Computer.Frames.Expansions.Info.YourMoney.Text = "$"..FormatNumber(Value)
end)

Handler.changed(Data.Popularity, function(Value)
	Main.Topbar.Container.Popularity.Bar.Size = UDim2.new(Handler.clampOne(Value/GameplayAPI.MaxPopularity),0,1,0)
end)

Handler.changed(Data.XP, function(Value)
	local Level = GameplayAPI.XPToLevel(Value)
	local CurrentXP = GameplayAPI.LevelToXP(Level)
	local Target = GameplayAPI.LevelToXP(Level+1) - CurrentXP
	local Max = Level >= GameplayAPI.MaxLevel and " (MAX)" or ""
	Value -= CurrentXP
	Main.Topbar.Container.Level.Bar.Size = UDim2.new(Handler.clampOne(Value/Target),0,1,0)
	Main.Topbar.Container.Level.Title.Text = string.format("Level %02d%s", Level, Max)
end)

-----< First person

local FrameOpen = false
local MouseLocked = true

UserInputService.InputBegan:Connect(function(Input, GPE)
	if GPE or Input.KeyCode ~= Enum.KeyCode.H then return end
	MouseLocked = not MouseLocked
	Handler.setStackable("FrameOpen", "MouseLocked", MouseLocked)
end)

Handler.stackableUpdated("FrameOpen", function(Value)
	FrameOpen = Value
	Main.Modal.Visible = Value
	Main.Cursor.Visible = not Value
	UserInputService.MouseIconEnabled = Value
end, "false", "boolean")

-----< Spawn at restaurant

Handler.characterAddedFunction(Player, function(NewCharacter, NewHRP, NewHumanoid)
	Character,HRP,Humanoid = NewCharacter,NewHRP,NewHumanoid
	HRP:PivotTo(Restaurant:WaitForChild("Spawn").CFrame*CFrame.new(0,3,0))
end)

-----< Interaction system

local Highlight = Instance.new("Highlight")
Highlight.OutlineColor = Color3.fromRGB(255,255,255)
Highlight.FillColor = Color3.fromRGB(255,255,255)
Highlight.FillTransparency = 1
Highlight.OutlineTransparency = 1
Highlight.Parent = workspace

local Interactions = {}
local ForceInteract = nil
local Hovering = nil
local ActionSample,ActionParent = Handler.sample(Main.Cursor.Hovering.Action)
local IngredientSample,IngredientParent = Handler.sample(ActionParent.Ingredients.Sample)

local MouseParams = RaycastParams.new()
MouseParams.FilterType = Enum.RaycastFilterType.Exclude
MouseParams.RespectCanCollide = true

Handler.heartbeat(function()
	MouseParams.FilterDescendantsInstances = {Dragging, Character}
	local Target = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * GameplayAPI.InteractionDistance, MouseParams)
	Target = Target and Target.Instance or nil
	if true then--(Hovering ~= Target and not (Target and Hovering and Target:IsDescendantOf(Hovering))) or not Interactions[Hovering] or ForceInteract then
		Hovering = nil
		Handler.tween(Highlight, {0.15}, {FillTransparency = 1, OutlineTransparency = 1}):Play()
		for _,Button in pairs(Main.MobileEnabled:GetChildren()) do
			if not Button:IsA("GuiObject") then continue end
			Button.Visible = false
		end
		if Target and not ForceInteract then
			local TargetName = Target:GetFullName()
			for Part,Info in pairs(Interactions) do
				if Target == Part or Target:IsDescendantOf(Part) then
					if Hovering then
						local _,HoveringLength = Part:GetFullName():gsub("%.", "")
						local _,CurrentLength = Hovering:GetFullName():gsub("%.", "")
						if CurrentLength > HoveringLength then continue end
					end
					Hovering = Part
					Handler.tween(Highlight, {0.15}, {FillTransparency = 0.9, OutlineTransparency = 0.1}):Play()
				end
			end
		end
	end
	
	if Hovering or ForceInteract then
		local Info = ForceInteract or Interactions[Hovering]
		for _,Child in pairs(ActionParent:GetChildren()) do
			if Child.Name ~= "Action" then continue end
			Handler.destroy(Child)
		end
		for Action,ActionInfo in pairs(Info.Actions) do
			if Player:GetAttribute("Device") == "PC" then
				local ActionLabel = ActionSample:Clone()
				ActionLabel.Text = Handler.keycodeString(ActionInfo.Keybinds[1]).." - "..ActionInfo.Text
				ActionLabel.Parent = ActionParent
			end
			for _,Button in pairs(Main.MobileEnabled:GetChildren()) do
				if not Button:IsA("GuiObject") then continue end
				if not table.find(ActionInfo.Mobile, Button) then continue end
				Button.Visible = true
			end
		end
		if Info.Ingredients then
			for _,Child in pairs(IngredientParent:GetChildren()) do
				if not Child:IsA("GuiObject") or table.find(Info.Ingredients, Child.Name) then continue end
				Handler.destroy(Child)
			end
			for Index,Ingredient in pairs(Info.Ingredients) do
				if not GameplayAPI.Ingredients[Ingredient] or IngredientParent:FindFirstChild(Ingredient) then continue end
				local Frame = IngredientSample:Clone()
				Frame.Icon.Image = GameplayAPI.Ingredients[Ingredient].Icon
				Frame.Name = Ingredient
				Frame.LayoutOrder = Index
				Frame.Parent = IngredientParent
			end
		end
		IngredientParent.Visible = Info.Ingredients
		ActionParent.Title.Text = Info.Title
		Highlight.Adornee = Hovering
	end
	Main.MobileEnabled.Click.Visible = Main.MobileEnabled.Click.Visible or Dragging
	ActionParent.Visible = Hovering or ForceInteract
end)

UserInputService.InputBegan:Connect(function(Input, GPE)
	if GPE then return end
	if Input.UserInputType == Enum.UserInputType.MouseButton1 and Dragging then
		DropItem()
	else
		if (not Hovering and not ForceInteract) then return end
		if ForceInteract then
			for Action,ActionInfo in pairs(ForceInteract.Actions) do
				if table.find(ActionInfo.Keybinds, Input.KeyCode) or table.find(ActionInfo.Keybinds, Input.UserInputType) then
					ActionInfo.Pressed()
				end
			end
		end
		for Part,Info in pairs(Interactions) do
			if Hovering ~= Part then continue end
			for Action,ActionInfo in pairs(Info.Actions) do
				if table.find(ActionInfo.Keybinds, Input.KeyCode) or table.find(ActionInfo.Keybinds, Input.UserInputType) then
					ActionInfo.Pressed()
				end
			end
		end
	end
end)

for _,Button in pairs(Main.MobileEnabled:GetChildren()) do
	if not Button:IsA("GuiObject") then continue end
	UIHandler.PressDown(Button, function()
		if Button.Name == "Click" and Dragging then
			DropItem()
			return
		end
		if not Hovering and not ForceInteract then return end
		if ForceInteract then
			for Action,ActionInfo in pairs(ForceInteract.Actions) do
				if table.find(ActionInfo.Mobile, Button) then
					ActionInfo.Pressed()
				end
			end
		end
		for Part,Info in pairs(Interactions) do
			if Hovering ~= Part then continue end
			for Action,ActionInfo in pairs(Info.Actions) do
				if table.find(ActionInfo.Mobile, Button) then
					ActionInfo.Pressed()
				end
			end
		end
	end)
end

--[[---< Popup

Main.Popup.Visible = false

local GamePass

task.spawn(function()
	while true do
		task.wait(Handler.random(1,3)*60)
		local GamePasses = {}
		for _,GamePass in pairs(Data.GamePasses:GetChildren()) do
			if GamePass.Value or not Settings.GamePassId[GamePass.Name] then continue end
			table.insert(GamePasses, GamePass)
		end
		if #GamePasses < 1 then return end
		GamePass = GamePasses[math.random(#GamePasses)]
		local ProductInfo = Handler.productInfo(Settings.GamePassId[GamePass.Name], "GamePass")
		Main.Popup.Icon.Image = "rbxassetid://"..ProductInfo.IconImageAssetId
		Main.Popup.Buy.Title.Text = ProductInfo.PriceString
		Main.Popup.Top.GamePass.Text = ProductInfo.Name
		Handler.tween(Main.Popup.BottomBar.Bar.Shadow, {0.1}, {Size = UDim2.new(0,0,1,0)}):Play()
		task.wait(0.1)
		Main.Popup.Visible = true
		Handler.tween(Main.Popup.BottomBar.Bar.Shadow, {10}, {Size = UDim2.new(1,0,1,0)}):Play()
		task.wait(10)
		Main.Popup.Visible = false
	end
end)

UIHandler.PressDown(Main.Popup.Close, function()
	Main.Popup.Visible = false
end)

UIHandler.PressDown(Main.Popup.Buy, function()
	if not GamePass then return end
	UIHandler.PromptPurchase(Settings.GamePassId[GamePass.Name], "GamePass")
end)
]]
-----< Employee slots

for _,Frame in pairs(Main.Frames.Computer.Frames.Employees.Container.Purchase:GetChildren()) do
	local Info = GameplayAPI.Employees[Frame.Name]
	if not Info then continue end
	UIHandler.PressDown(Frame.Container.Cash, function()
		if #Data.NPCs:GetChildren() >= Data.EmployeeSlots.Value then
			if Data.EmployeeSlots.Value < #GameplayAPI.EmployeeSlots then
				UIHandler.PromptPurchase(Settings.DevProductId["UnlockEmployeeSlot"], "Product")
			end
			UIHandler.Notify("Not enough employee slots!", "Red")
			return
		end
		Remotes.BuyEmployee:FireServer(Frame.Name)
	end)
	UIHandler.PressDown(Frame.Container.Robux, function()
		if #Data.NPCs:GetChildren() >= Data.EmployeeSlots.Value then
			if Data.EmployeeSlots.Value < #GameplayAPI.EmployeeSlots then
				UIHandler.PromptPurchase(Settings.DevProductId["UnlockEmployeeSlot"], "Product")
			end
			UIHandler.Notify("Not enough employee slots!", "Red")
			return
		end
		UIHandler.PromptPurchase(Settings.DevProductId[Info.Product], "Product")
	end)
end

local SlotSample,SlotParent = Handler.sample(Main.Frames.Computer.Frames.Employees.Container.Slots.Sample)
local EmployeeSlotFrames = {}

for Slot,Level in pairs(GameplayAPI.EmployeeSlots) do
	local Frame = SlotSample:Clone()
	Frame.LockedOverlay.Level.Text = "LVL "..Level
	Frame.Container.Number.Text = Slot
	Frame.Parent = SlotParent
	EmployeeSlotFrames[Slot] = Frame
	UIHandler.PressDown(Frame.Container.Delete, function()
		local Employees = Data.NPCs:GetChildren()
		table.sort(Employees, function(A,B) return A.Time.Value < B.Time.Value end)
		local Employee = Employees[Slot]
		if not Employee then return end
		Remotes.DeleteEmployee:FireServer(Employee.Name)
	end)
end

function UpdateEmployees()
	local Employees = Data.NPCs:GetChildren()
	table.sort(Employees, function(A,B) return A.Time.Value < B.Time.Value end)
	for Slot,LevelRequirement in pairs(GameplayAPI.EmployeeSlots) do
		local Employee = Employees[Slot]
		local Frame = EmployeeSlotFrames[Slot]
		local Locked = Data.EmployeeSlots.Value < Slot
		Frame.LockedOverlay.Visible = Locked
		Frame.LockedOverlay.UnlockEmployeeSlot.Visible = Slot == (Data.EmployeeSlots.Value + 1)
		Frame.Container.EmptyIcon.Visible = not Employee or Locked
		Frame.Container.Icon.Visible = Employee and not Locked
		Frame.Container.Icon.Image = GameplayAPI.Employees[Employee and Employee.Type.Value or "Cashier"].Icon
		Frame.Container.Delete.Visible = Employee and not Locked
		Frame.Container.Number.Visible = not Locked
		Frame.Container.Title.Visible = not Locked
		Frame.Container.Title.Text = Employee and Employee.Type.Value or "[EMPTY]"
	end
	for _,Frame in pairs(Main.Frames.Computer.Frames.Employees.Container.Purchase:GetChildren()) do
		local Info = GameplayAPI.Employees[Frame.Name]
		if not Info then continue end
		local Cost = Info.Price * (1 + (#Data.NPCs:GetChildren() * GameplayAPI.PriceMultiPerEmployee))
		Frame.Container.Cash.Amount.Text = "$"..Handler.abbreviate(Cost, "M")
	end
end

Handler.changed(Data.EmployeeSlots, UpdateEmployees)
Handler.childrenChanged(Data.NPCs, UpdateEmployees)
Handler.changed(Data.XP, UpdateEmployees)

-----< Expansions

local ExpansionFrames = {}

for Expansion,Info in pairs(GameplayAPI.Expansions) do
	local Frame = Main.Frames.Computer.Frames.Expansions.Container.ScrollingFrame[Expansion]
	Frame.Container.Buy.Amount.Text = "$"..FormatNumber(Info.Price)
	Frame.Container.LockedOverlay.Title.Text = "LVL "..("%02d"):format(Info.Lvl or 0)
	ExpansionFrames[Frame] = Info
	
	task.delay(2, function()
		if Data.Expansions.Value >= tonumber(Frame.Name) then
			Frame.Container.LockedOverlay.Visible = false
		end
	end)
	
	UIHandler.PressDown(Frame.Container.Buy, function()
		Remotes.BuyExpansion:FireServer()
	end)
	UIHandler.PressDown(Frame.Container.LockedOverlay.Robux, function()
		Remotes.RobuxExpansion:FireServer(Expansion)
	end)
end

local function UpdateFrames(Data)
	for v, _ in ExpansionFrames do
		local Num = tonumber(v.Name)
		if Data.Expansions.Value >= Num then
			v.Container.LockedOverlay.Visible = false
		end
	end
end

Handler.changed(Data.Expansions, function(Value)
	local Level = GameplayAPI.XPToLevel(Data.XP.Value)
	for Frame,Info in pairs(ExpansionFrames) do
		Frame.Container.Buy.Visible = Level >= Info.Lvl and Value < tonumber(Frame.Name)
	end
	
	UpdateFrames(Data)
end)

Handler.changed(Data.XP, function(Value)
	local Level = GameplayAPI.XPToLevel(Value)
	for Frame,Info in pairs(ExpansionFrames) do
		Frame.Container.LockedOverlay.Visible = Level < Info.Lvl
		Frame.Container.Buy.Visible = Level >= Info.Lvl and Data.Expansions.Value < tonumber(Frame.Name)
	end
end)

-----< Open/Close store

local Computer
local Sign

Handler.childAdded(Restaurant, function(Model)
	if Model.Name ~= "Model" then return end
	if Sign then
		Interactions[Sign] = nil
	end
	Sign = Model.Sign
	Interactions[Sign] = {
		Title = "Sign",
		Actions = {
			["Open"] = {
				Text = Data.Settings.Open.Value and "Close" or "Open",
				Keybinds = {Enum.UserInputType.MouseButton1},
				Mobile = {Main.MobileEnabled.Click},
				Pressed = function()
					Remotes.Parent.Settings.Setting:FireServer("Open", not Data.Settings.Open.Value)
				end,
			}
		},
	}
	if Computer then
		Interactions[Computer] = nil
	end
	Computer = Model["Computer Table"]
	Interactions[Computer] = {
		Title = "Computer",
		Actions = {
			["Open"] = {
				Text = "Open",
				Keybinds = {Enum.UserInputType.MouseButton1},
				Mobile = {Main.MobileEnabled.Click},
				Pressed = function()
					UIHandler.OpenUI(Main.Frames.Computer)
				end,
			}
		},
	}
end)

Handler.changed(Data.Settings.Open, function(Value)
	Main.Topbar.Container.Status.Title.Text = Value and "OPEN" or "CLOSED"
	Main.Topbar.Container.Status.Title.TextColor3 = Value and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
	Interactions[Sign].Actions["Open"].Text = Value and "Close" or "Open"
end)

-----< End of day

local Daily = Main.Frames.EndOfDay
UIHandler.CreateFrame(Daily)

function SetDailyStat(Name, String, Value, Number, Format)
	local Label = Daily.Container:FindFirstChild(Name, true)
	if Number then
		local Color = "rgb(26,204,2)"
		if Value < 0 then
			Value = (Format and FormatNumber(Value) or Value)
			Color = "rgb(204,26,2)"
		else
			Value = "+"..(Format and FormatNumber(Value) or Value)
		end
		Label.Text = String:format(Color, Value)
	else
		Label.Text = String:format(Value)
	end
end

local NewSample,NewParent = Handler.sample(Daily.Container.Items.Sample)

Remotes.EndOfDay.OnClientEvent:Connect(function(Day, Stats)
	local LastLevel = GameplayAPI.XPToLevel(Stats.StartXP)
	local NewLevel = GameplayAPI.XPToLevel(Data.XP.Value)
	SetDailyStat("TotalCustomers", `Total Customers: <font color="rgb(0, 200, 255)">%s</font>`, Stats.Customers)
	SetDailyStat("CustomersServed", `Customers Served: <font color="rgb(0, 200, 255)">%s</font>`, Stats.CustomersServed)
	SetDailyStat("Level", `Level: <font color="%s">%s</font>`, NewLevel - LastLevel, true)
	SetDailyStat("EXP", `EXP: <font color="%s">%s</font>`, Data.XP.Value - Stats.StartXP, true, true)
	SetDailyStat("Popularity", `Popularity: <font color="%s">%s</font>`, Data.Popularity.Value - Stats.StartPopularity, true, true)
	SetDailyStat("Profit", `Profit: <font color="%s">%s</font>`, Data.Cash.Value - Stats.StartCash, true, true)
	SetDailyStat("Balance", `Balance: <font color="rgb(26, 204, 2)">%s</font>`, FormatNumber(Data.Cash.Value))
	Daily.Top.Day.Text = "Day "..Day
	Daily.Container.CloseButton.Title.Text = "Continue (10)"
	Handler.clearAllChildren(NewParent, "GuiObject")
	for Category,Items in pairs(GameplayAPI.Items) do
		for Item,Info in pairs(Items) do
			if not Info.Lvl or Info.Lvl <= LastLevel or Info.Lvl > NewLevel then continue end
			local Frame = NewSample:Clone()
			Frame.Icon.Image = Info.Icon
			Frame.Parent = NewParent
		end
	end
	UIHandler.OpenUI(Daily)
	for Index = 10,1,-1 do
		Daily.Container.CloseButton.Title.Text = "Continue ("..Index..")"
		task.wait(1)
	end
	UIHandler.CloseUI(Daily)
end)

-----< Market

local Market = Main.Frames.Computer.Frames.Market
local MarketSample,MarketParent = Handler.sample(Market.Container.Food.Sample)
local CartSample,CartParent = Handler.sample(Market.Container.ShoppingCart.ScrollingFrame.Sample)

local MarketFrames = {}
local Cart = {}

function UpdateCartTotal()
	local Total = 0
	for _,Info in pairs(Cart) do
		Total += Info.Cost
	end
	Market.Container.ShoppingCart.TotalPrice.Text = `Total: <font color="#11ff00">${FormatNumber(Total)}</font>`
end

--warn("loading cart items")

for Category,Items in pairs(GameplayAPI.Items) do
	for Item,Info in pairs(Items) do
		local Frame = Info.Ignore and Market.Container.Appliances["Gold Cooktop"]:Clone() or MarketSample:Clone()
		Frame.Container.ItemName.Text = Info.Unit.."x "..Item
		Frame.Container.Icon.Image = Info.Icon
		Frame.Container.UnitPrice.Text = "$"..(Info.UnitPrice or 0)
		Frame.Container.LockedOverlay.Title.Text = "LVL "..("%02d"):format(Info.Lvl or 0)
		Frame.LayoutOrder = Info.Order
		Frame.Name = Item
		if Item ~= "Gold Cooktop" and Item ~= "Gold Fryer" and Info.Ignore then
			Frame.Container.Info.Text = "3x Cash"
		end
		MarketFrames[Frame] = Info
		UIHandler.PressDown(Frame.Container.BuyAmount.Increase, function()
			print('hit buyamount increase')
			Frame.Container.BuyAmount.Amount.Text += 1
		end)
		UIHandler.PressDown(Frame.Container.BuyAmount.Reduce, function()
			Frame.Container.BuyAmount.Amount.Text -= 1
		end)
		Frame.Container.Buy.Visible = Info.UnitPrice
		Frame.Container.UnitPrice.Visible = Info.UnitPrice
		Frame.Container.Product.Visible = Info.Product
		Frame.Container.RobuxPrice.Visible = Info.Product and not Info.Ignore
		Handler.propertyChanged(Frame.Container.BuyAmount.Amount, "Text", function(Text, Old)
			local Number = math.clamp(tonumber(Text:gsub("%D+", "") or "") or 1, 1, 100)
			Frame.Container.BuyAmount.Amount.Text = Number
			if Info.UnitPrice then
				Frame.Container.Buy.Amount.Text = "$"..FormatNumber(Number*Info.UnitPrice*Info.Unit)
			end
		end)
		if Info.Product then
			local Price = Handler.productInfo(Settings.DevProductId[Info.Product], "Product").PriceString
			Frame.Container.RobuxPrice.Text = Price
			Frame.Container.Product.Amount.Text = Price
		end
		UIHandler.PressDown(Frame.Container.Product, function()
			UIHandler.PromptPurchase(Settings.DevProductId[Info.Product], "Product")
		end)
		UIHandler.PressDown(Frame.Container.Buy, function()
			warn('clicked buy')
			local InTutorial = Data.Settings.Tutorial.Value <= 3
			print(InTutorial)
			if InTutorial and CartParent:FindFirstChild(Item) then 
				return 
			end
			local CartFrame = CartSample:Clone()
			local GUID = Handler.generateGUID()
			Cart[GUID] = {
				Category = Category,
				Frame = CartFrame,
				Item = Item,
				Amount = 0,
				Cost = 0,
			}
			CartFrame.ItemName.Text = Info.Unit.."x "..Item
			CartFrame.Icon.Image = Info.Icon
			CartFrame.Name = Item
			CartFrame.BuyAmount.Amount.Text = InTutorial and 1 or Frame.Container.BuyAmount.Amount.Text
			
			print(CartFrame:GetFullName())
			
			if not InTutorial then
				UIHandler.PressDown(CartFrame.BuyAmount.Increase, function()
					CartFrame.BuyAmount.Amount.Text += 1
				end)
				UIHandler.PressDown(CartFrame.BuyAmount.Reduce, function()
					CartFrame.BuyAmount.Amount.Text -= 1
				end)
			end
			Handler.propertyChanged(CartFrame.BuyAmount.Amount, "Text", function(Text)
				local Number = math.clamp(tonumber(Text:gsub("%D+", "") or "") or 1, 0, 100)
				CartFrame.BuyAmount.Amount.Text = Number
				CartFrame.ItemCost.Text = "$"..FormatNumber(Number*Info.UnitPrice*Info.Unit)
				Cart[GUID].Cost = Number*Info.UnitPrice*Info.Unit
				Cart[GUID].Amount = Number
				if Number <= 0 then
					Cart[GUID] = nil
					CartFrame:Destroy()
				end
				UpdateCartTotal()
			end)
			CartFrame.Parent = CartParent
		end)
		Frame.Parent = MarketParent.Parent[Category]
	end
	MarketParent.Parent[Category].Visible = false
	UIHandler.PressDown(Market.Info.Container[Category], function()
		for Other,Items in pairs(GameplayAPI.Items) do
			MarketParent.Parent[Other].Visible = Category == Other
		end
	end)
	UIHandler.CreateSearchBar(Market.Info.Search.Input, MarketParent.Parent[Category])
end

MarketParent.Visible = true

function ClearCart()
	for _,Info in pairs(Cart) do
		Info.Frame:Destroy()
	end
	table.clear(Cart)
	UpdateCartTotal()
end

UIHandler.PressDown(Market.Container.ShoppingCart.Delete, ClearCart)

UIHandler.PressDown(Market.Container.ShoppingCart.Buy, function()
	local Packages = 0
	local Total = 0
	for _,Info in pairs(Cart) do
		Total += Info.Cost
		Packages += Info.Amount
	end
	if Data.Cash.Value < Total then
		local Missing = Total - Data.Cash.Value
		local HighestId,HighestAmount = 0,math.huge
		for Product,Info in pairs(Settings.PurchaseRewards) do
			if not Product:match("CashPack") then continue end
			if Info[1].Amount < HighestAmount and Info[1].Amount > Missing then
				HighestId,HighestAmount = Product,Info[1].Amount
			end
		end
		UIHandler.PromptPurchase(Settings.DevProductId[HighestId], "Product")
		UIHandler.Notify("Not enough Cash!", "Red")
		return
	end
	if Packages + #Data.Packages:GetChildren() > 25 then
		UIHandler.Notify("Maximum of 25 Packages!", "Red")
		return
	end
	UIHandler.Audio("PurchaseCart")
	Remotes.Buy:FireServer(Cart)
	ClearCart()
end)

Handler.changed(Data.XP, function(Value)
	local Level = GameplayAPI.XPToLevel(Value)
	local HighestOrderPerFrame = {}
	for Frame,Info in pairs(MarketFrames) do
		if Info.Product then continue end
		if not HighestOrderPerFrame[Frame.Parent] then
			HighestOrderPerFrame[Frame.Parent] = 0
		end
		Frame.Container.LockedOverlay.Visible = Level < Info.Lvl
		Frame.Container.Buy.Visible = Level >= Info.Lvl
		if Level >= Info.Lvl and Info.Order > HighestOrderPerFrame[Frame.Parent] then
			HighestOrderPerFrame[Frame.Parent] = Info.Order
		end
	end
	for Frame,Info in pairs(MarketFrames) do
		if Info.Product then
			Frame.LayoutOrder = HighestOrderPerFrame[Frame.Parent] + 0.5
		else
			if Level >= Info.Lvl then
				Frame.LayoutOrder = Info.Order - HighestOrderPerFrame[Frame.Parent]
			else
				Frame.LayoutOrder = HighestOrderPerFrame[Frame.Parent] + Info.Lvl
			end
		end
	end
end)

-----< Dragging

local DraggingClone
local SnapDragging,Snapping

local PlacementParams = OverlapParams.new()
PlacementParams.FilterType = Enum.RaycastFilterType.Include
PlacementParams.FilterDescendantsInstances = {OwnedRestaurants}

function Hologram(Item)
	for _,Descendant in pairs(Item:GetDescendants()) do
		if Descendant:IsA("BasePart") then
			Descendant.Color = Color3.fromRGB(255,255,255)
			Descendant.Transparency += (1 - Descendant.Transparency) * 0.5
			Descendant.CanQuery = false
			Descendant.CanTouch = false
			Descendant.CanCollide = false
			Descendant.Material = Enum.Material.SmoothPlastic
			if Descendant:IsA("MeshPart") then
				Descendant.TextureID = ""
			end
		elseif Descendant:IsA("Texture") or Descendant:IsA("Decal") or Descendant:IsA("LayerCollector") or Descendant:IsA("SurfaceAppearance") or Descendant:IsA("Beam") then
			Descendant:Destroy()
		end
	end
end

local lastTick = tick()
Handler.renderStepped(function()
	Market.Container.Appliances["Gold Cooktop"].Visible = false
	if Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
		script.Bobbing.Value = CFrame.new(math.sin(time()*10)/4,math.sin(time()*10*2)/10,0)
	else
		script.Bobbing.Value = script.Bobbing.Value:Lerp(CFrame.new(),0.06)
	end
	if Dragging then
		if not Dragging:IsDescendantOf(workspace) then
			StopDragging()
			return
		end
		Dragging:PivotTo(Camera.CFrame * script.HoldOffset.Value * script.Bobbing.Value)
		if tick() - lastTick > .05 then
			lastTick = tick()
			ReplicatedStorage.Remotes.Placement.UpdatePosition:FireServer(Dragging:GetPivot())
		end
		local Ray = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 1000, MouseParams)
		local Pos = Ray and Ray.Position or Vector3.zero
		local X,Y,Z = Camera.CFrame:ToOrientation()
		local CF = CFrame.new(Pos) * CFrame.new(0,Dragging:GetExtentsSize().Y/2+0.05,0) * CFrame.Angles(0,Y,0)
		local CanPlace = true
		local InvalidPart = true
		local NewSnapping
		if Ray and Ray.Instance:HasTag("Snap") then
			local Part = Ray.Instance
			local Snappable = Part:FindFirstChild(Dragging.Name)
			if Snappable and not Snappable:GetAttribute("Occupied") then
				local Requirement = Snappable:GetAttribute("Requirement")
				if not Requirement or Part.Parent.Ingredients:FindFirstChild(Requirement) then
					NewSnapping = Snappable
					InvalidPart = false
				end
			end
		end
		if InvalidPart then
			InvalidPart = false
			local Parts = workspace:GetPartBoundsInBox(CF, DraggingClone:GetExtentsSize(), PlacementParams)
			for _,Part in pairs(Parts) do
				if Part:IsDescendantOf(Dragging) or Part.Name == "Padding" or Part.Name == "" then continue end
				if Part:HasTag("Snap") then
					local Snappable = Part:FindFirstChild(Dragging.Name)
					if Snappable and not Snappable:GetAttribute("Occupied") then
						local Requirement = Snappable:GetAttribute("Requirement")
						if not Requirement or Part.Parent.Ingredients:FindFirstChild(Requirement) then
							InvalidPart = false
							NewSnapping = Snappable
							break
						end
					end
				else
					InvalidPart = true
				end
			end
		end
		if NewSnapping ~= Snapping then
			if SnapDragging then
				SnapDragging:Destroy()
				SnapDragging = nil
			end
			if NewSnapping then
				Handler.invisible(DraggingClone)
				SnapDragging = NewSnapping:Clone()
				Hologram(SnapDragging)
				for _,Descendant in pairs(SnapDragging:GetDescendants()) do
					if Descendant:IsA("BasePart") then
						Descendant.Anchored = true
						Descendant.Transparency = 0.5
					end
				end
				SnapDragging.Parent = workspace
			else
				Handler.visible(DraggingClone)
			end
			Snapping = NewSnapping
		end
		if InvalidPart then
			CanPlace = false
			DraggingClone:SetAttribute("PlacementError", "Not enough room!")
		elseif not Ray or Ray.Distance >= 20 then
			CanPlace = false
			DraggingClone:SetAttribute("PlacementError", "Out of range!")
		else
			DraggingClone:SetAttribute("PlacementError", nil)
		end
		DraggingClone.Drag.CFrame = CF
		for _,Descendant in pairs(DraggingClone:GetDescendants()) do
			if not Descendant:IsA("BasePart") then continue end
			Descendant.Color = CanPlace and Color3.new(1,1,1) or Color3.new(1,0,0)
		end
	end
end)

ReplicatedStorage.Remotes.Placement.UpdatePosition.OnClientEvent:Connect(function(
	Player, Item, CFrame
)
	if Player == game.Players.LocalPlayer then return end
	if not CFrame then return end
	if typeof(CFrame) ~= "CFrame" then return end
	
	Item:PivotTo(CFrame)
end)

function StopDragging()
	if Dragging and Dragging.Parent then
		if Dragging.Name == "Tray" then
			Dragging.NPCBeam.Enabled = false
			Dragging.Drag.NPCOrder.Enabled = true
			Dragging.TrayHitbox.Value.Transparency = 1
		end
		Dragging.Drag.Anchored = false
	end
	if DraggingClone then
		
		DraggingClone:Destroy()
		DraggingClone = nil
	end
	if SnapDragging then
		SnapDragging:Destroy()
		SnapDragging = nil
	end
	Dragging = nil
	ForceInteract = nil
	Snapping = nil
	ReplicatedStorage.Remotes.Placement.StopPlacing:FireServer()
end

function DragItem(Item, Name)
	if Dragging then return end
	local Restaurant = Handler.findFirstAncestorOfChild(Item, OwnedRestaurants)
	if not Restaurant or not Restaurant.Whitelist:FindFirstChild(Player.Name) then
		UIHandler.Notify("You need permissions!", "Red")
		return
	end
	if Item:GetAttribute("Placing") then
		UIHandler.Notify("Someone already grabbing!", "Red")
		return
	end
	ReplicatedStorage.Remotes.Placement.StartPlacing:FireServer(Item)
	warn("start drag")
	Remotes.PickUpItem:FireServer(Item)
	local Size = Item:GetExtentsSize()
	script.HoldOffset.Value = Camera.CFrame:ToObjectSpace(Item:WaitForChild("Drag").CFrame)
	Handler.tween(script.HoldOffset, {0.2}, {Value = CFrame.new(0,-1-Size.Y/2,-2-Size.Z/2)}):Play()
	Dragging = Item
	Dragging.Drag.Anchored = true
	local Clone = Dragging:Clone()
	Hologram(Clone)
	Clone.Drag.Anchored = true
	Clone.Parent = workspace
	DraggingClone = Clone
	MouseParams.FilterDescendantsInstances = {Dragging, Character}
	if Item.Name == "Tray" then
		Item.NPCBeam.Enabled = true
		Item.Drag.NPCOrder.Enabled = false
		Item.TrayHitbox.Value.Transparency = 0.5
	end
end

function DropItem()
	if not Dragging then return end
	if not DraggingClone:GetAttribute("PlacementError") then
		if Snapping then
			local Snap = Snapping.Parent
			local Model = Dragging
			if Snap.Parent.Name == "Tray" then
				local Found = Snap.Parent.FoodsLeft:FindFirstChild(Model.Name)
				if Found then
					local Ingredients = Model.Ingredients:GetChildren()
					local IngredientsLeft = Snap.Parent.FoodsLeft[Model.Name]:GetChildren()
					local IngredientsFound = 0
					for _,IngredientLeft in pairs(IngredientsLeft) do
						for _,Ingredient in pairs(Ingredients) do
							if Ingredient.Name ~= IngredientLeft.Value then continue end
							IngredientsFound += 1
							table.remove(Ingredients, table.find(Ingredients, Ingredient))
							break
						end
					end
					if #Ingredients > 0 or IngredientsFound < #IngredientsLeft then
						UIHandler.Notify("Wrong ingredients!", "Red")
						return
					end
				else
					UIHandler.Notify(Model.Name.." not needed!", "Red")
					return
				end
			end
			local Snappable = Snap:FindFirstChild(Model.Name)
			if not Snappable or Snappable:GetAttribute("Occupied") then return end
			local Requirement = Snappable:GetAttribute("Requirement")
			if Requirement and not Snap.Parent.Ingredients:FindFirstChild(Requirement) then return end
			Interactions[Model] = nil
			Remotes.SnapIngredient:FireServer(Model, Snap)
		else
			Remotes.PlaceItem:FireServer(Dragging, DraggingClone.Drag.CFrame)
			Dragging.Drag.CFrame = DraggingClone.Drag.CFrame
			Dragging.Drag.AssemblyLinearVelocity = Vector3.zero
			Dragging.Drag.AssemblyAngularVelocity = Vector3.zero
		end
		UIHandler.Audio("Drop")
		StopDragging()
	else
		UIHandler.Notify(DraggingClone:GetAttribute("PlacementError"), "Red")
	end
end

Remotes.DragItem.OnClientEvent:Connect(DragItem)
Remotes.PickUpItem.OnClientEvent:Connect(function(Holder, Item)
	if Holder == Player then return end
	--Handler.invisible(Item)
end)
Remotes.PlaceItem.OnClientEvent:Connect(function(Holder, Item)
	if Holder == Player then return end
	--Handler.visible(Item)
end)

-----< Snappables

Handler.tagAdded("Snap", function(Snap)
	if not Snap:IsDescendantOf(workspace.OwnedRestaurants) then return end
	Snap.CanCollide = false
	Snap.CanQuery = true
	Handler.childAdded(Snap, function(Food)
		if Food.Name == "Cooked Patty" then
			Handler.changed(Food.Finished, function(Value)
				if not Snap or not Snap.Parent then return end
				Interactions[Snap.Parent].Actions["Wrap"] = Value and {
					Text = "Wrap Burger",
					Keybinds = {Enum.KeyCode.E},
					Mobile = {Main.MobileEnabled.FinishBurger},
					Pressed = function()
						Food.Wrap:FireServer()
					end,
				} or nil
			end)
		elseif Food.Name == "Cooked Nuggets" then
			Handler.changed(Food.Closeable, function(Value)
				if not Snap or not Snap.Parent then return end
				Interactions[Snap.Parent].Actions["Close"] = Value and {
					Text = "Close Box",
					Keybinds = {Enum.KeyCode.E},
					Mobile = {Main.MobileEnabled.FinishBurger},
					Pressed = function()
						Food.Close:FireServer()
					end,
				} or nil
			end)
		end
		if not Food:GetAttribute("Time") then return end
		local Timer = Food:WaitForChild("Timer")
		Interactions[Food] = {
			Title = Food.Name.." (0%)",
			Actions = {},
		}
		Handler.changed(Timer, function(Value)
			Interactions[Food].Title = Food.Name.." ("..Value.."%)"
			if Food.Name == "Raw Patty" then
				Interactions[Food].Actions["Flip"] = Value >= 100 and {
					Text = "Flip",
					Keybinds = {Enum.UserInputType.MouseButton1},
					Mobile = {Main.MobileEnabled.Click},
					Pressed = function()
						Food.Flip:FireServer()
					end,
				} or nil
			elseif Food.Name == "Empty Soda" then
				Interactions[Food].Actions["Finish"] = Value >= 100 and {
					Text = "Add Lid",
					Keybinds = {Enum.UserInputType.MouseButton1},
					Mobile = {Main.MobileEnabled.Click},
					Pressed = function()
						Food.Finish:FireServer()
					end,
				} or nil
			elseif Food.Name == "Milkshake Cup" then
				Interactions[Food].Actions["Finish"] = Value >= 100 and {
					Text = "Add Lid",
					Keybinds = {Enum.UserInputType.MouseButton1},
					Mobile = {Main.MobileEnabled.Click},
					Pressed = function()
						Food.Finish:FireServer()
					end,
				} or nil
			end
		end)
		if Food.Name == "Empty Soda" then
			Handler.changed(Food:WaitForChild("SelectingFlavor"), function(Value)
				local Flavors = Snap.Parent.Flavors
				if Value then
					(Flavors:FindFirstChild("GreenHighlight") or script.GreenHighlight:Clone()).Parent = Flavors
				else
					Handler.destroy(Flavors:FindFirstChild("GreenHighlight"))
				end
				for _,Flavor in pairs(Snap.Parent.Flavors:GetChildren()) do
					Interactions[Flavor] = Value and {
						Title = "Select "..Flavor.Name,
						Actions = {
							["Select"] = {
								Text = "Select",
								Keybinds = {Enum.UserInputType.MouseButton1},
								Mobile = {Main.MobileEnabled.Click},
								Pressed = function()
									Food.SelectFlavor:FireServer(Flavor.Name)
								end,
							},
						},
					} or nil
				end
			end)
		elseif Food.Name == "Ice Cream Cone" then
			Handler.changed(Food:WaitForChild("SelectingFlavor"), function(Value)
				local Flavors = Snap.Parent.Flavors
				if Value then
					(Flavors:FindFirstChild("GreenHighlight") or script.GreenHighlight:Clone()).Parent = Flavors
				else
					Handler.destroy(Flavors:FindFirstChild("GreenHighlight"))
				end
				for _,Flavor in pairs(Snap.Parent.Flavors:GetChildren()) do
					Interactions[Flavor] = Value and {
						Title = "Select "..Flavor.Name,
						Actions = {
							["Select"] = {
								Text = "Select",
								Keybinds = {Enum.UserInputType.MouseButton1},
								Mobile = {Main.MobileEnabled.Click},
								Pressed = function()
									Food.SelectFlavor:FireServer(Flavor.Name)
								end,
							},
						},
					} or nil
				end
			end)
		elseif Food.Name == "Milkshake Cup" then
			Handler.changed(Food:WaitForChild("CanStart"), function(Value)
				Interactions[Food].Actions["Start"] = Value and {
					Text = "Start Machine",
					Keybinds = {Enum.UserInputType.MouseButton1},
					Mobile = {Main.MobileEnabled.Click},
					Pressed = function()
						Food.Start:FireServer()
					end,
				} or nil
			end)
		end
	end)
end)

-----< Dirty trays

Handler.descendantAdded(OwnedRestaurants, function(Tray)
	local Restaurant = Tray.Parent.Parent
	
	if Tray.Parent.Name == "DirtyTrays" then
		Interactions[Tray] = {
			Title = "Dirty Tray",
			Actions = {
				["Collect"] = {
					Text = "Collect",
					Keybinds = {Enum.KeyCode.E},
					Mobile = {Main.MobileEnabled.CollectTray},
					Pressed = function()
						if Restaurant.Name ~= Player.Name then
							if not Restaurant.Whitelist:FindFirstChild(Player.Name) then
								UIHandler.Notify("You are not whitelisted!", "Red")
								return
							end
						end
						
						Tray.Collect:FireServer()
					end,
				},
			},
		}
	end
end)

-----< Movements

Handler.tagAdded("Movement", function(Movement)
	local Restaurant = Handler.findFirstAncestorOfChild(Movement, OwnedRestaurants)
	if not Restaurant then return end
	local Placement = Handler.findFirstAncestorOfChild(Movement, Handler.findFirstAncestorOfChild(Movement, Restaurant:WaitForChild("Furniture")))
	Placement = Placement and Placement:WaitForChild("Placement", 3)
	if not Placement then
		Placement = Restaurant.Plot
	end
	local Door = Movement:FindFirstChildWhichIsA("BasePart")
	if not Door then
		Door = Movement.ChildAdded:Wait()
	end
	Interactions[Door] = {
		Title = Door.Name,
		Actions = {
			["Open"] = {
				Text = "Open",
				Keybinds = {Enum.UserInputType.MouseButton1},
				Mobile = {Main.MobileEnabled.Click},
				Pressed = function()
					local Open = Movement:GetAttribute("Open")
					Movement:SetAttribute("Open", not Open)
					if Open then
						UIHandler.Audio("DoorClose")
					else
						UIHandler.Audio("DoorOpen")
					end
					Handler.tween(Movement, {0.5}, {CFrame = Placement.CFrame * Movement:GetAttribute(Open and "Closed" or "Opened")}):Play()
				end,
			},
		},
	}
	Handler.attributeChanged(Movement, "Open", function(Value)
		Interactions[Door].Actions.Open.Text = Value and "Close" or "Open"
	end)
end)

-----< Placement system

local Grid = script.Grid
Grid.Parent = workspace
local PlacingParams = RaycastParams.new()
PlacingParams.FilterType = Enum.RaycastFilterType.Exclude
local PlacingCF,PlacingRotation = CFrame.new(),0
local PlacingModel
local Replacing
local Placing

local PlacingHighlight = Instance.new("Highlight")
PlacingHighlight.OutlineColor = Color3.fromRGB(255,255,255)
PlacingHighlight.FillColor = Color3.fromRGB(255,255,255)
PlacingHighlight.FillTransparency = 0.7
PlacingHighlight.OutlineTransparency = 0.4
PlacingHighlight.Enabled = false
PlacingHighlight.Parent = workspace
Handler.heartbeat(function()
	-- toggle visuals
	Grid.Texture.Transparency     = Placing and 0 or 1
	PlacingHighlight.Enabled      = Placing
	Main.MobileEnabled.PlaceItem.ImageColor3 = Color3.fromRGB(255,0,0)

	-- slight pulsing effect while invalid
	Handler.tween(
		PlacingHighlight,
		{0.15},
		{FillColor = Color3.fromRGB(255,0,0), OutlineColor = Color3.fromRGB(255,0,0)}
	):Play()

	-- hide chair / table placement arrows
	for _, t in pairs(Restaurant.Furniture.Tables:GetChildren()) do
		for _, c in pairs(t.Chairs:GetChildren()) do
			c:WaitForChild("Placement").Transparency = 1
		end
	end
	for _, arrow in pairs(CollectionService:GetTagged("Placement")) do
		arrow.Transparency = 1
	end

	-- enable / disable CanQuery on the fly
	for _, desc in pairs(Restaurant.Furniture:GetDescendants()) do
		if desc:IsA("BasePart") and desc.Name == "Placement" then
			desc.CanQuery = Placing
		end
	end
	for _, grp in ipairs({Restaurant.Model.Placement, Restaurant.Model.Unplacement}) do
		for _, part in pairs(grp:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanQuery = Placing
			elseif part:IsA("Texture") then
				part.Transparency = Placing and 0 or 1
			end
		end
	end

	----------------------------------------------------------------
	-- EXIT EARLY IF WE’RE NOT CURRENTLY PLACING ANYTHING
	----------------------------------------------------------------
	if not PlacingModel then return end	

	----------------------------------------------------------------
	-- 🎯  CAST A LONG RAY FROM THE CAMERA TO FIND MOUSE HIT
	----------------------------------------------------------------
	PlacingHighlight.Adornee = PlacingModel
	PlacingParams.FilterDescendantsInstances = {Character, PlacingModel}

	local rayHit = workspace:Raycast(
		Camera.CFrame.Position,
		Camera.CFrame.LookVector * 1000,
		PlacingParams
	)
	if not rayHit then return end

	----------------------------------------------------------------
	-- 🧮  SNAP THE GHOST MODEL TO THE GRID & PREVIEW COLOUR
	----------------------------------------------------------------
	local placementType = GameplayAPI.Items[Placing.Category.Value][Placing.Item.Value].Placement
	local placementPad  = Restaurant.Model.Placement[placementType]:FindFirstChildWhichIsA("BasePart")
	
	warn(placementPad.CFrame)

	-- grid plane
	Grid.CFrame = placementPad.CFrame - Vector3.new(0,0.49,0)

	-- snap point relative to the top‑left corner of the placement area
	local corner   = placementPad.CFrame * CFrame.new(-placementPad.Size/2 * Vector3.new(1,0,1) + Vector3.new(2,0,2))
	local angles   = CFrame.Angles(0, math.rad(PlacingRotation), 0)
	local mouseCF  = CFrame.new(rayHit.Position) * angles
	local offset   = corner:ToObjectSpace(mouseCF)

	local snapCF   = corner * CFrame.new(
		Handler.roundToNumber(offset.X, WillsIncrement),
		0,
		Handler.roundToNumber(offset.Z, WillsIncrement)
	) * (offset - offset.Position)

	----------------------------------------------------------------
	--  SHOW VALID CHAIR SOCKETS WHEN PLACING A CHAIR
	----------------------------------------------------------------
	for _, arrow in pairs(CollectionService:GetTagged("Placement")) do
		arrow.Transparency = 0
	end
	if PlacingModel:GetAttribute("Type") == "Chairs" then
		for _, t in pairs(Restaurant.Furniture.Tables:GetChildren()) do
			for _, c in pairs(t.Chairs:GetChildren()) do
				if c.Chair.Value then continue end
				c.Placement.Color        = Color3.fromRGB(0,255,0)
				c.Placement.Transparency = 0.8
			end
		end
	end

	-- smoothly lerp ghost
	PlacingModel:PivotTo(PlacingModel:GetPivot():Lerp(snapCF, 0.2))
	
	pcall(function()
		PlacingModel:FindFirstChild('Seats'):Destroy()
	end)
	PlacingCF = snapCF

	----------------------------------------------------------------
	-- ✅  SERVER‑SIDE VALIDATION
	----------------------------------------------------------------
	local isValid, _errmsg = GameplayAPI.CanPlaceFurniture(
		RealData,
		Restaurant,
		PlacingModel,
		snapCF,
		placementType,
		Replacing
	)

	-- update colour preview on the “Placement” part
	PlacingModel.Placement.Transparency = 0.8
	PlacingModel.Placement.Color = isValid and Color3.fromRGB(0,255,0)
		or  Color3.fromRGB(255,0,0)

	-- turn the “PLACE” button green if allowed
	if isValid then
		Main.MobileEnabled.PlaceItem.ImageColor3 = Color3.fromRGB(47,255,0)
		Handler.tween(
			PlacingHighlight,
			{0.15},
			{FillColor = Color3.fromRGB(255,255,255), OutlineColor = Color3.fromRGB(255,255,255)}
		):Play()
	end
end)

-----< Foods

Handler.childAdded(workspace:WaitForChild("UnownedRestaurants"), function(Restaurant)
	Handler.destroy(Restaurant:WaitForChild("Model"):WaitForChild("Tutorial", 5))
end)

Handler.childAdded(OwnedRestaurants, function(Restaurant)
	if Restaurant.Name ~= Player.Name then
		Handler.childAdded(Restaurant, function(Model)
			if Model.Name ~= "Model" then return end
			Handler.destroy(Model:WaitForChild("Tutorial", 5))
		end)
	end
	local Data = Handler.waitForData(Players:WaitForChild(Restaurant.Name))
	if not Data then return end
	Handler.uniqueChildAdded(Restaurant:WaitForChild("Furniture"):WaitForChild("Trash"), function(Trash)
		Interactions[Trash] = {
			Title = "Trash",
			Actions = {
				["Trash"] = {
					Text = "Trash Item",
					Keybinds = {Enum.KeyCode.E},
					Mobile = {Main.MobileEnabled.TrashItem},
					Pressed = function()
						if not Dragging then
							UIHandler.Notify("You are not holding anything!", "Red")
							return
						end
						if not Restaurant.Whitelist:FindFirstChild(Player.Name) then
							UIHandler.Notify("You need permissions!", "Red")
							return
						end
						Remotes.TrashItem:FireServer(Dragging)
					end,
				}
			},
		}
	end)
	
	Handler.uniqueChildAdded(Restaurant:WaitForChild("Furniture"):WaitForChild("CashRegisters"), function(CashRegister)
		Handler.childAdded(CashRegister:WaitForChild("Lineup"), function(NPC)
			Handler.propertyChanged(NPC, "Name", function(Name)
				if Name ~= "1" then return end
				local Information = NPC.Value:WaitForChild("Information")
				local InLine = Information:WaitForChild("InLine")
				if not InLine.Value then
					InLine:GetPropertyChangedSignal("Value"):Wait()
				end
				Interactions[CashRegister] = {
					Title = "Cash Register",
					Actions = {
						["Order"] = {
							Text = "Take Order",
							Keybinds = {Enum.UserInputType.MouseButton1},
							Mobile = {Main.MobileEnabled.Click},
							Pressed = function()
								if not Restaurant.Whitelist:FindFirstChild(Player.Name) then
									UIHandler.Notify("You need permissions!", "Red")
									return
								end
								CashRegister:WaitForChild("TakeOrder"):FireServer()
							end,
						}
					},
				}
				Information:WaitForChild("Ordered"):GetPropertyChangedSignal("Value"):Wait()
				Interactions[CashRegister].Actions["Order"] = nil
				UpdateFurnitureBuildMode(CashRegister)
			end)
		end)
	end)
	
	Handler.childAdded(Restaurant.Ingredients, function(Food)
		local Item = Data.Foods[Food.Name].Item.Value
		Interactions[Food] = {
			Title = Item,
			Actions = {
				["Drag"] = {
					Text = "Pick Up",
					Keybinds = {Enum.UserInputType.MouseButton1},
					Mobile = {Main.MobileEnabled.Click},
					Pressed = function()
						UIHandler.Audio("PickUp2")
						DragItem(Food, Item)
					end,
				},
				["Take"] = {
					Text = "Take 1x",
					Keybinds = {Enum.KeyCode.E},
					Mobile = {Main.MobileEnabled.TakeIngredient},
					Pressed = function()
						Remotes.TakeIngredient:FireServer(Food)
					end,
				},
			},
		}

		Handler.changed(Data.Foods[Food.Name].Amount, function(Value)
			Interactions[Food].Title = Item.." ("..Value.."/"..GameplayAPI.Items.Food[Item].Unit..")"
		end)
	end)
	
	Handler.childAdded(Restaurant.Trash, function(Trash)
		Interactions[Trash] = {
			Title = Trash.Name,
			Actions = {
				["Drag"] = {
					Text = "Pick Up",
					Keybinds = {Enum.UserInputType.MouseButton1},
					Mobile = {Main.MobileEnabled.Click},
					Pressed = function()
						UIHandler.Audio("PickUp2")
						DragItem(Trash, Trash.Name)
					end,
				},
			},
			Ingredients = {},
		}
		Handler.propertyChanged(Trash, "Name", function(Value)
			Interactions[Trash].Title = Value
		end)
		if Trash:FindFirstChild("Ingredients") then
			Handler.childrenChanged(Trash.Ingredients, function()
				if not Interactions[Trash] then return end
				Interactions[Trash].Ingredients = {}
				for _,Ingredient in pairs(Trash.Ingredients:GetChildren()) do
					table.insert(Interactions[Trash].Ingredients, Ingredient.Name)
				end
			end)
		end
	end)

	Handler.childAdded(Restaurant.Packages, function(Package)
		local Attachment = Package:WaitForChild("Drag"):WaitForChild("Attachment")
		local Item = Data.Packages[Package.Name].Item.Value
		Interactions[Package] = {
			Title = Item.." Package",
			Actions = {
				["Drag"] = {
					Text = "Pick Up",
					Keybinds = {Enum.UserInputType.MouseButton1},
					Mobile = {Main.MobileEnabled.Click},
					Pressed = function()
						UIHandler.Audio("PickUp2")
						DragItem(Package, Item.." Package")
					end,
				},
				["Open"] = {
					Text = "Open",
					Keybinds = {Enum.KeyCode.E},
					Mobile = {Main.MobileEnabled.OpenBox},
					Pressed = function()
						UIHandler.Audio("OpenBox")
						if Data.Packages[Package.Name].Category.Value == "Food" then
							Remotes.OpenPackage:FireServer(Package)
							return
						end
						Placing = Data.Packages[Package.Name]
						PlacingModel = Assets.Furniture[Placing.Item.Value]:Clone()
						PlacingModel.Parent = workspace
						ForceInteract = {
							Title = "Placing "..Placing.Item.Value,
							Actions = {
								["Place"] = {
									Text = "Place",
									Keybinds = {Enum.UserInputType.MouseButton1},
									Mobile = {Main.MobileEnabled.PlaceItem},
									Pressed = function()
										local PlacementType = GameplayAPI.Items[Placing.Category.Value][Placing.Item.Value].Placement
										local Valid,Message = GameplayAPI.CanPlaceFurniture(RealData, Restaurant, PlacingModel, PlacingCF, PlacementType)
										if not Valid then
											UIHandler.Notify(Message, "Red")
											return
										end
										UIHandler.Audio("Place")
										Remotes.PlaceFurniture:FireServer(Placing, PlacingCF)
										PlacingModel:Destroy()
										Placing,PlacingModel = nil,nil
										ForceInteract = nil
									end,
								},
								["RotateL"] = {
									Text = "Rotate Left",
									Keybinds = {Enum.KeyCode.Q},
									Mobile = {Main.MobileEnabled.RotateLeft},
									Pressed = function()
										PlacingRotation -= 90
									end,
								},
								["RotateR"] = {
									Text = "Rotate Right",
									Keybinds = {Enum.KeyCode.E},
									Mobile = {Main.MobileEnabled.RotateRight},
									Pressed = function()
										PlacingRotation += 90
									end,
								},
								["Cancel"] = {
									Text = "Cancel",
									Keybinds = {Enum.KeyCode.X},
									Mobile = {Main.MobileEnabled.CancelPlacing},
									Pressed = function()
										PlacingModel:Destroy()
										Placing,PlacingModel = nil,nil
										ForceInteract = nil
									end,
								},
							},
						}
					end,
				},
				["Sell"] = {
					Text = "Sell (50%)",
					Keybinds = {Enum.KeyCode.X},
					Mobile = {Main.MobileEnabled.SellPackage},
					Pressed = function()
						Remotes.SellPackage:FireServer(Package)
					end,
				},
			},
		}
	end)
end)

-----< Furniture

local BuildMode = false

function UpdateFurnitureBuildMode(Furniture)
	local Item = Data.Furniture[Furniture.Name].Item.Value
	Interactions[Furniture] = Interactions[Furniture] or (BuildMode and {
		Title = Item,
		Actions = {},
	}) or nil

	if BuildMode then
		Interactions[Furniture].Actions["Move"] = {
			Text = "Move",
			Keybinds = {Enum.KeyCode.C},
			Mobile = {Main.MobileEnabled.MoveFurniture},
			Pressed = function()
				if Furniture:GetAttribute("Occupied") then
					UIHandler.Notify("Item currently occupied!", "Red")
					return
				end
				for _,Descendant in pairs(Furniture:GetDescendants()) do
					if Descendant:IsA("BasePart") then
						Descendant:SetAttribute("MovingTransparency", Descendant.Transparency)
						Descendant.Transparency += (1 - Descendant.Transparency) * 0.5
						Descendant:SetAttribute("MovingCanCollide", Descendant.CanCollide)
						Descendant:SetAttribute("MovingCanQuery", Descendant.CanQuery)
						Descendant:SetAttribute("MovingCanTouch", Descendant.CanTouch)
						Descendant.CanCollide = false
						Descendant.CanQuery = false
						Descendant.CanTouch = false
					end
				end
				Replacing = Furniture
				Placing = Data.Furniture[Furniture.Name]
				PlacingModel = Assets.Furniture[Placing.Item.Value]:Clone()
				PlacingModel.Parent = workspace
				ForceInteract = {
					Title = "Placing "..Placing.Item.Value,
					Actions = {
						["Place"] = {
							Text = "Place",
							Keybinds = {Enum.UserInputType.MouseButton1},
							Mobile = {Main.MobileEnabled.PlaceItem},
							Pressed = function()
								local PlacementType = GameplayAPI.Items[Placing.Category.Value][Placing.Item.Value].Placement
								local Valid,Message = GameplayAPI.CanPlaceFurniture(RealData, Restaurant, PlacingModel, PlacingCF, PlacementType, Replacing)
								if not Valid then
									UIHandler.Notify(Message, "Red")
									return
								end
								UIHandler.Audio("Place")
								Furniture:PivotTo(PlacingCF)
								for _,Descendant in pairs(Furniture:GetDescendants()) do
									if Descendant:IsA("BasePart") then
										Descendant.Transparency = Descendant:GetAttribute("MovingTransparency")
										Descendant.CanCollide = Descendant:GetAttribute("MovingCanCollide")
										Descendant.CanQuery = Descendant:GetAttribute("MovingCanQuery")
										Descendant.CanTouch = Descendant:GetAttribute("MovingCanTouch")
									end
								end
								Remotes.PlaceFurniture:FireServer(Placing, PlacingCF)
								PlacingModel:Destroy()
								Placing,PlacingModel = nil,nil
								ForceInteract = nil
								Replacing = nil
							end,
						},
						["RotateL"] = {
							Text = "Rotate Left",
							Keybinds = {Enum.KeyCode.Q},
							Mobile = {Main.MobileEnabled.RotateLeft},
							Pressed = function()
								PlacingRotation -= 90
							end,
						},
						["RotateR"] = {
							Text = "Rotate Right",
							Keybinds = {Enum.KeyCode.E},
							Mobile = {Main.MobileEnabled.RotateRight},
							Pressed = function()
								PlacingRotation += 90
							end,
						},
						["Grid Size"] = {
							Text = "Grid Size",
							Keybinds = {Enum.KeyCode.U},
							Mobile = {Main.MobileEnabled.GridSize},
							Pressed = function()
								if WillsIncrement == 1 then
									WillsIncrement = .5
								elseif WillsIncrement == .5 then
									WillsIncrement = .1
								else
									WillsIncrement = 1
								end
							end,
						},
						["Cancel"] = {
							Text = "Cancel",
							Keybinds = {Enum.KeyCode.X},
							Mobile = {Main.MobileEnabled.CancelPlacing},
							Pressed = function()
								-- destroy the ghost model
								if PlacingModel then PlacingModel:Destroy() end
								Placing, PlacingModel, ForceInteract, Replacing = nil, nil, nil, nil

								-- **FIX** – fully restore all physics/query flags we disabled
								for _,Descendant in ipairs(Furniture:GetDescendants()) do
									if Descendant:IsA("BasePart") then
										Descendant.Transparency = Descendant:GetAttribute("MovingTransparency")
										Descendant.CanCollide     = Descendant:GetAttribute("MovingCanCollide")
										Descendant.CanQuery       = Descendant:GetAttribute("MovingCanQuery")
										Descendant.CanTouch       = Descendant:GetAttribute("MovingCanTouch")
									end
								end

								-- rebuild the interaction table now that we’re back in normal build‑mode
								for _,Category in ipairs(Restaurant.Furniture:GetChildren()) do
									for _,F in ipairs(Category:GetChildren()) do
										UpdateFurnitureBuildMode(F)
									end
								end
							end,
						},
					},
				}
			end,
		}
		Interactions[Furniture].Actions["Delete"] = {
			Text = "Delete",
			Keybinds = {Enum.KeyCode.X},
			Mobile = {Main.MobileEnabled.DeleteFurniture},
			Pressed = function()
				if Furniture:GetAttribute("Occupied") then
					UIHandler.Notify("Item currently occupied!", "Red")
					return
				end
				Remotes.DeleteFurniture:FireServer(Furniture)
			end,
		}
	elseif Interactions[Furniture] then
		Interactions[Furniture].Actions["Move"] = nil
		Interactions[Furniture].Actions["Delete"] = nil
		if Handler.dictionaryLength(Interactions[Furniture].Actions) <= 0 then
			Interactions[Furniture] = nil
		end
	end
end

UIHandler.PressDown(Main.Topbar.Container.BuildMode, function()
	print('build mode pressed')
	BuildMode = not BuildMode
	Main.Topbar.Container.BuildMode.Label.Text = BuildMode and "ON" or "OFF"
	Main.Topbar.Container.BuildMode.Label.TextColor3 = BuildMode and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
	for _,Category in pairs(Restaurant.Furniture:GetChildren()) do
		for _,Furniture in pairs(Category:GetChildren()) do
			UpdateFurnitureBuildMode(Furniture)
		end
	end
end)

Handler.childAdded(Restaurant.Furniture, function(Category)
	Handler.childAdded(Category, UpdateFurnitureBuildMode)
end)

-----< Reset

UIHandler.PressDown(Main.Frames.Settings.ScrollingFrame.Reset.Reset, function()
	Remotes.Reset:FireServer()
end)

-----< Computer

for _,Button in pairs(Main.Frames.Computer.Sidebar:GetChildren()) do
	if not Button:IsA("GuiButton") then continue end
	Main.Frames.Computer.Frames[Button.Name].Visible = false
	UIHandler.PressDown(Button, function()
		for _,Other in pairs(Main.Frames.Computer.Sidebar:GetChildren()) do
			if not Other:IsA("GuiButton") then continue end
			Main.Frames.Computer.Frames[Other.Name].Visible = Button == Other
		end
	end)
end

Main.Frames.Computer.Frames.Market.Visible = true

-----< Whitelist

local WhitelistSample,WhitelistParent = Handler.sample(Main.Frames.Whitelist.ScrollingFrame.Sample)

Handler.playerAddedFunction(function(Other)
	if Other == Player then return end
	local Frame = WhitelistSample:Clone()
	Frame.PlayerIcon.Image = Handler.headshotAsync(Other.UserId)
	Frame.PlayerName.Text = "@"..Other.Name
	Frame.Name = Other.Name
	Frame.Parent = WhitelistParent
	Handler.onDestroy(Other, Frame)
	UIHandler.PressDown(Frame.AddButton, function()
		Remotes.SetWhitelist:FireServer(Other, true)
	end)
	UIHandler.PressDown(Frame.RemoveButton, function()
		Remotes.SetWhitelist:FireServer(Other, nil)
	end)
end)

Handler.childrenChanged(Restaurant.Whitelist, function()
	for _,Frame in pairs(WhitelistParent:GetChildren()) do
		if not Frame:FindFirstChild("PlayerName") then continue end
		local Whitelisted = Restaurant.Whitelist:FindFirstChild(Frame.Name)
		Frame.AddButton.Visible = not Whitelisted
		Frame.RemoveButton.Visible = Whitelisted
	end
end)

local WhitelistTeleport = Main.Frames.WhitelistTeleport
UIHandler.CreateFrame(WhitelistTeleport)
local TeleportTo

Remotes.TeleportPrompt.OnClientEvent:Connect(function(Other)
	TeleportTo = OwnedRestaurants:FindFirstChild(Other.Name)
	WhitelistTeleport.Description.Text = Other.Name.." has whitelisted you! Would you like to teleport to their restaurant?"
	UIHandler.OpenUI(WhitelistParent)
end)

UIHandler.PressDown(WhitelistTeleport.Buttons.No, function()
	UIHandler.CloseUI(WhitelistParent)
end)

UIHandler.PressDown(WhitelistTeleport.Buttons.Yes, function()
	UIHandler.CloseUI(WhitelistParent)
	HRP:PivotTo(TeleportTo:WaitForChild("Spawn").CFrame*CFrame.new(0,3,0))
end)

-----< Group reward

UIHandler.ConnectKeybind(Main.GroupRewards, Enum.KeyCode.L)

UIHandler.PressDown(Main.GroupRewards, function()
	if not Player:WaitForChild("Group").Value then
		UIHandler.Notify("You are not in the group", "Red")
		return
	end
	if Data.ClaimedGroupReward.Value then
		UIHandler.Notify("Already claimed", "Red")
		return
	end
	Remotes.ClaimGroup:FireServer()
end)

-----< Restaurant name

local LOADING_DURATION = game:GetService('RunService'):IsStudio() and 2 or 6.5

Camera.CameraType = Enum.CameraType.Scriptable
Camera.CFrame = workspace.CameraPoints:WaitForChild("1").CFrame

UIHandler.CreateFrame(Main.Loading)
UIHandler.OpenUI(Main.Loading)
UIHandler.DisableOpen()
Handler.setStackable("HUD", "LoadingScreen", false)

Main.Loading.Input.Input.Text = Player.Name .. "'s Restaurant" -- default

Handler.tween(Main.LoadingCode, {1}, {BackgroundTransparency = 1}):Play()

task.delay(0.1, function()
	Handler.tween(Camera, {LOADING_DURATION}, {CFrame = workspace.CameraPoints:WaitForChild("2").CFrame}):Play()
	Handler.tween(Main.Loading.Bar.Bar, {LOADING_DURATION}, {Size = UDim2.new(1,0,1,0)}):Play()
	Handler.tween(Main.Loading.Bar.Value, {LOADING_DURATION}, {Value = 100}):Play()
	task.wait(0.5)
	Main.LoadingCode.Visible = false
	task.wait(LOADING_DURATION - 0.5)
	
	local originalRestaurantName = Data.Settings.RestaurantName.Value
	
	if not originalRestaurantName or originalRestaurantName == "" or originalRestaurantName == "Empty Restaurant" then -- 
		Main.Loading.Bar.Visible = false
		Main.Loading.Input.Visible = true
	else
		UIHandler.EnableOpen()
		UIHandler.CloseUI(Main.Loading)
		Handler.setStackable("HUD", "LoadingScreen", true)
		Camera.CameraType = Enum.CameraType.Custom
	end
end)

Handler.changed(Main.Loading.Bar.Value, function(Value)
	Main.Loading.Bar.Percent.Text = ("%0.02f%%"):format(Value)
end)

UIHandler.PressDown(Main.Loading.Input.Confirm, function()
	if string.len(Main.Loading.Input.Input.Text) == 0 then 
		Main.Loading.Input.Input.Text = Player.Name .. "'s Restaurant"
	end
	UIHandler.EnableOpen()
	UIHandler.CloseUI(Main.Loading)
	Handler.setStackable("HUD", "LoadingScreen", true)
	Remotes.Parent.Settings.Setting:FireServer("RestaurantName", Main.Loading.Input.Input.Text)
	Camera.CameraType = Enum.CameraType.Custom
end)

Handler.changed(Data.Settings.RestaurantName, function(Value)
	Main.Frames.Settings.ScrollingFrame.RestaurantName.TextBox.Text = Value
end)

Main.Frames.Settings.ScrollingFrame.RestaurantName.TextBox.FocusLost:Connect(function()
	Remotes.Parent.Settings.Setting:FireServer("RestaurantName", Main.Frames.Settings.ScrollingFrame.RestaurantName.TextBox.Text)
end)

-----< Open frames

task.wait(1)

while FrameOpen do
	task.wait()
end

task.wait(0.3)

if Player:GetAttribute("RewardsReady") > 0 then
	UIHandler.OpenUI(Main.Frames.Daily)
end

task.wait(1)

while FrameOpen do
	task.wait()
end

task.wait(0.3)

if Data.Joins.Value <= 2 then
	UIHandler.OpenUI(Main.Frames.StarterPack)
end

Remotes.FinishedLoading:FireServer()
Player:SetAttribute('FinishedLoading', true)

-----< 