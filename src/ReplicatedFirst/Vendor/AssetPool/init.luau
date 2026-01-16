--!strict
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

local Module = {
	assetIds = {} :: { string },
}

--[=[
	AssetRegistry
	=============

	Purpose:
		Provide a single, id-based way to fetch assets across the codebase
		without hardcoding paths, while also smoothing out StreamingEnabled
		network usage.

		- All assets originate from a canonical template stored in ServerStorage.
		- When an asset needs to exist on the client, a single template copy is
		  placed in ReplicatedStorage and used as the replication source.
		- Callers use `getAsset` by id (or by instance) and always receive a
		  fresh clone, regardless of where the call originates.

	Behavior:
		- ServerStorage holds canonical templates under `__assetRegister__`.
		- ReplicatedStorage holds replicated templates under `__AssetPool__`.
		- Server:
			* `registerAsset` seeds the registry.
			* `replicateAsset` ensures a template exists in ReplicatedStorage.
			* `getAsset` clones from the replicated template, creating it
			  from the registry on demand if needed.
		- Client:
			* `getAsset` clones from the replicated template if present.
			* If the template is missing, it returns nil and warns.

	Use this when you want:
		- Centralized, id-based asset access instead of hardcoded paths.
		- A consistent way for both server and client to clone assets.
		- Automatic replication of assets that are actually used, reducing
		  redundant downloads under StreamingEnabled.

	Each asset is identified by an "asset id":
		- Derived from attributes listed in `Module.assetIds`.
		- Falls back to `instance.Name` if none are found.
]=]


local assetPool = ReplicatedStorage:FindFirstChild('__AssetPool__') :: Folder?
if not assetPool then
	assetPool = Instance.new('Folder')
	assetPool.Name = '__AssetPool__'
	assetPool.Parent = ReplicatedStorage
end

local assetRegister: Folder? = nil

local function safeIndex(container: Instance?, name: string): Instance?
	if not container then
		return nil
	end
	local ok, result = xpcall(function()
		return (container :: any)[name]
	end, function()
		return nil
	end)
	return ok and result or nil
end

local function getAssetId(instance: Instance): string
	for _, key in Module.assetIds do
		local value = instance:GetAttribute(key)
		if type(value) == 'string' then
			return value
		end
	end
	return instance.Name
end

--[=[
	registerAsset(asset, consumeAsset?)

	Registers a canonical template for `asset` on the server.

	Location:
		Stored under `ServerStorage/__assetRegister__/[assetId]`.

	Parameters:
		asset          - Instance used as the source template.
		consumeAsset   - If true, moves the instance into the registry.
		                 Otherwise stores a clone and leaves `asset` untouched.

	Server-only.
]=]
function Module.registerAsset(asset: Instance, consumeAsset: boolean?)
	if RunService:IsClient() then
		warn('AssetRegistry.registerAsset can only be called on the server')
		return
	end

	if not assetRegister then
		warn('AssetRegistry.registerAsset: assetRegister folder is not available')
		return
	end

	local assetId = getAssetId(asset)
	local existing = safeIndex(assetRegister, assetId)
	if existing then
		return
	end

	local toStore = consumeAsset and asset or asset:Clone()
	toStore.Name = assetId
	toStore.Parent = assetRegister
end

--[=[
	replicateAsset(assetOrAssetId)

	Ensures a replication template for this asset id exists in ReplicatedStorage.

	Location:
		Stored under `ReplicatedStorage/__AssetPool__/[assetId]`.

	Behavior:
		- If already replicated, returns it.
		- Otherwise clones the canonical template from ServerStorage and
		  places the clone in ReplicatedStorage.
		- Returns the replicated template instance.

	Server-only.
]=]
function Module.replicateAsset(assetOrAssetId: any): Instance?
	if RunService:IsClient() then
		warn('AssetRegistry.replicateAsset can only be called on the server')
		return nil
	end

	if not assetPool or not assetRegister then
		warn('AssetRegistry.replicateAsset: registry or pool folder missing')
		return nil
	end

	local assetId = if typeof(assetOrAssetId) == 'Instance'
		then getAssetId(assetOrAssetId :: Instance)
		else (assetOrAssetId :: string)

	local replicated = safeIndex(assetPool, assetId)
	if replicated then
		return replicated
	end

	local registered = safeIndex(assetRegister, assetId)
	if not registered then
		warn(`AssetRegistry.replicateAsset: asset "{assetId}" is not registered`)
		return nil
	end

	local template = registered:Clone()
	template.Name = assetId
	template.Parent = assetPool

	return template
end

--[=[
	getAsset(assetOrAssetId)

	Returns a fresh clone of an asset’s replicated template.

	Server:
		- Clone from replicated template if it exists.
		- If missing, call `replicateAsset` to create the template,
		  then return a fresh clone.

	Client:
		- Clone only if the replicated template exists.
		- If missing, returns nil and warns.

	Returns:
		A new clone of the asset, or nil if unavailable.
]=]
function Module.getAsset(assetOrAssetId: any): Instance?
	local assetId = if typeof(assetOrAssetId) == 'Instance'
		then getAssetId(assetOrAssetId :: Instance)
		else (assetOrAssetId :: string)

	if not assetPool then
		warn('AssetRegistry.getAsset: assetPool folder is not available')
		return nil
	end

	local replicated = safeIndex(assetPool, assetId)
	if replicated then
		return replicated:Clone()
	end

	if RunService:IsServer() then
		local ensured = Module.replicateAsset(assetId)
		if not ensured then
			return nil
		end
		return ensured:Clone()
	end

	warn(`AssetRegistry.getAsset: asset "{assetId}" is not replicated to this client`)
	return nil
end

function Module.isAssetRegistered(assetOrAssetId):boolean
	local assetId = if typeof(assetOrAssetId) == 'Instance'
		then getAssetId(assetOrAssetId :: Instance)
		else (assetOrAssetId :: string)
	
	if RunService:IsServer() then 
		return (safeIndex(assetPool, assetId) or safeIndex(assetRegister, assetId)) ~= nil
	else
		return safeIndex(assetPool, assetId) ~= nil
	end
end

-- bootstrap registry
if RunService:IsServer() then
	assetRegister = ServerStorage:FindFirstChild('__assetRegister__') :: Folder?
	if not assetRegister then
		assetRegister = Instance.new('Folder')
		assetRegister.Name = '__assetRegister__'
		assetRegister.Parent = ServerStorage
	end
end

return Module
