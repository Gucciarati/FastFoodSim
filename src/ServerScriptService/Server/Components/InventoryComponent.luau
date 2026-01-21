--!strict
local InventoryComponent = {}

type Data = {
	Foods: { [string]: number },
	Assemblies: { [string]: number },
	Furniture: { [string]: any },
}

function InventoryComponent.Add(data: Data, category: string, itemName: string, amount: number): boolean
	if amount < 0 then return false end
	
	if not data[category] then
		data[category] = {}
	end
	
	data[category][itemName] = (data[category][itemName] or 0) + amount
	return true
end

function InventoryComponent.Remove(data: Data, category: string, itemName: string, amount: number): boolean
	if amount < 0 then return false end
	
	if not data[category] or not data[category][itemName] then
		return false
	end
	
	if data[category][itemName] < amount then
		return false
	end
	
	data[category][itemName] -= amount
	
	if data[category][itemName] == 0 then
		data[category][itemName] = nil
	end
	
	return true
end

function InventoryComponent.Get(data: Data, category: string, itemName: string): number
	if not data[category] or not data[category][itemName] then
		return 0
	end
	return data[category][itemName]
end

function InventoryComponent.Set(data: Data, category: string, itemName: string, amount: number): boolean
	if amount < 0 then return false end
	
	if not data[category] then
		data[category] = {}
	end
	
	if amount == 0 then
		data[category][itemName] = nil
	else
		data[category][itemName] = amount
	end
	
	return true
end

function InventoryComponent.Clear(data: Data, category: string): boolean
	if not data[category] then
		return false
	end
	
	data[category] = {}
	return true
end

function InventoryComponent.GetAll(data: Data, category: string): { [string]: number }
	if not data[category] then
		return {}
	end
	return data[category]
end

function InventoryComponent.HasEnough(data: Data, category: string, itemName: string, amount: number): boolean
	return InventoryComponent.Get(data, category, itemName) >= amount
end

return InventoryComponent
