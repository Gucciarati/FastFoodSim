

return function(Parent)
    local ProgressMeter = Parent:FindFirstChild("ProgressMeter") or Instance.new("IntValue")
    ProgressMeter.Name = "ProgressMeter"
    ProgressMeter.Value = 0
    ProgressMeter.Parent = Parent

    return ProgressMeter
end
