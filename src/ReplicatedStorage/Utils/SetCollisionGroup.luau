--!strict
return function(Instance: any, CollisionGroup: string)

    if Instance:IsA("BasePart") then
        Instance.CollisionGroup = CollisionGroup
    end

     for _, Part in Instance:GetDescendants() do
        if not Part:IsA("BasePart") then continue end
        Part.CollisionGroup = CollisionGroup
    end
end