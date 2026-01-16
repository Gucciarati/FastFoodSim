--!strict
local ReplicatedFirst   = game:GetService('ReplicatedFirst')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Utils            = ReplicatedStorage:WaitForChild('Utils')
local Vendor           = ReplicatedFirst.Vendor
local RequireAttribute = require(Utils.RequireAttribute)

local module = {
	Tags = {},
	Attributes = {}
}

return module
