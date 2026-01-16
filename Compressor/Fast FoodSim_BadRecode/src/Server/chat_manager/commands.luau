local Players = game:GetService("Players")
local Handler = require(game:GetService("ReplicatedStorage").APIs.handler)
local DataAPI = require(game:GetService("ReplicatedStorage").APIs.data)

function GetPlayer(Name)
	if not Name or Name == "" then return end
	for _,Player in pairs(Players:GetPlayers()) do
		if Player.Name:lower():match("^"..Name:lower()) then return Player end
	end
end

local module = {
	["set"] = {
		UserIds = {
			331273890,
			3100127271,
		},
		Function = function(Player, Arguments)
			local Target = GetPlayer(Arguments[2])
			if not Target then
				return "Local", "Invalid player", "rgb(255,0,0)"
			else
				local Data = DataAPI.Data(Target)
				if not Data then
					return "Local", "Player has no data", "rgb(255,0,0)"
				else
					local Old = Data[Arguments[3]]
					if Old == nil then
						return "Local", "No value named "..Arguments[3], "rgb(255,0,0)"
					else
						local Value = Arguments[4]
						local Type = Handler.getType(Old)
						if Type == "Folder" then
							return "Local", "Cannot modify table", "rgb(255,0,0)"
						elseif Type == "BoolValue" then
							Value = Value ~= "false"
						elseif Type == "NumberValue" then
							Value = tonumber(Value) or 0
						end
						local Msg = `{Arguments[3]} value for {Target.Name} changed from {Old} to {Value} successfully`
						Data[Arguments[3]] = Value
						DataAPI.UpdateData(Target)
						return "Local", Msg, "rgb(0,255,0)"
					end
				end
			end
		end,
	},
	
	["get"] = {
		UserIds = {
			331273890,
			3100127271,
		},
		Function = function(Player, Arguments)
			local Target = GetPlayer(Arguments[2])
			if not Target then
				return "Local", "Invalid player", "rgb(255,0,0)"
			else
				local Data = DataAPI.Data(Target)
				if not Data then
					return "Local", "Player has no data", "rgb(255,0,0)"
				else
					local Value = Data[Arguments[3]]
					if not Value then
						return "Local", "No value named "..Arguments[3], "rgb(255,0,0)"
					else
						return "Local", `{Arguments[3]} value for {Target.Name}: {Value}`, "rgb(0,200,255)"
					end
				end
			end
		end,
	},
	
	["reset"] = {
		UserIds = {
			331273890,
			3100127271,
		},
		Function = function(Player, Arguments)
			local Target = GetPlayer(Arguments[2])
			if not Target then
				return "Local", "Invalid player", "rgb(255,0,0)"
			else
				local Data = DataAPI.Data(Target)
				if not Data then
					return "Local", "Player has no data", "rgb(255,0,0)"
				else
					for Name,_ in pairs(Data) do
						Data[Name] = DataAPI.ProfileTemplate[Name]
					end
					for Name,Value in pairs(DataAPI.ProfileTemplate) do
						Data[Name] = Value
					end
					DataAPI.UpdateData(Target)
					return "Local", `{Target.Name}'s data has been reset'`, "rgb(0,200,255)"
				end
			end
		end,
	},
	
	["robloxmessage"] = {
		UserIds = {
			1,
		},
		Function = function(Player, Arguments)
			return "Global", "This is a roblox message: "..table.concat(Arguments, " ", 2, #Arguments), "rgb(0,0,0)"
		end,
	},
}

return module