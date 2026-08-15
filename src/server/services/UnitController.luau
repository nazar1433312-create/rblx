local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitDefs = require(ReplicatedStorage.UnitDefs)
local GameConfig = require(ReplicatedStorage.GameConfig)
local Net = require(ReplicatedStorage.Net)

local UnitController = {}

local ActiveUnits = {}
local ColonyService

local function createUnitModel(unitType, stats)
	local model = Instance.new("Model")
	model.Name = unitType

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 1.4, 3)
	root.Color = stats.color
	root.Material = Enum.Material.SmoothPlastic
	root.CanCollide = false
	root.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.2, 1, 1.2)
	head.Color = stats.color
	head.CanCollide = false
	head.CFrame = root.CFrame * CFrame.new(0, 0.3, -2)
	head.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = head
	weld.Parent = head

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = stats.maxHealth
	humanoid.Health = stats.maxHealth
	humanoid.WalkSpeed = stats.moveSpeed
	humanoid.Parent = model

	model.PrimaryPart = root
	return model
end

local function findNearestTagged(tag, position, maxRange)
	local nearest, nearestDist
	for _, instance in CollectionService:GetTagged(tag) do
		local dist = (instance:GetPivot().Position - position).Magnitude
		if dist <= maxRange and (not nearestDist or dist < nearestDist) then
			nearest, nearestDist = instance, dist
		end
	end
	return nearest
end

local function runGather(model, humanoid, data, order)
	local node = order.target
	if not (node and node.Parent) then
		data.order = nil
		return
	end

	humanoid:MoveTo(node.Position)
	humanoid.MoveToFinished:Wait()

	while data.order == order and humanoid.Health > 0 and node.Parent and (node:GetAttribute("FoodRemaining") or 0) > 0 do
		task.wait(1 / data.stats.gatherRate)
		if data.order ~= order or not node.Parent then
			break
		end
		local remaining = node:GetAttribute("FoodRemaining") or 0
		if remaining <= 0 then
			break
		end
		node:SetAttribute("FoodRemaining", remaining - 1)
		ColonyService.AddFood(1)
	end

	if node.Parent and (node:GetAttribute("FoodRemaining") or 0) <= 0 then
		node:Destroy()
	end
	if data.order == order then
		data.order = nil
	end
end

local function runAttack(model, humanoid, data, order)
	local target = order.target
	if not (target and target.Parent) then
		data.order = nil
		return
	end
	local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
	if not targetHumanoid then
		data.order = nil
		return
	end

	while data.order == order and humanoid.Health > 0 and target.Parent and targetHumanoid.Health > 0 do
		local myPos = model:GetPivot().Position
		local targetPos = target:GetPivot().Position
		local dist = (targetPos - myPos).Magnitude
		if dist > data.stats.attackRange then
			humanoid:MoveTo(targetPos)
			task.wait(0.2)
		else
			targetHumanoid:TakeDamage(data.stats.damage)
			task.wait(data.stats.attackCooldown)
		end
	end
	if data.order == order then
		data.order = nil
	end
end

local function unitBrain(model, data)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	while model.Parent and humanoid.Health > 0 do
		local order = data.order
		if order == nil then
			local enemy = findNearestTagged("Enemy", model:GetPivot().Position, GameConfig.guardRadius)
			if enemy then
				data.order = { kind = "attack", target = enemy }
			else
				task.wait(0.3)
			end
		elseif order.kind == "move" then
			humanoid:MoveTo(order.target)
			humanoid.MoveToFinished:Wait()
			if data.order == order then
				data.order = nil
			end
		elseif order.kind == "gather" then
			if not data.stats.canGather then
				data.order = nil
			else
				runGather(model, humanoid, data, order)
			end
		elseif order.kind == "attack" then
			runAttack(model, humanoid, data, order)
		end
	end

	ActiveUnits[model] = nil
	if model.Parent then
		model:Destroy()
	end
end

function UnitController.SpawnUnit(unitType, position)
	local stats = UnitDefs[unitType]
	if not stats then
		return nil
	end

	local model = createUnitModel(unitType, stats)
	model:PivotTo(CFrame.new(position))
	model.Parent = workspace.Units
	CollectionService:AddTag(model, "PlayerUnit")

	local data = { stats = stats, order = nil, unitType = unitType }
	ActiveUnits[model] = data
	task.spawn(unitBrain, model, data)
	return model
end

local function isValidPlayerUnit(model)
	return typeof(model) == "Instance" and ActiveUnits[model] ~= nil
end

function UnitController.Init(colonyService)
	ColonyService = colonyService

	Net.IssueOrder.OnServerEvent:Connect(function(_player, units, orderKind, target)
		if typeof(units) ~= "table" then
			return
		end
		for _, unitModel in units do
			if not isValidPlayerUnit(unitModel) then
				continue
			end
			local data = ActiveUnits[unitModel]
			if orderKind == "move" and typeof(target) == "Vector3" then
				data.order = { kind = "move", target = target }
			elseif orderKind == "gather" and typeof(target) == "Instance" and CollectionService:HasTag(target, "FoodNode") then
				data.order = { kind = "gather", target = target }
			elseif orderKind == "attack" and typeof(target) == "Instance" and CollectionService:HasTag(target, "Enemy") then
				data.order = { kind = "attack", target = target }
			end
		end
	end)
end

return UnitController
