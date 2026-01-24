--!strict
export type ActionInfo = {
	Text: string,
	Keybind: Enum.KeyCode | Enum.UserInputType,
}

export type InteractionInfo = {
	Title: string,
	Actions: { [string]: ActionInfo },
}

export type AncestorResult = {
	Part: Instance,
	Info: InteractionInfo,
}

local Interactions: { [Instance]: InteractionInfo } = {}

local InteractionRegistry = {}

function InteractionRegistry.Register(Part: Instance, Info: InteractionInfo)
	Interactions[Part] = Info
end

function InteractionRegistry.Unregister(Part: Instance)
	Interactions[Part] = nil
end

function InteractionRegistry.Get(Part: Instance): InteractionInfo?
	return Interactions[Part]
end

function InteractionRegistry.GetAncestor(Target: Instance): AncestorResult?
	local Current: Instance? = Target
	while Current do
		if Interactions[Current] then
			return { Part = Current, Info = Interactions[Current] }
		end
		Current = Current.Parent
	end
	return nil
end

return InteractionRegistry
