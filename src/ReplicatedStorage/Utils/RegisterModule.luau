--!strict
local mainModule = {}
local _debug = false

function mainModule.requireModules(moduleList: {ModuleScript | Folder})
	for _, module in moduleList do
		--\\ Case so you can scope modules in folders and not have to require the whole damn list of children
		if module:IsA('Folder') or module:IsA('Configuration') then
			mainModule.requireModules(module:GetChildren() :: {ModuleScript | Folder})
		elseif module:IsA('ModuleScript') then
			local isEnabled = module:GetAttribute("Enabled")
			if isEnabled == nil or isEnabled == true then

				local success, service = task.spawn(pcall, require, module)
				if success then
					print("[Module Loaded]:", module:GetFullName())

					if type(service) == "table" and typeof(service.init) == "function" then
						local initSuccess, err = pcall(service.init, service)
						if not initSuccess and _debug then
							warn("[Module Init Failed]:", module:GetFullName(), err)
						end
					end
				else
					warn("[Module Require Failed]:", module:GetFullName(), service)
				end
			else
				print("[Module Skipped (Disabled)]:", module:GetFullName())
			end
		end
	end
end
return mainModule
