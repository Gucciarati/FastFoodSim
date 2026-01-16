-----< Variables

local UserInputService = game:GetService("UserInputService")
local PlayerHandler = require(script.Parent)
local Handler = PlayerHandler.APIs.handler
local UIHandler = PlayerHandler.UIHandler
local Player = PlayerHandler.Player
local Data = PlayerHandler.Data
local Main = PlayerHandler.ScreenGui.main
local Tutorial = Main.Tutorial
local ArrowParts = workspace:FindFirstChild("Tutorial")
local OwnedRestaurants = workspace:WaitForChild("OwnedRestaurants")
local Restaurant = OwnedRestaurants:WaitForChild(Player.Name)
local Utilities = require(game.ReplicatedStorage.Utilities)
local Tween = Utilities.Tween

local Funnels = game.ReplicatedStorage.Remotes.Data.OnboardingFunnels

-----< Stages

local Dump = {}

local GUID = ""
local Stage = 1
local Stages = {
	[1] = {
		Text = "Welcome to your restaurant! Open the Computer UI.",
		Function = function()
			local Arrow = script.TutorialBeam:Clone()
			Arrow.Attachment0 = (Player.Character or Player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment")
			Arrow.Attachment1 = Restaurant.Model:WaitForChild("Computer Table").Table:WaitForChild("Cube.029").Attachment
			Arrow.Parent = Restaurant.Model:WaitForChild("Computer Table").Computer
			local Highlight = script.TutorialHighlight:Clone()
			Highlight.Parent = Restaurant.Model:WaitForChild("Computer Table").Computer
			table.insert(Dump, Highlight); table.insert(Dump, Arrow)
			local function Check()
				if Main.Frames.Computer:GetAttribute("Open") then return end
				Main.Frames.Computer:GetAttributeChangedSignal("Open"):Wait()
				Check()
			end
			Check()
		end,
	},
	[2] = {
		Text = "Add Buns, Patties, and Papers your cart!",
		Function = function()
			Funnels:FireServer(1)
			local function Check()
				local Market = Main.Frames.Computer.Frames.Market.Container.ShoppingCart.ScrollingFrame
				if Market:FindFirstChild("Burger Buns") and Market:FindFirstChild("Papers") and Market:FindFirstChild("Patties") then
					return
				end
				Market.ChildAdded:Wait()
				Check()
			end
			Check()
		end,
	},
	[3] = {
		Text = "Buy Them and Close the Computer!",
		Function = function()
			Funnels:FireServer(2)
			Main.Frames.Computer.Frames.Market.Container.ShoppingCart.Buy.MouseButton1Down:Wait()
			UIHandler.CloseAllUI()
			Handler.destroy(Restaurant.Model:WaitForChild("Computer Table").Computer:FindFirstChild("TutorialBeam"))
			Handler.destroy(Restaurant.Model:WaitForChild("Computer Table").Computer:FindFirstChild("TutorialHighlight"))
		end,
	},
	[4] = {
		Text = "Bring the Boxes to the Kitchen!",
		Function = function()
			Funnels:FireServer(3)
			local function Check()
				local Hitbox = Restaurant.Model.Tutorial["4"]:WaitForChild("Counter")
				local Parts = workspace:GetPartBoundsInBox(Hitbox.CFrame, Hitbox.Size)
				local Ingredients = Restaurant.Ingredients:GetChildren()
				local Packages = Restaurant.Packages:GetChildren()
				for _,Part in pairs(Parts) do
					for _,Package in pairs(Packages) do
						if not Part:IsDescendantOf(Package) then continue end
						table.remove(Packages, table.find(Packages, Package))
					end
					for _,Ingredient in pairs(Ingredients) do
						if not Part:IsDescendantOf(Ingredient) then continue end
						table.remove(Ingredients, table.find(Ingredients, Ingredient))
					end
					if #Packages <= 0 and #Ingredients <= 0 then return end
				end
				task.wait(0.5)
				Check()
			end
			-- scripts cutscene
			--Utilities.FadeOut(0.4)
			local camera = workspace.CurrentCamera

			local firstPackage = Restaurant.Packages:GetChildren()[1]
			
			while not firstPackage do 
				task.wait(1)
				firstPackage = Restaurant.Packages:GetChildren()[1]
			end
			
			camera.CameraType = Enum.CameraType.Scriptable

			camera.CFrame = CFrame.new((firstPackage:GetPivot() * CFrame.new(0, 60, -100)).Position, firstPackage:GetPivot().Position)
			
			local tuts = {}
			
			-- beams
			for _,Box in pairs(Restaurant.Model.Tutorial["4"].Holograms:GetChildren()) do
				for _,Package in pairs(Restaurant.Packages:GetChildren()) do
					if Box.Name ~= Data.Packages[Package.Name].Item.Value then continue end
					local tut = Box:FindFirstChild("TutorialBeam", true)
					if not tut then 
						task.wait(0.1)
						tut = Box:FindFirstChild("TutorialBeam", true)
					end
					
					if tut then 
						local Att0 = tut.Attachment0
						Att0.Parent = Package:FindFirstChild(Att0.Parent.Name, true)
						table.insert(tuts, tut)
					end
					
				end
				for _,Ingredient in pairs(Restaurant.Ingredients:GetChildren()) do
					if Box.Name ~= Data.Foods[Ingredient.Name].Item.Value then continue end
					local tut = Box:FindFirstChild("TutorialBeam", true)
					if not tut then 
						task.wait(0.1)
						tut = Box:FindFirstChild("TutorialBeam", true)
					end
					
					if tut then 
						local Att0 = tut.Attachment0
						Att0.Parent = Ingredient:FindFirstChild(Att0.Parent.Name, true)
						table.insert(tuts, tut)
					end
				end
			end
			--
			
			--Utilities.FadeIn(0.4)
			
			for _,Package in pairs(Restaurant.Packages:GetChildren()) do
				local Highlight = script.TutorialHighlight:Clone()
				Highlight.Parent = Package
			end
			
			for _,Package in pairs(Restaurant.Ingredients:GetChildren()) do
				local Highlight = script.TutorialHighlight:Clone()
				Highlight.Parent = Package
			end
			
			task.wait(2)
			
			Tween(1, 'easeOutCubic', function(a)
				camera.FieldOfView = 70 - 40 * a
			end)
			
			task.wait(3)
			
			camera.FieldOfView = 70 
			
			camera.CameraType = Enum.CameraType.Custom

			Check()
			
			for _, x in next, tuts do 
				pcall(function()
					x:Destroy()
				end)
			end
			
		end,
	},
	[5] = {
		Text = "Open the boxes!",
		Function = function()
			Funnels:FireServer(4)
			local function Check()
				if #Data.Foods:GetChildren() >= 3 then return end
				Data.Foods.ChildAdded:Wait()
				Check()
			end
			for _,Ingredient in pairs(Restaurant.Ingredients:GetChildren()) do
				if Ingredient:FindFirstChild("TutorialHighlight") then 
					pcall(function()
						Ingredient.TutorialHighlight:Destroy()
					end)
				end
			end
			Check()
		end,
	},
	[6] = {
		Text = "Open the Store!",
		Function = function()
			Funnels:FireServer(5)
			local Att0 = Instance.new("Attachment", Restaurant.Model:WaitForChild("Sign"):WaitForChild("OpenSignBack"))
			local Arrow = script.TutorialBeam:Clone()
			Arrow.Attachment0 = (Player.Character or Player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment")
			Arrow.Attachment1 = Att0
			Arrow.Parent = Att0
			local Highlight = script.TutorialHighlight:Clone()
			Highlight.Parent = Restaurant.Model.Sign
			local function Check()
				if Data.Settings.Open.Value then return end
				Data.Settings.Open.Changed:Wait()
				Check()
			end
			Check()
			Handler.destroy(Restaurant.Model.Sign.OpenSignBack:WaitForChild("Attachment"))
			Handler.destroy(Restaurant.Model.Sign:WaitForChild("TutorialHighlight"))
		end,
	},
	[7] = {
		Text = "Waiting For Customers..",
		Function = function()
			Funnels:FireServer(6)
			local function Check()
				if #Restaurant.Furniture.CashRegisters.Register.Lineup:GetChildren() > 0 then 
					local npc = Restaurant.Furniture.CashRegisters.Register.Lineup:GetChildren()[1].Value 
					
					repeat task.wait() until npc:GetAttribute("IsInRegister")
					
					return 
				end
				Restaurant.Furniture.CashRegisters.Register.Lineup.ChildAdded:Wait()
				Check()
			end
			Check()
		end,
	},
	[8] = {
		Text = "Take their order!",
		Function = function()
			Funnels:FireServer(7)
			local Highlight = script.TutorialHighlight:Clone()
			Highlight.Parent = Restaurant.Furniture.CashRegisters.Register
			local function Check2()
				if #Restaurant.Furniture.CashRegisters.Register.Lineup:GetChildren() < 1 then return end
				Restaurant.Furniture.CashRegisters.Register.Lineup.ChildRemoved:Wait()
				Check2()
			end
			Check2()
			Handler.destroy(Restaurant.Furniture.CashRegisters.Register:FindFirstChild("TutorialHighlight"))
		end,
	},
	[9] = {
		Text = "Place the tray",
		Function = function()
			Funnels:FireServer(8)
			local Hitbox = Restaurant.Model.Tutorial["9"]:WaitForChild("Tray"):WaitForChild("Tray")
			local Beam = Hitbox.TutorialBeam
			local Att = Instance.new("Attachment", Restaurant.Trash:WaitForChild("Tray"):WaitForChild("Drag"))
			Beam.Attachment0 = Att
			local function Check()
				for _,Part in pairs(workspace:GetPartBoundsInBox(Hitbox.CFrame, Hitbox.Size)) do
					if Part.Parent.Parent == Restaurant.Trash and Part.Parent.Name == "Tray" then return end
				end
				task.wait(0.5)
				Check()
			end
			Check()
		end,
	},
	[10] = {
		Text = "Take 1 Paper",
		Function = function()
			Funnels:FireServer(9)
			local function Check()
				if Restaurant.Trash:FindFirstChild("Paper") then return end
				Restaurant.Trash.ChildAdded:Wait()
				Check()
			end
			Check()
		end,
	},
	[11] = {
		Text = "Place the Paper",
		Function = function()
			Funnels:FireServer(10)
			local Hitbox = Restaurant.Model.Tutorial["11"]:WaitForChild("Paper"):WaitForChild("Paper")
			local Beam = Hitbox.TutorialBeam
			local Att = Instance.new("Attachment", Restaurant.Trash:WaitForChild("Paper"):WaitForChild("Drag"))
			Beam.Attachment0 = Att
			local function Check()
				for _,Part in pairs(workspace:GetPartBoundsInBox(Hitbox.CFrame, Hitbox.Size)) do
					if Part.Parent.Parent == Restaurant.Trash and Part.Parent.Name == "Paper" then return end
				end
				task.wait(0.5)
				Check()
			end
			Check()
		end,
	},
	[12] = {
		Text = "Take 1 Bun",
		Function = function()
			Funnels:FireServer(11)
			local function Check()
				if Restaurant.Trash:FindFirstChild("Burger Bun") then return end
				Restaurant.Trash.ChildAdded:Wait()
				Check()
			end
			Check()
		end,
	},
	[13] = {
		Text = "Place the Bun",
		Function = function()
			Funnels:FireServer(12)
			local Beam = script.TutorialBeam:Clone()
			local Att = Instance.new("Attachment", Restaurant.Trash:WaitForChild("Burger Bun"):WaitForChild("Drag"))
			local Att2 = Instance.new("Attachment", Restaurant.Trash:WaitForChild("Paper"):WaitForChild("Drag"))
			Beam.Attachment0 = Att
			Beam.Attachment1 = Att2
			Beam.Parent = Restaurant.Trash["Burger Bun"]
			local function Check()
				if not Restaurant.Trash:FindFirstChild("Burger Bun") then return end
				Restaurant.Trash.ChildRemoved:Wait()
				Check()
			end
			Check()
			Att2:Destroy()
			Beam:Destroy()
		end,
	},
	[14] = {
		Text = "Take 1 Patty",
		Function = function()
			Funnels:FireServer(13)
			local function Check()
				if Restaurant.Trash:FindFirstChild("Raw Patty") then return end
				Restaurant.Trash.ChildAdded:Wait()
				Check()
			end
			Check()
		end,
	},
	[15] = {
		Text = "Place Patty on Grill",
		Function = function()
			Funnels:FireServer(14)
			local Hitbox = Restaurant.Model.Tutorial["15"]:WaitForChild("Patty")
			local Beam = Hitbox.TutorialBeam
			local Att = Instance.new("Attachment", Restaurant.Trash:WaitForChild("Raw Patty"):WaitForChild("Drag"))
			Beam.Attachment0 = Att
			local function Check()
				if not Restaurant.Trash:FindFirstChild("Raw Patty") then return end
				Restaurant.Trash.ChildRemoved:Wait()
				Check()
			end
			Check()
		end,
	},
	[16] = {
		Text = "Flip the Patty when it's ready!",
		Function = function()
			Funnels:FireServer(15)
			local function Check()
				local Occupied
				for _,Part in pairs(Restaurant.Furniture.Cooktop.Cooktop:GetChildren()) do
					if Part:FindFirstChild("Flipped Raw Patty") and Part["Flipped Raw Patty"]:GetAttribute("Occupied") then
						Occupied = Part["Flipped Raw Patty"]
						break
					end
				end
				if Occupied then print("burger placed") Tutorial.Tutorial.Title.Title.Text = "Wait for it to cook.." task.wait(Occupied:GetAttribute("Time")) return end
				task.wait(0.1)
				Check()
			end
			Check()
		end,
	},
	[17] = {
		Text = "Take the Patty",
		Function = function()
			Funnels:FireServer(16)
			local Highlight = script.TutorialHighlight:Clone()
			Highlight.Parent = Restaurant.Trash:WaitForChild("Cooked Patty")
			local function Check()
				if workspace:FindFirstChild("Cooked Patty") then return end
				workspace.ChildAdded:Wait()
				Check()
			end
			Check()
			Handler.destroy(Restaurant.Trash["Cooked Patty"]:FindFirstChild("TutorialHighlight"))
		end,
	},
	[18] = {
		Text = "Put the Patty on the Burger",
		Function = function()
			Funnels:FireServer(17)
			local Beam = script.TutorialBeam:Clone()
			local Att = Instance.new("Attachment", Restaurant.Trash:WaitForChild("Cooked Patty"):WaitForChild("Drag"))
			local Att2 = Instance.new("Attachment", Restaurant.Trash:WaitForChild("Burger"):WaitForChild("Drag"))
			Beam.Attachment0 = Att
			Beam.Attachment1 = Att2
			Beam.Parent = Restaurant.Trash["Cooked Patty"]
			local function Check()
				for _,Trash in pairs(Restaurant.Trash:GetChildren()) do
					if Trash.Name ~= "Burger" or not Trash.Ingredients:FindFirstChild("Cooked Patty") then continue end
					return
				end
				task.wait(0.5)
				Check()
			end
			Check()
			Att2:Destroy()
			Beam:Destroy()
		end,
	},
	[19] = {
		Text = "Wrap the Burger",
		Function = function()
			Funnels:FireServer(18)
			local Highlight = script.TutorialHighlight:Clone()
			Highlight.Parent = Restaurant.Trash:WaitForChild("Burger")
			local function Check()
				for _,Trash in pairs(Restaurant.Trash:GetChildren()) do
					if Trash.Name ~= "Burger" or not Trash:GetAttribute("Wrapped") then continue end
					return
				end
				task.wait(0.5)
				Check()
			end
			Check()
			Handler.destroy(Restaurant.Trash["Burger"]:FindFirstChild("TutorialHighlight"))
		end,
	},
	[20] = {
		Text = "Place the Burger",
		Function = function()
			Funnels:FireServer(19)
			local Beam = script.TutorialBeam:Clone()
			local Att = Instance.new("Attachment", Restaurant.Trash:WaitForChild("Burger"):WaitForChild("Drag"))
			local Att2 = Instance.new("Attachment", Restaurant.Trash:WaitForChild("Tray"):WaitForChild("Drag"))
			Beam.Attachment0 = Att
			Beam.Attachment1 = Att2
			Beam.Parent = Restaurant.Trash["Burger"]
			local Highlight = script.TutorialHighlight:Clone()
			Highlight.Parent = Restaurant.Trash:WaitForChild("Tray")
			local function Check()
				for _,Trash in pairs(Restaurant.Trash:GetChildren()) do
					if Trash.Name ~= "Tray" or not Trash.Ingredients:FindFirstChild("Cooked Patty") then continue end
					return
				end
				task.wait(0.5)
				Check()
			end
			Check()
			Handler.destroy(Att2)
		end,
	},
	[21] = {
		Text = "Take the Tray",
		Function = function()
			Funnels:FireServer(20)
			local function Check()
				if workspace:FindFirstChild("Tray") then return end
				workspace.ChildAdded:Wait()
				Check()
			end
			Check()
			Handler.destroy(Restaurant.Trash["Tray"]:FindFirstChild("TutorialHighlight"))
		end,
	},
	[22] = {
		Text = "Serve the Tray",
		Function = function()
			Funnels:FireServer(21)
			local function Check()
				if not Restaurant.Trash:FindFirstChild("Tray") then return end
				Restaurant.Trash.ChildRemoved:Wait()
				Check()
			end
			Check()
		end,
	},
	[23] = {
		Text = "Wait for Customer",
		Function = function()
			Funnels:FireServer(22)
			local function Check()
				if #Restaurant.DirtyTrays:GetChildren() > 0 then return end
				Restaurant.DirtyTrays.ChildAdded:Wait()
				Check()
			end
			Check()
		end,
	},
	[24] = {
		Text = "Collect Money",
		Function = function()
			Funnels:FireServer(23)
			local function Check()
				if #Restaurant.DirtyTrays:GetChildren() < 1 then return end
				Restaurant.DirtyTrays.ChildRemoved:Wait()
				Check()
			end
			Check()
		end,
	},
	[25] = {
		Text = "Go to Computer",
		Function = function()
			Funnels:FireServer(24)
			local Arrow = script.TutorialBeam:Clone()
			Arrow.Attachment0 = (Player.Character or Player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment")
			Arrow.Attachment1 = Restaurant.Model:WaitForChild("Computer Table").Table:WaitForChild("Cube.029").Attachment
			Arrow.Parent = Restaurant.Model:WaitForChild("Computer Table").Computer
			local Highlight = script.TutorialHighlight:Clone()
			Highlight.Parent = Restaurant.Model:WaitForChild("Computer Table").Computer
			local function Check()
				if Main.Frames.Computer:GetAttribute("Open") then return end
				Main.Frames.Computer:GetAttributeChangedSignal("Open"):Wait()
				Check()
			end
			Check()
			for _,Frame in pairs(Main.Frames.Computer.Frames.Market.Container:GetChildren()) do
				Frame.Visible = Frame.Name == "Furniture" or Frame.Name == "ShoppingCart"
			end
		end,
	},
	[26] = {
		Text = "Purchase x1 Basic Chair",
		Function = function()
			Funnels:FireServer(25)
			local function Check()
				local Market = Main.Frames.Computer.Frames.Market.Container.ShoppingCart.ScrollingFrame
				if Market:FindFirstChild("Basic Chair") then
					return
				end
				Market.ChildAdded:Wait()
				Check()
			end
			Check()
			Main.Frames.Computer.Frames.Market.Container.ShoppingCart.Buy.MouseButton1Down:Wait()
			UIHandler.CloseAllUI()
			Handler.destroy(Restaurant.Model:WaitForChild("Computer Table").Computer:FindFirstChild("TutorialBeam"))
			Handler.destroy(Restaurant.Model:WaitForChild("Computer Table").Computer:FindFirstChild("TutorialHighlight"))
			
		end,
	},
	[27] = {
		Text = "Open Basic Chair Package",
		Function = function()
			Funnels:FireServer(26)
			for _,Package in pairs(Restaurant.Packages:GetChildren()) do
				local Highlight = script.TutorialHighlight:Clone()
				Highlight.Parent = Package
			end
			local function Check()
				if workspace:FindFirstChild("Basic Chair") then return end
				workspace.ChildAdded:Wait()
				Check()
			end
			Check()
		end,
	},
	[28] = {
		Text = "Place Basic Chair on Table",
		Function = function()
			Funnels:FireServer(27)
			local function Check()
				if #Data.Packages:GetChildren() <= 0 then return end
				Data.Packages.ChildRemoved:Wait()
				Check()
			end
			Check()
		end,
	},
	[29] = {
		Text = "You Finished the Tutorial! Have fun!",
		Function = function()
			Funnels:FireServer(28)
			Player.PlayerGui.main.SkipTutorial.Visible = false
			task.wait(3)
			Player.PlayerGui.main.SkipTutorial.Visible = false
		end,
	},
}

-----< Tutorial

function Finish()
	Player.PlayerGui.main.SkipTutorial.Visible = true
	GUID = nil
	Tutorial.Tutorial.Title.Title.MaxVisibleGraphemes = -1
	if Stages[Stage].Function then
		Stages[Stage].Function()
	end
	game.ReplicatedStorage.Remotes.Settings.Setting:FireServer("Tutorial", Stage + 1)
end

local Finished = false
Player.PlayerGui.main.SkipTutorial.MouseButton1Click:Connect(function()
	if Finished then return end
	Finished = true
	game.ReplicatedStorage.Remotes.Tutorial.Skip:FireServer()
end)

game.UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.P then
		if Finished then return end
		Finished = true
		game.ReplicatedStorage.Remotes.Tutorial.Skip:FireServer()
	end
end)

function DisableExtraFrames()
	for Stage,_ in pairs(Stages) do
		local Frame = Tutorial:FindFirstChild(Stage)
		if Frame then
			Frame.Visible = false
		end
	end
	for Stage,_ in pairs(Stages) do
		local Frame = Restaurant.Model.Tutorial:FindFirstChild(Stage)
		if Frame then
			Handler.invisible(Frame)
		end
	end
end

Handler.childAdded(Restaurant.Model.Tutorial, function(Model)
	task.delay(3, function()
		if Model.Name == tostring(Stage) then return end
		Handler.invisible(Model)
	end)
end)

function SetBeam(Value)
	local Success,Character,HRP = Handler.character(Player)
	if not Success or not ArrowParts then return end
	local Arrow = ArrowParts:FindFirstChild(Stage)
	HRP.TutorialBeam.Attachment1 = (Value and Arrow and Arrow.Attachment) or nil
end

function SetExtraFrame()
	local Frame = Tutorial:FindFirstChild(Stage)
	if Frame then
		Frame.Visible = true
	end
	local Frame = Restaurant.Model.Tutorial:FindFirstChild(Stage)
	if Frame then
		Handler.visible(Frame)
	end
end

function Set(Value)
	warn("Called Set")
	print(Value)
	local GivenGUID = Handler.generateGUID()
	GUID = GivenGUID
	Stage = Value
	DisableExtraFrames()
	SetExtraFrame()
	SetBeam(Stages[Data.Settings.Tutorial.Value])
	Tutorial.Tutorial.Title.Title.MaxVisibleGraphemes = 1
	Tutorial.Tutorial.Title.Title.Text = Stages[Stage].Text
	if Stages[Stage].TimePerCharacter then
		for Index = 2,#Stages[Stage].Text do
			task.wait(Stages[Stage].TimePerCharacter)
			if GUID ~= GivenGUID then break end
			Tutorial.Tutorial.Title.Title.MaxVisibleGraphemes = Index
		end
	end
	if GUID ~= GivenGUID then print('guiud mismatch') return end
	Finish()
end

-----< Arrow

if ArrowParts then
	for _,Part in pairs(ArrowParts:GetChildren()) do
		Instance.new("Attachment", Part)
	end
	
	Handler.characterAddedFunction(Player, function(Character, HRP)
		script.TutorialBeam:Clone().Parent = HRP
		HRP.TutorialBeam.Attachment0 = Instance.new("Attachment", HRP)
		SetBeam(Stages[Data.Settings.Tutorial.Value])
	end)
end

-----< Frame

while not Player:GetAttribute('FinishedLoading') do 
	task.wait(1)
end

local OpenPosition = Tutorial.Tutorial.Position
local ClosePosition = OpenPosition + UDim2.new(0,0,1,0)

Tutorial.Tutorial.Position = ClosePosition
Tutorial.Tutorial.Visible = true

function Frame(Value)
	local Valid = Stages[Value]
	SetBeam(Valid)
	DisableExtraFrames()
	Handler.tween(Tutorial.Tutorial, {0.25}, {Position = Valid and OpenPosition or ClosePosition}):Play()
	if Valid then Set(Value) return end
end

Handler.changed(Data.Settings.Tutorial, Frame)


-----< 