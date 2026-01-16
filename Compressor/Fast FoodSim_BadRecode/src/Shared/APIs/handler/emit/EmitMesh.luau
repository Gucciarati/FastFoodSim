local ts = game:GetService("TweenService")
local attributes = {}

function attributes:Emit( Mesh ,MeshSize, EmitDuration, emitDelay, transparency, Size, Rotation, BeforeReset, Cframe)
	local  Mesh = Mesh
	local MeshSize =MeshSize or Mesh.Size
	local EmitDuration = EmitDuration or 1
	local emitDelay = emitDelay or 0
	local transparency = transparency or 0
	local BeforeReset = BeforeReset or 1
	
	local oldTransparency = Mesh.Transparency
	local oldSize = Mesh.Size
	local oldRot = Mesh.Orientation
	local oldCf = Mesh.CFrame
	BeforeReset += EmitDuration
	if Rotation then
		Rotation = string.split(Rotation, ",")
		if Vector3.new(Rotation[1], Rotation[2], Rotation[3]) == Vector3.new(0, 0, 0) or nil then
			Rotation = Vector3.new(0,0,0)
		else 
			Rotation = Vector3.new(Rotation[1], Rotation[2], Rotation[3])
		end
	else
		Rotation = Vector3.new(0,0,0)
	end
	
	if Size then
		Size = string.split(Size, ",")
		if Vector3.new(Size[1], Size[2], Size[3]) == Vector3.new(0, 0, 0) or nil then
			Size = Vector3.new(0, 0, 0)
		else 
			Size = Vector3.new(Size[1], Size[2], Size[3])
		end
	else
		Size = Vector3.new(0, 0, 0)
	end
	
	if Cframe then
		Cframe = string.split(Cframe, ",")
		if CFrame.new(Cframe[1], Cframe[2], Cframe[3]) == CFrame.new(0, 0, 0) then
			Cframe = CFrame.new(0, 0, 0)
		else 
			Cframe = CFrame.new(Cframe[1], Cframe[2], Cframe[3])
		end
	else
		Cframe = CFrame.new(0, 0, 0)
	end
	

	local info = TweenInfo.new(EmitDuration, Enum.EasingStyle.Linear)
	local change = {
		Size = Vector3.new(Size),
		Orientation = Vector3.new(Rotation),
		Transparency = transparency
	}

	task.delay(emitDelay, function()
		ts:Create(Mesh, info, {Size = Mesh.Size + Size}):Play()
		ts:Create(Mesh, info, {Orientation = Mesh.Orientation + Rotation}):Play()
		ts:Create(Mesh, info, {CFrame = Mesh.CFrame * Cframe}):Play()
		ts:Create(Mesh, info, {Transparency = transparency}):Play()
		task.delay(BeforeReset, function()
				Mesh.Size = oldSize
				Mesh.Transparency = oldTransparency
			Mesh.Orientation = oldRot
			Mesh.CFrame = oldCf
		end)
	end)
end

return attributes