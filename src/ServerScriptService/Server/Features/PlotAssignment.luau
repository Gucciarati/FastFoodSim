--!strict
local Players = game:GetService("Players")

local Plots = workspace.Plots

local PlotAssignment = {}

function PlotAssignment.GetVacantPlot(): Folder?
	for _, PlotFolder in Plots:GetChildren() do
		local OwnerId = PlotFolder:GetAttribute("OwnerId")
		if not OwnerId then
			return PlotFolder
		end
	end
	return nil
end

function PlotAssignment.AssignPlot(Player: Player): Folder?
	local PlotFolder = PlotAssignment.GetVacantPlot()
	if not PlotFolder then
		Player:Kick("No vacant plots available")
		return nil
	end

	PlotFolder:SetAttribute("OwnerId", Player.UserId)
	return PlotFolder
end

function PlotAssignment.VacatePlot(Player: Player)
	local PlotFolder = Plots:QueryDescendants(`[$OwnerId = {Player.UserId}]`)[1]
	if PlotFolder then
		PlotFolder:SetAttribute("OwnerId", nil)

		local FoodFolder = PlotFolder:FindFirstChild("Food")
		if FoodFolder then
			FoodFolder:ClearAllChildren()
		end

		local FurnitureFolder = PlotFolder:FindFirstChild("Furniture")
		if FurnitureFolder then
			FurnitureFolder:ClearAllChildren()
		end
	end
end

function PlotAssignment.GetPlayerPlot(Player: Player): Folder?
	return Plots:QueryDescendants(`[$OwnerId = {Player.UserId}]`)[1]
end

function PlotAssignment.GetPlotByUserId(UserId: number): Folder?
	return Plots:QueryDescendants(`[$OwnerId = {UserId}]`)[1]
end

Players.PlayerRemoving:Connect(function(Player: Player)
	PlotAssignment.VacatePlot(Player)
end)

return PlotAssignment
