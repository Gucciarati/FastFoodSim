local Players = game:GetService("Players")
local Plots = workspace.Plots
local LocalPlayer = Players.LocalPlayer


return function(MachineId: string)
	local PlotFolder = Plots:QueryDescendants(`[$OwnerId = {LocalPlayer.UserId}]`)[1]
    if not PlotFolder then return nil end

	local MachineModel = PlotFolder.Furniture:QueryDescendants(`[$Id = {MachineId}]`)[1]
    if not MachineModel then return nil end
	return MachineModel
end
