--!strict
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("main")

local MobileEnabled = Main:FindFirstChild("MobileEnabled")
local MobileButtons = {
	Click = MobileEnabled and MobileEnabled:FindFirstChild("Click"),
	Take = MobileEnabled and MobileEnabled:FindFirstChild("Take"),
	OpenBox = MobileEnabled and MobileEnabled:FindFirstChild("OpenBox"),
	SellPackage = MobileEnabled and MobileEnabled:FindFirstChild("SellPackage"),
	RotateLeft = MobileEnabled and MobileEnabled:FindFirstChild("RotateLeft"),
	RotateRight = MobileEnabled and MobileEnabled:FindFirstChild("RotateRight"),
	CollectTray = MobileEnabled and MobileEnabled:FindFirstChild("CollectTray"),
	MoveFurniture = MobileEnabled and MobileEnabled:FindFirstChild("MoveFurniture"),
	DeleteFurniture = MobileEnabled and MobileEnabled:FindFirstChild("DeleteFurniture"),
}

return {
	["Grab"] = MobileButtons.Click,
	["Open"] = MobileButtons.OpenBox,
	["Pick Up"] = MobileButtons.Click,
	["Take"] = MobileButtons.Take,
	["Take 1x"] = MobileButtons.Take,
	["Sell"] = MobileButtons.SellPackage,
	["Collect"] = MobileButtons.CollectTray,
	["Move"] = MobileButtons.MoveFurniture,
	["Flip"] = MobileButtons.Click,
	["Add Lid"] = MobileButtons.Click,
}
