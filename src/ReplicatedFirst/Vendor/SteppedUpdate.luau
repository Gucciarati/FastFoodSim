export type RunServiceEventName =
 'PreSimulation'
| 'PreAnimation'
| 'PreRender' -- same as stepped
| 'PostSimulation'  -- same as heartbeat
| "Heartbeat"


local RunService = game:GetService('RunService')

return function(runServiceEvent: RunServiceEventName, rate: number, callback: (dt: number) -> ()): RBXScriptConnection
	local timesPerSecond = math.clamp(rate, 1, 60)
	local interval = 1 / timesPerSecond
	local timeSinceLastCall = 0

	return RunService[runServiceEvent]:Connect(function(dt)
		timeSinceLastCall += dt
		if timeSinceLastCall >= interval then
			local callbackDT = timeSinceLastCall
			--timeSinceLastCall = 0
			callback(callbackDT)
			timeSinceLastCall %= interval -- account for time overflow 
		end
	end)
end

--[[

TODO: Implement 2.0 version of this module with the following fluent api

Vendor.updateEvery(60).hertz('PostSimulation', function(dt)
	
end)

Vendor.updateEvery(60).secondsInterval('PostSimulation', function(dt)

end)

Vendor.timer(60).seconds(onEnded())

]]
