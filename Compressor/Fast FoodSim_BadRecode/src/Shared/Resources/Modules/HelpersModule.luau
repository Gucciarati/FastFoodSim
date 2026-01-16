local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes.Gameplay

local Helpers = {}

function Helpers.cacheHideModel(model)
	local transparencyByDescendant, enabledByDescendant = {}, {}
	for _, d in ipairs(model:GetDescendants()) do
		if (d:IsA("BasePart") or d:IsA("MeshPart")) and d.Transparency < 1 then transparencyByDescendant[d]=d.Transparency d.Transparency=1 end
		if d:IsA("SurfaceGui") then enabledByDescendant[d]=d.Enabled d.Enabled=false end
	end
	return transparencyByDescendant, enabledByDescendant
end

function Helpers.restoreModel(transparencyByDescendant, enabledByDescendant)
	for part, oldTrans in pairs(transparencyByDescendant or {}) do if part and part.Parent then part.Transparency = oldTrans end end
	for part, e in pairs(enabledByDescendant or {}) do if part and part.Parent then part.Enabled = e end end
end

function Helpers.setCollisionGroupForModelParts(model, group)
	for _, d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then d.CollisionGroup = group end end
end

function Helpers.notifyPlayer(player, text, color)
	Remotes.Parent.Handler.Notify:FireClient(player, text, color)
end

function Helpers.notifyAll(text)
	Remotes.Parent.Handler.Notify:FireAllClients(text)
end

function Helpers.playAudio(player, key)
	Remotes.Parent.Handler.Audio:FireClient(player, key)
end

function Helpers.restaurantOf(player)
	return workspace:WaitForChild("OwnedRestaurants"):FindFirstChild(player.Name)
end

function Helpers.isWhitelisted(restaurant, player)
	return restaurant and restaurant.Whitelist:FindFirstChild(player.Name) ~= nil
end

function Helpers.seatsAvailable(restaurant)
	for _, tbl in pairs(restaurant.Furniture.Tables:GetChildren()) do
		for _, chairWrap in pairs(tbl.Chairs:GetChildren()) do
			local chair = chairWrap.Chair.Value
			if chair then
				for _, seat in pairs(chair.Seats:GetChildren()) do
					if   seat.NPC.Value == nil
						and not seat:GetAttribute("Occupied")
						and seat:FindFirstChildWhichIsA("Seat", true).Occupant == nil then
						return true
					end
				end
			end
		end
	end
	return false
end

return Helpers


