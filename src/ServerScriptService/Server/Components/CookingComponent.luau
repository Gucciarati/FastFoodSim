--!strict
local CookingComponent = {}

type Data = {
	Foods: { [string]: number },
	Assemblies: { [string]: number },
}

type CookingState = {
	FurnitureId: string,
	Status: "cooking" | "ready" | "idle",
	TimeStarted: number,
	Duration: number,
	Output: string,
}

local activeCookingSessions: { [string]: CookingState } = {}

function CookingComponent.StartCooking(playerId: string, furnitureId: string, duration: number, outputItem: string): boolean
	local sessionKey = playerId .. ":" .. furnitureId
	
	if activeCookingSessions[sessionKey] then
		return false
	end
	
	activeCookingSessions[sessionKey] = {
		FurnitureId = furnitureId,
		Status = "cooking",
		TimeStarted = os.time(),
		Duration = duration,
		Output = outputItem,
	}
	
	return true
end

function CookingComponent.FinishCooking(playerId: string, furnitureId: string, data: Data): (boolean, string?)
	local sessionKey = playerId .. ":" .. furnitureId
	local session = activeCookingSessions[sessionKey]
	
	if not session then
		return false, "No active cooking session"
	end
	
	activeCookingSessions[sessionKey] = nil
	
	if not data.Foods then
		data.Foods = {}
	end
	
	data.Foods[session.Output] = (data.Foods[session.Output] or 0) + 1
	
	return true, session.Output
end

function CookingComponent.CancelCooking(playerId: string, furnitureId: string): boolean
	local sessionKey = playerId .. ":" .. furnitureId
	
	if not activeCookingSessions[sessionKey] then
		return false
	end
	
	activeCookingSessions[sessionKey] = nil
	return true
end

function CookingComponent.GetCookingState(playerId: string, furnitureId: string): CookingState?
	local sessionKey = playerId .. ":" .. furnitureId
	return activeCookingSessions[sessionKey]
end

return CookingComponent
