--!strict

return function (DeliveryCFrame: CFrame, Lane: any, SpawnPoint: Part): Vector3
	local OrangePos = DeliveryCFrame.Position
	local BluePos = SpawnPoint.Position
	local ToOrange = OrangePos - BluePos
	local T = ToOrange:Dot(Lane.Dir)
	return BluePos + Lane.Dir * T
end
