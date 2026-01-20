--!strict
--[[
	HierarchyUtil: Utility for copying the game hierarchy into a table structure.
	Captures only instance names, not properties.
]]

local HierarchyUtil = {}

--[[
	Copies an instance and its descendants into a nested table structure.
	
	@param instance -- The instance to start from (default: game)
	@return table -- A nested table representing the hierarchy
	
	Example output:
	{
		Workspace = {
			Part1 = {},
			Folder = {
				Part2 = {},
				Part3 = {}
			}
		},
		ServerScriptService = {
			Script1 = {}
		}
	}
]]

    local HierarchyUtil = {}
function HierarchyUtil.copyHierarchy(instance: Instance?): { [string]: any }
	instance = instance or game
	local result = {}

	local function traverse(obj: Instance, tbl: { [string]: any }): nil
		for _, child in ipairs(obj:GetChildren()) do
			local childTable: { [string]: any } = {}
			traverse(child, childTable)
			tbl[child.Name] = childTable
		end
	end

	traverse(instance, result)
	return result
end
print(HierarchyUtil.copyHierarchy(game.StarterGui))
--[[
	Prints the hierarchy in a readable format for debugging.
	
	@param instance -- The instance to start from (default: game)
	@param indent -- Internal parameter for recursion (default: 0)
]]


    function HierarchyUtil.printHierarchy(instance: Instance?, indent: number?): nil
        instance = instance or game
        indent = indent or 0

        local function traverse(obj: Instance, depth: number): nil
            for _, child in ipairs(obj:GetChildren()) do
                print(string.rep("  ", depth) .. child.Name)
                traverse(child, depth + 1)
            end
        end

        print(instance.Name)
        traverse(instance, indent)
end
HierarchyUtil.printHierarchy(game)
return HierarchyUtil
