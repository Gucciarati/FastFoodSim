

return function(Model: Model, Transparency: number)
    for _, Descendant in ipairs(Model:GetDescendants()) do
        local IsValidType = Descendant:IsA("BasePart") or Descendant:IsA("Decal") or Descendant:IsA("ParticleEmitter")
        if not IsValidType then continue end
        
        Descendant.Transparency = Transparency
    end
end