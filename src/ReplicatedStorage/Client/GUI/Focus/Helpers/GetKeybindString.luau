--!strict
local function GetKeybindString(Keybind: Enum.KeyCode | Enum.UserInputType): string
	if typeof(Keybind) == "EnumItem" then
		if Keybind.EnumType == Enum.KeyCode then
			return Keybind.Name
		elseif Keybind == Enum.UserInputType.MouseButton1 then
			return "LMB"
		elseif Keybind == Enum.UserInputType.MouseButton2 then
			return "RMB"
		end
	end
	return tostring(Keybind)
end

return GetKeybindString
