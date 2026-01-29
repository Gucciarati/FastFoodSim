--!strict
--[[
	Cleanup Utility
	
	Manages cleanup of residual connections, functions, and objects.
	Used to clean up state between phase transitions in async operations.
	
	Cleanup accepts a table containing any of the following:
	- RBXScriptConnection: Will be disconnected
	- Instance: Will be destroyed
	- function: Will be called
	- Any other value: Will be cleared from the table
]]
local function Cleanup(residueTable: {[any]: any}?)
	if not residueTable then return end
	
	for key, item in residueTable do
		if item == nil then
			continue
		end
		
		-- Handle RBXScriptConnection
		if typeof(item) == "RBXScriptConnection" then
			if item.Connected then
				item:Disconnect()
			end
		-- Handle Instance
		elseif typeof(item) == "Instance" then
			if item.Parent then
				item:Destroy()
			end
		-- Handle function (cleanup callback)
		elseif typeof(item) == "function" then
			task.spawn(item)
		end
		
		-- Clear the reference
		residueTable[key] = nil
	end
end

return Cleanup
