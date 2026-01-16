local ts = game:GetService("TweenService")
local attributes = {}
attributes.__index = attributes
attributes.EmitDuration = 0.3
attributes.EmitDelay = 0
attributes.Width1 = 1
attributes.Width0 = 1
attributes.Beam = nil

function attributes:new(Beam : Beam , EmitDuration : number, EmitDelay : number, Width1 : number, Width0 : number)
	local Settings = setmetatable({}, attributes)
	Settings.Beam = Beam
	Settings.EmitDuration = EmitDuration
	Settings.EmitDelay = EmitDelay
	Settings.Width1 = Width1
	Settings.Width0 = Width0
	return Settings
end

function attributes:Emit()
	local beam = self.Beam
	local emitDuration = self.EmitDuration
	local emitDelay = self.EmitDelay
	local width1 = self.Width1
	local width0 = self.Width0
	local previous = beam.Width0
	beam.Width0 = 0
	beam.Width1 = 0
	task.delay(emitDelay, function()
		ts:Create(beam, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Width0 = width0}):Play()
		ts:Create(beam, TweenInfo.new(.2, Enum.EasingStyle.Linear), {Width1 = width1}):Play()
		task.delay(emitDuration +.2, function()
			ts:Create(beam, TweenInfo.new(.3, Enum.EasingStyle.Linear), {Width0 = 0}):Play()
			ts:Create(beam, TweenInfo.new(.3, Enum.EasingStyle.Linear), {Width1 = 0}):Play()
		end)
	end)
end

return attributes