--!strict
local Players       = game:GetService("Players")
local LocalPlayer   = Players.LocalPlayer
local Plots         = workspace.Plots

return function(PossibleDescendant: any)
    if not PossibleDescendant then return nil end

    local PlotFolder = Plots:QueryDescendants(`[$OwnerId = {LocalPlayer.UserId}]`)[1]
    if not PlotFolder then return nil end

    local IsAssembly
    while not IsAssembly do
        print(PossibleDescendant)
        PossibleDescendant = PossibleDescendant.Parent
        IsAssembly = PossibleDescendant.Parent.Parent == PlotFolder

        if not PossibleDescendant or PossibleDescendant == PlotFolder then
            warn ("[FindAssembly] Could not find assembly for descendant:", PossibleDescendant)
            break
        end
    end

    return PossibleDescendant
end
