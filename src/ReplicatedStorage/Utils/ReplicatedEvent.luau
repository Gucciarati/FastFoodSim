--!strict

local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local LemonSignal = require(game:GetService("ReplicatedFirst").Vendor.LemonSignal)

export type Event<T...> = {
	Fire: (self: Event<T...>, T...) -> (),
	FireSome: (self: Event<T...>, players: { Player }, T...) -> (),
	SetAllowClientReplication: (self: Event<T...>, allowed: boolean) -> (),

	Connect: (self: Event<T...>, handler: (...any) -> ()) -> LemonSignal.Connection<T...>,
	Once: (self: Event<T...>, handler: (...any) -> ()) -> LemonSignal.Connection<T...>,
	Wait: (self: Event<T...>) -> T...,
	Destroy: (self: Event<T...>) -> (),
	networkId: string,
}

local ReplicatedEvent = {}

-- Internal handshake token so we know when at least one client is listening.
local HANDSHAKE_TOKEN = "\1_REPLICATED_EVENT_HANDSHAKE_\0"

-- Client -> Server payload token so we can distinguish actual messages from handshake.
local C2S_TOKEN = "\1_REPLICATED_EVENT_C2S_\0"

--[[
	ReplicatedEvent.new
	===================

	**Description**
	Drop-in replacement for plain signals / bindables that also replicate.
	Supports server -> client replication and optional client -> server replication.

	**Params**
	- [name] [string] -- Stable event name used to locate the RemoteEvent on both server and client.
	- [allowClientReplication] [true?] -- If true, allows client -> server replication for this event.
		When omitted or falsey, client -> server messages are debounced on the server.

	Behavior notes:
	- Server:
		- Creates a RemoteEvent parented to this script, named with `name`.
		- .Fire(...) replicates to all clients only after at least one client has handshaken for this name.
		- .FireSome(players, ...) replicates to specific clients only after handshake.
		- When allowClientReplication is enabled:
			- Accepts client -> server messages and fires local listeners.
	- Client:
		- Does not create the RemoteEvent.
		- Hooks the RemoteEvent on construction (waiting via ChildAdded if needed).
		- Handshakes once so the server can enable server -> client replication.
		- .Fire(...) sends to the server.

	Replication payload rules:
	- If client replication is enabled, sender is ALWAYS appended as the last argument to local listeners:
		- Server-local fire: (...payload, nil)
		- Server received from client: (...payload, player)
		- Client received from server: (...payload, nil)

	Safety:
	- Remote receives never call Fire. They route through an internal local-only emitter
	  to avoid recursive client <-> server ping pong.
	- Server has to explicitely opt-in to client -> server replication.
]]
function ReplicatedEvent.new<T...>(name: string, allowClientReplication: true?): Event<T...>
	if type(name) ~= "string" or name == "" then
		error("ReplicatedEvent.new(name: string) requires a non-empty string name", 2)
	end

	local remote: RemoteEvent
	local hasAnyClientHooked = false
	local connections: { RBXScriptConnection } = {}

	--\\ Server-side gate for accepting client -> server replication
	local allowClientReplication = allowClientReplication == true

	if isServer then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = script
	else
		remote = nil :: any
	end

	local signal = LemonSignal.new()
	local remoteHookedClient = false
	local remoteHookedServer = false

	--\\ Append sender to the end of varargs safely.
	local function fireSignalWithSender(sender: Player?, ...: any)
		local packed = table.pack(...)
		packed.n += 1
		packed[packed.n] = sender
		signal:Fire(table.unpack(packed, 1, packed.n))
	end

	local function disconnectAllConnections()
		for _, conn in connections do
			conn:Disconnect()
		end
		table.clear(connections)
	end

	-- Internal emit that can optionally replicate.
	-- Sender is appended as the final argument for all local listeners.
	local function fireInternal(fromNetwork: boolean, sender: Player?, ...: any)
		fireSignalWithSender(sender, ...)

		-- Network receives never re-send.
		if fromNetwork then
			return
		end

		if isServer then
			if hasAnyClientHooked then
				remote:FireAllClients(...)
			end
		elseif isClient then
			if remote then
				(remote :: RemoteEvent):FireServer(C2S_TOKEN, ...)
			else
				warn(`[ReplicatedEvent:{name}] Client attempted to replicate before RemoteEvent was bound; ignoring`)
			end
		end
	end

	local function bindRemoteClient(re: RemoteEvent)
		if remoteHookedClient then
			return
		end
		remoteHookedClient = true
		remote = re

		disconnectAllConnections()

		table.insert(connections, re.OnClientEvent:Connect(function(...: any)
			fireInternal(true, nil, ...)
		end))

		re:FireServer(HANDSHAKE_TOKEN)
	end

	local function ensureRemoteHookedClient()
		if not isClient or remoteHookedClient then
			return
		end

		local existing = script:FindFirstChild(name)
		if existing and existing:IsA("RemoteEvent") then
			bindRemoteClient(existing :: RemoteEvent)
			return
		end

		table.insert(connections, script.ChildAdded:Connect(function(child)
			if child.Name == name and child:IsA("RemoteEvent") then
				bindRemoteClient(child :: RemoteEvent)
			end
		end))
	end

	local function bindRemoteServer(re: RemoteEvent)
		if remoteHookedServer then
			return
		end
		remoteHookedServer = true

		table.insert(connections, re.OnServerEvent:Connect(function(player: Player, first: any, ...: any)
			if first == HANDSHAKE_TOKEN then
				hasAnyClientHooked = true
				return
			end

			if first == C2S_TOKEN then
				if not allowClientReplication then
					return
				end

				-- Server listeners receive (...payload, player)
				fireInternal(true, player, ...)
				return
			end

			warn(`[ReplicatedEvent:{name}] Received unexpected client payload; ignoring`)
		end))
	end

	if isServer then
		bindRemoteServer(remote)
	else
		ensureRemoteHookedClient()
	end

	-- API

	local function Fire(self: Event<T...>, ...: any)
		fireInternal(false, nil, ...)
	end

	local function FireSome(self: Event<T...>, players: { Player }, ...: any)
		fireSignalWithSender(nil, ...)

		if not isServer then
			warn(`[ReplicatedEvent:{name}] FireSome called on client; ignoring`)
			return
		end

		if hasAnyClientHooked then
			for _, player in players do
				remote:FireClient(player, ...)
			end
		end
	end

	local function SetAllowClientReplication(self: Event<T...>, allowed: boolean)
		if not isServer then
			warn(`[ReplicatedEvent:{name}] SetAllowClientReplication called on client; ignoring`)
			return
		end

		allowClientReplication = allowed
	end

	local function Connect(self: Event<T...>, handler: (...any) -> ()): LemonSignal.Connection<T...>
		if isClient then
			ensureRemoteHookedClient()
		end
		return signal:Connect(handler)
	end

	local function Once(self: Event<T...>, handler: (...any) -> ()): LemonSignal.Connection<T...>
		if isClient then
			ensureRemoteHookedClient()
		end
		return signal:Once(handler)
	end

	local function Wait(self: Event<T...>): ...any
		if isClient then
			ensureRemoteHookedClient()
		end
		return signal:Wait()
	end

	local function Destroy(self: Event<T...>)
		signal:Destroy()
		disconnectAllConnections()

		if isServer and remote and remote.Parent ~= nil then
			remote:Destroy()
		end
	end

	local self: Event<T...> = {
		Fire = Fire,
		FireSome = FireSome,
		SetAllowClientReplication = SetAllowClientReplication,

		Connect = Connect,
		Once = Once,
		Wait = Wait,
		Destroy = Destroy,
		networkId = name,
	}

	return self
end

return ReplicatedEvent