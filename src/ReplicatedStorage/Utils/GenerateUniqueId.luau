local HttpService = game:GetService("HttpService")

return function(...: { [string]: any }): string
    local Tables = { ... }

    local UniqueId: string
    repeat
        UniqueId = HttpService:GenerateGUID(false)

        local IsUnique = true
        for _, Table in Tables do
            if Table[UniqueId] then
                IsUnique = false
                break
            end
        end
    until IsUnique

    return UniqueId
end
