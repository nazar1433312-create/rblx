local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameState = require(ReplicatedStorage:WaitForChild("State"))
local Net = require(ReplicatedStorage:WaitForChild("Net"))
local UnitDefs = require(ReplicatedStorage:WaitForChild("UnitDefs"))

local player = Players.LocalPlayer

local HUDController = {}

local function makeLabel(parent, position, textGetter)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 220, 0, 28)
	label.Position = position
	label.BackgroundTransparency = 0.4
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	local function update()
		label.Text = "  " .. textGetter()
	end
	update()
	return update
end

local function makeSpawnButton(parent, position, unitType)
	local stats = UnitDefs[unitType]
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 180, 0, 40)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.Text = stats.displayName .. " (" .. stats.cost .. ")"
	button.Parent = parent
	button.MouseButton1Click:Connect(function()
		Net.SpawnUnit:FireServer(unitType)
	end)
end

function HUDController.Start()
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameHUD"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local dragFrame = Instance.new("Frame")
	dragFrame.Name = "SelectionBox"
	dragFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
	dragFrame.BackgroundTransparency = 0.7
	dragFrame.BorderSizePixel = 1
	dragFrame.Visible = false
	dragFrame.ZIndex = 10
	dragFrame.Parent = screenGui

	local updates = {}
	table.insert(updates, makeLabel(screenGui, UDim2.fromOffset(20, 20), function()
		return "Food: " .. GameState.Food.Value
	end))
	table.insert(updates, makeLabel(screenGui, UDim2.fromOffset(20, 56), function()
		return "Nest: " .. GameState.NestHealth.Value .. " / " .. GameState.NestMaxHealth.Value
	end))
	table.insert(updates, makeLabel(screenGui, UDim2.fromOffset(20, 92), function()
		return "Wave: " .. GameState.Wave.Value
	end))

	makeSpawnButton(screenGui, UDim2.fromOffset(20, 140), "Worker")
	makeSpawnButton(screenGui, UDim2.fromOffset(20, 188), "Soldier")

	local gameOverLabel = Instance.new("TextLabel")
	gameOverLabel.Size = UDim2.new(0, 400, 0, 80)
	gameOverLabel.Position = UDim2.new(0.5, -200, 0.4, 0)
	gameOverLabel.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
	gameOverLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	gameOverLabel.Font = Enum.Font.GothamBold
	gameOverLabel.TextSize = 28
	gameOverLabel.Text = "NEST DESTROYED"
	gameOverLabel.Visible = GameState.GameOver.Value
	gameOverLabel.Parent = screenGui

	GameState.GameOver:GetPropertyChangedSignal("Value"):Connect(function()
		gameOverLabel.Visible = GameState.GameOver.Value
	end)

	for _, valueObject in { GameState.Food, GameState.NestHealth, GameState.NestMaxHealth, GameState.Wave } do
		valueObject:GetPropertyChangedSignal("Value"):Connect(function()
			for _, update in updates do
				update()
			end
		end)
	end

	return dragFrame
end

return HUDController
