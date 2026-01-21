--!strict
local FurnitureComponent = {}

type Data = {
	Furniture: { [string]: FurnitureData },
}

type FurnitureData = {
	Item: string,
	Type: string,
	CF: string,
	Occupied: boolean?,
	Rotation: number?,
}

function FurnitureComponent.Place(data: Data, furnitureId: string, furnitureData: FurnitureData): boolean
	if data.Furniture[furnitureId] then
		return false
	end
	
	data.Furniture[furnitureId] = {
		Item = furnitureData.Item,
		Type = furnitureData.Type,
		CF = furnitureData.CF,
		Occupied = furnitureData.Occupied or false,
	}
	
	return true
end

function FurnitureComponent.Remove(data: Data, furnitureId: string): boolean
	if not data.Furniture[furnitureId] then
		return false
	end
	
	data.Furniture[furnitureId] = nil
	return true
end

function FurnitureComponent.Get(data: Data, furnitureId: string): FurnitureData?
	return data.Furniture[furnitureId]
end

function FurnitureComponent.UpdatePosition(data: Data, furnitureId: string, cfString: string): boolean
	if not data.Furniture[furnitureId] then
		return false
	end
	
	data.Furniture[furnitureId].CF = cfString
	return true
end

function FurnitureComponent.SetOccupied(data: Data, furnitureId: string, occupied: boolean): boolean
	if not data.Furniture[furnitureId] then
		return false
	end
	
	data.Furniture[furnitureId].Occupied = occupied
	return true
end

function FurnitureComponent.GetAll(data: Data): { [string]: FurnitureData }
	return data.Furniture
end

function FurnitureComponent.GetByType(data: Data, furnitureType: string): { [string]: FurnitureData }
	local result = {}
	for id, furniture in data.Furniture do
		if furniture.Type == furnitureType then
			result[id] = furniture
		end
	end
	return result
end

function FurnitureComponent.Exists(data: Data, furnitureId: string): boolean
	return data.Furniture[furnitureId] ~= nil
end

return FurnitureComponent
