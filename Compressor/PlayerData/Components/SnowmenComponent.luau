--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InjectLifeCycleSignal = require(ReplicatedStorage.InjectLifeCycleSignal)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)
local World = require(ServerScriptService.World)

local PlayerComponents = ServerScriptService.Player.Components
local PlayersComponent = require(PlayerComponents.PlayerComponents)

local GenerateUniqueId = require(ReplicatedStorage.Util.Registry.GenerateUniqueId)

local Snowmen = InjectLifeCycleSignal({})
Snowmen.Changed = Signal.new()

function Snowmen:add(Entity: number, Data: any)
	return TableValue.new(Data, function(_Table, Key, New, Old)
		if New == Old then return end
		Snowmen.Changed:Fire(Entity, Key, New)
	end)
end

function Snowmen:GetFromPlayer(Player: Player)
	local Entity = PlayersComponent.playerInstanceToEntity(Player)
	local SnowmenData = self.get(Entity)
	return SnowmenData
end

function Snowmen:Generate(Player: Player, SnowmanName: string, Boost: number?)
	local PlayerSnowmen = self:GetFromPlayer(Player)
	local Id = `SNOWMAN_{GenerateUniqueId(PlayerSnowmen)}`

	PlayerSnowmen[Id] = {
		Name = SnowmanName,
		Boost = 1 + (Boost or 0),
		CreatedAt = DateTime.now().UnixTimestampMillis,
	}

	return Id
end

return World.factory(Snowmen)
