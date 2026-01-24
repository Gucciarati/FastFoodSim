--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GenerateUniqueId = require(ReplicatedStorage.Utils.GenerateUniqueId)
local CFrameSerdes = require(ReplicatedStorage.Utils.CFrameSerdes)

type AdditionalInformation = {
    Name: string,
    PackSize: number,
    Cframe: CFrame?,
}

return function(Data: any, AdditionalInformation: AdditionalInformation)
    local Id = GenerateUniqueId(Data.Assemblies)
    local FoodPackageData = {
        Id = Id,
        Name = AdditionalInformation.Name,
        Amount = AdditionalInformation.PackSize,
        Cframe = if AdditionalInformation.Cframe then CFrameSerdes.Serialize(AdditionalInformation.Cframe) else nil,
    }

    Data.Assemblies[Id] = FoodPackageData
    return FoodPackageData
end