--\\ Ever wanted to find a child or ancestor that matches a name and class? now you can :)
--\\ Common, frequently parented Roblox classes as string singletons used for giveInstance()
export type ClassName =
	-- World geometry / containers
	"Part" | "MeshPart" | "WedgePart" | "CornerWedgePart" | "TrussPart"
| "Model" | "Folder"

-- Attachments & constraints / forces
| "Attachment"
| "WeldConstraint" | "HingeConstraint" | "BallSocketConstraint" | "RigidConstraint"
| "RopeConstraint" | "SpringConstraint" | "SlidingBallConstraint" | "PrismaticConstraint"
| "AngularVelocity" | "LinearVelocity" | "VectorForce" | "Torque"

-- Interaction
| "ClickDetector" | "ProximityPrompt" | "TouchInterest" | "DragDetector" -- TouchInterest is what Parts use

-- Characters / animation plumbing
| "Humanoid" | "Animator" | "AnimationController" | "Animation"| "HumanoidDescription"

-- Audio
| "Sound" | "SoundGroup"
| "ChorusSoundEffect" | "CompressorSoundEffect" | "DistortionSoundEffect"
| "EchoSoundEffect" | "EqualizerSoundEffect" | "FlangeSoundEffect"
| "PitchShiftSoundEffect" | "ReverbSoundEffect" | "TremoloSoundEffect"

-- Visuals / effects
| "ParticleEmitter" | "Trail" | "Beam"
| "Decal" | "Texture" | "Highlight" | "PointLight" | "SpotLight" | "SurfaceLight"

-- UI you might attach to parts/models (plus ScreenGui for completeness)
| "BillboardGui" | "SurfaceGui" | "ScreenGui"

-- Networking & bindables
| "RemoteEvent" | "RemoteFunction" | "BindableEvent" | "BindableFunction"

-- Value objects (handy config/state blobs)
| "BoolValue" | "IntValue" | "NumberValue" | "StringValue" | "ObjectValue"
| "Vector3Value" | "CFrameValue" | "Color3Value"
-- Seats
|'VehicleSeat' | 'Seat';


local Find = {}

function Find.firstChildWithNameOfClass<T>(withinInstance: Instance, name: string, className: ClassName, recursive: true?): T
	local descendants: {Instance} = if recursive then withinInstance:GetDescendants() else withinInstance:GetChildren()
	for _, descendant in descendants do
		if descendant.Name == name and descendant.ClassName == className then 
			return descendant
		end
	end
end


function Find.firstChildWithNameWhichIsA<T>(withinInstance: Instance, name: string, className: ClassName, recursive: true?): T
	local descendants: {Instance} = if recursive then withinInstance:GetDescendants() else withinInstance:GetChildren()
	for _, descendant in descendants do
		if descendant.Name == name and descendant:IsA(className) then 
			return descendant
		end
	end
end

return Find
