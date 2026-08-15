local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitDefs = require(ReplicatedStorage.UnitDefs)
local Net = require(ReplicatedStorage.Net)

local ColonyService = {}

local GameState
local UnitController
local WorldBuilder
local pendingSpawns = {}

function ColonyService.AddFood(amount: number)
	GameState.Food.Value += amount
end

function ColonyService.DamageNest(amount: number)
	if GameState.GameOver.Value then
		return
	end
	GameState.NestHealth.Value = math.max(0, GameState.NestHealth.Value - amount)
	if GameState.NestHealth.Value <= 0 then
		GameState.GameOver.Value = true
	end
end

function ColonyService.Init(gameState, unitController, worldBuilder)
	GameState = gameState
	UnitController = unitController
	WorldBuilder = worldBuilder

	Net.SpawnUnit.OnServerEvent:Connect(function(_player, unitType)
		if GameState.GameOver.Value then
			return
		end
		local stats = UnitDefs[unitType]
		if not stats then
			return
		end
		if GameState.Food.Value < stats.cost then
			return
		end
		GameState.Food.Value -= stats.cost
		table.insert(pendingSpawns, {
			readyTime = os.clock() + stats.buildTime,
			unitType = unitType,
		})
	end)

	task.spawn(function()
		while true do
			task.wait(0.25)
			local now = os.clock()
			for i = #pendingSpawns, 1, -1 do
				local pending = pendingSpawns[i]
				if now >= pending.readyTime then
					table.remove(pendingSpawns, i)
					UnitController.SpawnUnit(pending.unitType, WorldBuilder.GetSpawnPosition())
				end
			end
		end
	end)
end

return ColonyService
