--!strict
local Players       = game:GetService("Players")
local LocalPlayer   = Players.LocalPlayer
local Plots         = workspace.Plots

return function(PossibleDescendant: any)
    if not PossibleDescendant then return nil end
    if PossibleDescendant:HasTag("Snap") then return PossibleDescendant end
    
    local PlotFolder = Plots:QueryDescendants(`[$OwnerId = {LocalPlayer.UserId}]`)[1]
    if not PlotFolder then return nil end
    
    
    local IsDescendantOf = PossibleDescendant.IsDescendantOf
    local IsPotentialFurnitureAssembly = IsDescendantOf(PossibleDescendant, PlotFolder.Furniture)
    local IsPotentialFoodAssembly      = IsDescendantOf(PossibleDescendant, PlotFolder.Food)

    local IsPotentialAssembly = IsPotentialFurnitureAssembly or IsPotentialFoodAssembly
    if not IsPotentialAssembly then return nil end
    
    local IdealGrandParents = {
        [PlotFolder.Furniture] = true,
        [PlotFolder.Food]      = true,
    }

    local IsAssembly
    while not IsAssembly do
        PossibleDescendant = PossibleDescendant.Parent
        IsAssembly = IdealGrandParents[PossibleDescendant.Parent]

        if not PossibleDescendant or PossibleDescendant == PlotFolder then
            warn ("[FindAssembly] Could not find assembly for descendant:", PossibleDescendant)
            break
        end
    end

    return PossibleDescendant
end
