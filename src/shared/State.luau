local ReplicatedStorage = game:GetService("ReplicatedStorage")
local folder = ReplicatedStorage:WaitForChild("GameState")

return {
	Food = folder:WaitForChild("Food"),
	NestHealth = folder:WaitForChild("NestHealth"),
	NestMaxHealth = folder:WaitForChild("NestMaxHealth"),
	Wave = folder:WaitForChild("Wave"),
	GameOver = folder:WaitForChild("GameOver"),
}
