local ReplicatedFirst = game:GetService("ReplicatedFirst")
local LemonSignal = require(ReplicatedFirst.Vendor.LemonSignal)

return {
    DeliverProducts = LemonSignal.new(),
    Grab = LemonSignal.new(),
    Release = LemonSignal.new(),
}