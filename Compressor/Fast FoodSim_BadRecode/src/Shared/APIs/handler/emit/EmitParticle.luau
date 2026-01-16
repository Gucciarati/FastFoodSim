local attributes = {}
attributes.__index = attributes
attributes.EmitCount = 5
attributes.EmitDelay = 0
attributes.ParticleEmitter = nil

function attributes:new(ParticleEmitter : ParticleEmitter ,EmitCount : number, EmitDelay : number)
	local Settings = setmetatable({}, attributes)
	Settings.ParticleEmitter = ParticleEmitter
	Settings.EmitCount = EmitCount
	Settings.EmitDelay = EmitDelay
	return Settings
end

function attributes:Emit()
	local particle = self.ParticleEmitter
	local emitCount = self.EmitCount
	local emitDelay = self.EmitDelay
	
	task.delay(emitDelay, function()
		particle:Emit(emitCount)
	end)
end

return attributes