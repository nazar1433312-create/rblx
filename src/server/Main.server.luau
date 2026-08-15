local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Example = require(ReplicatedStorage.Example)

print("[Server] " .. Example.greet("world"))
