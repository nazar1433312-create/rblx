local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

Players.CharacterAutoLoads = false

local GameConfig = require(ReplicatedStorage.GameConfig)

local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

local issueOrder = Instance.new("RemoteEvent")
issueOrder.Name = "IssueOrder"
issueOrder.Parent = remotesFolder

local spawnUnitRemote = Instance.new("RemoteEvent")
spawnUnitRemote.Name = "SpawnUnit"
spawnUnitRemote.Parent = remotesFolder

local gameStateFolder = Instance.new("Folder")
gameStateFolder.Name = "GameState"
gameStateFolder.Parent = ReplicatedStorage

local function makeIntValue(name, value)
	local v = Instance.new("IntValue")
	v.Name = name
	v.Value = value
	v.Parent = gameStateFolder
	return v
end

local GameState = {
	Food = makeIntValue("Food", GameConfig.startingFood),
	NestHealth = makeIntValue("NestHealth", GameConfig.nestMaxHealth),
	NestMaxHealth = makeIntValue("NestMaxHealth", GameConfig.nestMaxHealth),
	Wave = makeIntValue("Wave", 0),
}

local gameOver = Instance.new("BoolValue")
gameOver.Name = "GameOver"
gameOver.Value = false
gameOver.Parent = gameStateFolder
GameState.GameOver = gameOver

local services = script.Parent:WaitForChild("services")
local WorldBuilder = require(services.WorldBuilder)
local ColonyService = require(services.ColonyService)
local UnitController = require(services.UnitController)
local EnemyWaveService = require(services.EnemyWaveService)

WorldBuilder.Build()
UnitController.Init(ColonyService)
ColonyService.Init(GameState, UnitController, WorldBuilder)
EnemyWaveService.Init(GameState, ColonyService, WorldBuilder)
EnemyWaveService.Start()

print("[Server] Infinity Waves core initialized")
