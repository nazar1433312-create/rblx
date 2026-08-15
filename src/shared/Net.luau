local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

return {
	IssueOrder = remotesFolder:WaitForChild("IssueOrder"),
	SpawnUnit = remotesFolder:WaitForChild("SpawnUnit"),
}
