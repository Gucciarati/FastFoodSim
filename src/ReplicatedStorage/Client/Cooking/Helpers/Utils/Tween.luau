local TweenService = game:GetService("TweenService")

return function(Instance: Instance, TweenData: {number | string}, Properties: {[string]: any})
	local Info = TweenInfo.new(
		TweenData[1] or 1,
		Enum.EasingStyle[TweenData[2] or "Quad"],
		Enum.EasingDirection[TweenData[3] or "Out"],
		TweenData[4] or 0,
		TweenData[5] or false,
		TweenData[6] or 0
	)
	return TweenService:Create(Instance, Info, Properties)
end
