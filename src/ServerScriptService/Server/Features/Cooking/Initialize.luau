--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateValue = require(ReplicatedStorage.Packages.StateValue)


StateValue.Create("ActiveCookingProcesses", {} :: {[number]: {[string]: any}})


require(script.Parent.Register)
require(script.Parent.AddKeypoint)
require(script.Parent.Finish)


return true
