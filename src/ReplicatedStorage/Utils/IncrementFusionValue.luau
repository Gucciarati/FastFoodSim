local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion            = require(ReplicatedStorage.Packages.Fusion)
local Peek              = Fusion.peek

return function(FusionValue: any, IncrementBy: number, MinValue: number?, MaxValue: number?)
    local CurrentValue = Peek(FusionValue)
    local NewValue = CurrentValue + IncrementBy

    if MinValue and NewValue < MinValue then
        NewValue = MinValue
    end

    if MaxValue and NewValue > MaxValue then
        NewValue = MaxValue
    end

    FusionValue:set(NewValue)
end