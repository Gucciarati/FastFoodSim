--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GenerateUniqueId = require(ReplicatedStorage.Utils.GenerateUniqueId)
local CFrameSerdes = require(ReplicatedStorage.Utils.CFrameSerdes)

type AdditionalInformation = {
    Name: string,
    Cframe : CFrame,
    Id: string?,
    Packed: boolean?,
}

return function(PlayerData: any, AdditionalInformation: AdditionalInformation)
    local Id = AdditionalInformation.Id or GenerateUniqueId(PlayerData.Furniture)
    local Packed = if AdditionalInformation.Packed ~= nil then AdditionalInformation.Packed else true

    local FurnitureData = {
        Id = Id,
        Name = AdditionalInformation.Name,
	 	Cframe = CFrameSerdes.Serialize(AdditionalInformation.Cframe),
        Packed = Packed,
	}

    PlayerData.Furniture[Id] = FurnitureData

    return FurnitureData
end
