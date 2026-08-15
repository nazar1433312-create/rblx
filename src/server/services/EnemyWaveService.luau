local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnemyDefs = require(ReplicatedStorage.EnemyDefs)
local GameConfig = require(ReplicatedStorage.GameConfig)

local EnemyWaveService = {}

local GameState
local ColonyService
local WorldBuilder

local function createEnemyModel(enemyType, stats)
	local model = Instance.new("Model")
	model.Name = enemyType

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2.5, 1.6, 3.5)
	root.Color = stats.color
	root.Material = Enum.Material.SmoothPlastic
	root.CanCollide = false
	root.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = stats.maxHealth
	humanoid.Health = stats.maxHealth
	humanoid.WalkSpeed = stats.moveSpeed
	humanoid.Parent = model

	model.PrimaryPart = root
	return model
end

local function pickSpawnPosition()
	local angle = math.random() * math.pi * 2
	local radius = GameConfig.waveSpawnRadius
	return Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius)
end

local function acquireTarget(position)
	local nearestUnit, nearestDist
	for _, unit in CollectionService:GetTagged("PlayerUnit") do
		local dist = (unit:GetPivot().Position - position).Magnitude
		if dist <= GameConfig.enemyAggroRadius and (not nearestDist or dist < nearestDist) then
			nearestUnit, nearestDist = unit, dist
		end
	end
	if nearestUnit then
		return nearestUnit:GetPivot().Position, nearestUnit:FindFirstChildOfClass("Humanoid"), false
	end
	local nest = WorldBuilder.GetNest()
	return nest.Position, nil, true
end

local function spawnEnemy(enemyType)
	local stats = EnemyDefs[enemyType]
	local model = createEnemyModel(enemyType, stats)
	model:PivotTo(CFrame.new(pickSpawnPosition()))
	model.Parent = workspace.Enemies
	CollectionService:AddTag(model, "Enemy")

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	task.spawn(function()
		while model.Parent and humanoid.Health > 0 and not GameState.GameOver.Value do
			local targetPos, targetHumanoid, isNest = acquireTarget(model:GetPivot().Position)
			if not targetPos then
				task.wait(0.5)
				continue
			end
			local dist = (targetPos - model:GetPivot().Position).Magnitude
			if dist > stats.attackRange then
				humanoid:MoveTo(targetPos)
				task.wait(0.3)
			elseif isNest then
				ColonyService.DamageNest(stats.damage)
				task.wait(stats.attackCooldown)
			elseif targetHumanoid and targetHumanoid.Health > 0 then
				targetHumanoid:TakeDamage(stats.damage)
				task.wait(stats.attackCooldown)
			else
				task.wait(0.3)
			end
		end
		if model.Parent then
			model:Destroy()
		end
	end)
end

function EnemyWaveService.Init(gameState, colonyService, worldBuilder)
	GameState = gameState
	ColonyService = colonyService
	WorldBuilder = worldBuilder
end

function EnemyWaveService.Start()
	task.spawn(function()
		task.wait(GameConfig.firstWaveDelaySeconds)
		local waveNumber = 0
		while not GameState.GameOver.Value do
			waveNumber += 1
			GameState.Wave.Value = waveNumber
			local enemyCount = math.floor(GameConfig.enemiesPerWaveBase * (GameConfig.enemiesPerWaveGrowth ^ (waveNumber - 1)))
			for _ = 1, enemyCount do
				if GameState.GameOver.Value then
					break
				end
				spawnEnemy("Termite")
				task.wait(1.5)
			end
			task.wait(GameConfig.waveIntervalSeconds)
		end
	end)
end

return EnemyWaveService
