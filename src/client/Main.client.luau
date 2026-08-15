local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Example = require(ReplicatedStorage.Example)

print("[Client] " .. Example.greet("player"))
