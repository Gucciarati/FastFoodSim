export type RunServiceEventName =
	'PreSimulation'
| 'PreAnimation'
| 'PreRender' -- same as stepped
| 'PostSimulation'  -- same as heartbeat
| "Heartbeat"


local UpdateEvery = {}


local function steppedUpdate()
	
end



function UpdateEvery(ammount: number)
	return {
		frames,
		seconds,
	}
end








return UpdateEvery
