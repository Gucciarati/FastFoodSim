local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GenerateUniqueId = require(ReplicatedStorage.Util.Registry.GenerateUniqueId)

local PlayerComponents = ServerScriptService.Player.Components
local PlayersComponent = require(PlayerComponents.PlayerComponents)

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)


local Blueprints = InjectLifeCycleSignal {}
Blueprints.Changed = Signal.new()

function Blueprints:add(entity: number, data)
    return TableValue.new(data, function(_, _, _new, _old)
        self.Changed:Fire(entity, data)
    end)
end

function Blueprints:GetFromPlayer(Player: Player)
    local Entity = PlayersComponent.playerInstanceToEntity(Player)
    local BlueprintsData = self.get(Entity)
    return BlueprintsData
end

function Blueprints:Generate(Player: Player, BlueprintName: string, Boost: number?)
    local PlayerBlueprints = self:GetFromPlayer(Player)
    local Id = `BLUEPRINT_{GenerateUniqueId(PlayerBlueprints)}`

    PlayerBlueprints[Id] = {
        Name = BlueprintName,
        Boost = 1 + (Boost or 0),
    }

    return Id
end

return World.factory(Blueprints)
