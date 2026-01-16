local Signal = require(script:WaitForChild("signal"))

local module = {}

module.DevProducts = {
	["VIPCustomer"] = Signal.new(),
	["Gold2Hrs"] = Signal.new(),
	["Gold30Mins"] = Signal.new(),
	["Gold10Mins"] = Signal.new(),
	["NewExpansion"] = Signal.new()
}

return module