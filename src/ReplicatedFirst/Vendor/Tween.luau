--!strict
local TweenService = game:GetService('TweenService')
export type TInfo = TweenInfo | {Time: number?, EasingStyle: Enum.EasingStyle?, EasingDirection: Enum.EasingDirection?, RepeatCount: number?, Reverses: boolean?, DelayTime: number?}


--[[
    @description
    Creates a tween for the given instance with a more flexible TweenInfo definition which
    accepts a table to construct TweenInfo letting you define only the arguments you need 
    and skip the brain damage of using the rigid constructor Roblox gave us.
	
    @params
    - instance: Instance — The object to tween.
    - info: TweenInfo | {Time, EasingStyle, EasingDirection, RepeatCount, Reverses, DelayTime} — TweenInfo or a table defining its properties.
    - propertyTable: {[string]: any} — The properties to tween and their target values.

    @returns
    - Tween — The created Tween object.
]]

local function createTween(
	instance: Instance, 
	propertyTable: {[string]: any},
	info: TInfo?
): Tween

	info = (info or {}):: TInfo
	assert(info)

	local tweenInfo = typeof(info) == "TweenInfo" and info or TweenInfo.new(
		info.Time or 0.1, 
		info.EasingStyle or Enum.EasingStyle.Linear,
		info.EasingDirection or Enum.EasingDirection.InOut,
		info.RepeatCount or 0,
		info.Reverses or false,
		info.DelayTime or 0
	)

	return TweenService:Create(
		instance,
		tweenInfo,
		propertyTable		
	)
end



return createTween