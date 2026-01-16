local springUtil = require(script.SpringUtil)

local function spring(instance: Instance)
	local completed = Instance.new('BindableEvent')
	
	local function toTarget(properties: {[string]: any}, seconds: number, dampingRatio: number?)
		local frequency = 1/seconds
		dampingRatio = dampingRatio or 1
		--\\ damping and frequency must be bigger than 0 else it'll error
		springUtil.target(instance, math.clamp(dampingRatio, 0, 1000) :: number, math.clamp(frequency, 0, 1000), properties)
	end
	
	local function stop()
		springUtil.stop(instance)
	end

	-- There's something odd about this callback. there's always a slim chance it won't fire when completed
	springUtil.completed(instance, function() 
		completed:Fire()
	end)
	
	-- there's no real way to destroy the spring through the spring util
	-- the spring util leaks instances. I gotta patch it
	return {
		toTarget = toTarget,
		stop = stop,
		completed = completed,
	}
end


return spring