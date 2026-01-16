local ParticleEmitter = require(script.EmitParticle)
local BeamEmitter = require(script.EmitBeam)
local MeshEmitter = require(script.EmitMesh)

return function(attachment)
	local descendants = attachment:GetDescendants()
	table.insert(descendants, attachment)
	
	for _,descendant in pairs(descendants) do
		if descendant:IsA("ParticleEmitter") then
			local count = descendant:GetAttribute("EmitCount") or 0
			local delayC = descendant:GetAttribute("EmitDelay") or 0
			local setup = ParticleEmitter:new(descendant, count, delayC)
			setup:Emit()
		elseif descendant:IsA("Beam") then
			local count = descendant:GetAttribute("Duration") local width = descendant:GetAttribute("Width1") local delayC = descendant:GetAttribute("EmitDelay")
			local width00 = descendant:GetAttribute("Width0")
			local setup = BeamEmitter:new(descendant, count, delayC, width, width00)
			setup:Emit()
		elseif descendant:IsA("MeshPart") then
			local delayC = descendant:GetAttribute("EmitDelay") local duration = descendant:GetAttribute("Duration") local transparency = descendant:GetAttribute("Transparency")
			local size = descendant:GetAttribute("Size") local rotation = descendant:GetAttribute("Rotation")
			local timebeforerest = descendant:GetAttribute("TimeBeforeReset") local cf = descendant:GetAttribute("CFrame")
			MeshEmitter:Emit(descendant, descendant.Size, duration, delayC, transparency, size, rotation, timebeforerest, cf)
		end
	end
end