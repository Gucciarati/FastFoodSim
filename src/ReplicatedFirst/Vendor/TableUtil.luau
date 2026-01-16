--!strict

export type RandomFn = (min: number, max: number) -> number

local module = {}
local RNG = Random.new()

--==================================================
-- Shared functions
--==================================================

function module.compareLexic(a: string, b: string)
	local aLength, bLength = string.len(a), string.len(b)
	if aLength ~= bLength then
		return aLength < bLength
	end
	for index = 1, math.max(aLength, bLength) do
		local aByte = string.byte(string.sub(a, index, index))
		local bByte = string.byte(string.sub(b, index, index))
		if aByte ~= bByte then
			return aByte < bByte
		end
	end
	return true
end

function module.forEach(t: {[any]: any}, callback: (k:any, v:any) -> ())
	for k, v in t do
		callback(k, v)
	end
end

function module.map<K, V>(t: {[K]: V}, callback : (k: K, v: V) -> any): {any}
	local result = {}
	for k, v in t do
		result[k] = callback(v, k)
	end
	return result
end
function module.deepFreeze(tbl: {[any]: any}): {[any]: any}
	table.freeze(tbl)
	for _, v in tbl do
		if type(v) == "table" then
			module.deepFreeze(v)
		end
	end
	return tbl
end

function module.deepCopy(tbl: {[any]: any}): {[any]: any}
	local copy = table.clone(tbl)
	for k, v in copy do
		copy[k] = if type(v) == "table" then module.deepCopy(v) else v
	end
	return copy
end

function module.pick<T>(tbl: {[any]: T}, seed: number?): T
	local values = module.values(tbl)
	return values[Random.new(seed or os.clock()):NextInteger(1, #values)]
end

function module.pickKey<T>(tbl: {[T]: any}, seed: number?): T
	local keys = {}
	for key in tbl do
		table.insert(keys, key)
	end
	return keys[Random.new(seed or os.clock()):NextInteger(1, #keys)]
end

function module.weightedPick<T>(weightsList: {[T]: number}, seed: number?): T
	local sumOfAllWeights = 0
	for _, weight in weightsList do
		sumOfAllWeights += weight
	end

	local randomNumber = Random.new(seed):NextNumber(0.1, sumOfAllWeights)
	sumOfAllWeights = 0

	for key, weight in weightsList do
		sumOfAllWeights += weight
		if randomNumber <= sumOfAllWeights then
			return key
		end
	end

	return
end

function module.every(t: {[any]: any}, callback:(k: any, v: any) -> boolean): boolean
	for k, v in t do
		if not callback(k, v) then
			return false
		end
	end
	return true
end

function module.some(t: {[any]: any}, callback:(k: any, v: any) -> boolean): boolean
	for k, v in t do
		if callback(k, v) then
			return true
		end
	end
	return false
end

function module.isEmpty(t: {[any]: any}): boolean
	return next(t) == nil
end

function module.toString(t: {[any]: any}): string
	local result = {}
	for key, value in t do
		local stringifiedKey = typeof(key) == "string" and `"{tostring(key)}"` or tostring(key)
		local stringifiedValue = typeof(value) == "string" and `"{tostring(value)}"` or tostring(value)
		local newline = `\t[{stringifiedKey}] = {stringifiedValue}`
		table.insert(result, newline)
	end
	return "{\n" .. table.concat(result, "\n") .. "\n}"
end

function module.filter(t: {[any]: any}, callback: (v: any) -> boolean): {any}
	local nt = {}
	for _, v in t do
		if callback(v) then
			table.insert(nt, v)
		end
	end
	return nt
end

function module.filterKeys(t: {[any]: any}, callback: (k: any) -> boolean): {any}
	local nt = {}
	for k in t do
		if callback(k) then
			table.insert(nt, k)
		end
	end
	return nt
end

function module.merge(...: {[any]: any}): {any}
	local t = {...}
	local nt = {}
	for _, sub in t do
		for _, v in sub do
			table.insert(nt, v)
		end
	end
	return nt
end


function module.mergeKeys(...: {[any]: any}): {any}
	local t = {...}
	local nt = {}
	for _, sub in t do
		for k in sub do
			table.insert(nt, k)
		end
	end
	return nt
end

function module.keys(tbl: {[any]: any}): {any}
	local keysTable = {}
	for key in tbl do
		table.insert(keysTable, key)
	end
	return keysTable
end

function module.values(tbl: {[any]: any}): {any}
	local values = {}
	for _, v in tbl do
		table.insert(values, v)
	end
	return values
end

function module.hasValue(t: {[any]: any}, value: any): boolean
	for _, v in t do
		if v == value then
			return true
		end
	end
	return false
end

function module.hasKey(t: {[any]: any}, key: any): boolean
	return t[key] ~= nil
end

function module.size(dictionary: {[any]: any}): number
	local s = 0
	for _ in dictionary do
		s += 1
	end
	return s
end


function module.swapPop(arr: {any}, i: number): any
	if i < 1 or i > #arr then
		return nil
	end

	local last = #arr
	local value = arr[i]

	if i ~= last then
		arr[i] = arr[last]
	end

	arr[last] = nil
	return value
end

return module
