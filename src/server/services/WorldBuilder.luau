local CollectionService = game:GetService("CollectionService")

local NEST_POSITION = Vector3.new(0, 3, 0)
local FOOD_NODE_OFFSETS = {
	Vector3.new(40, 1, 0),
	Vector3.new(-40, 1, 0),
	Vector3.new(0, 1, 40),
	Vector3.new(0, 1, -40),
}

local WorldBuilder = {}

local nest

function WorldBuilder.Build()
	nest = workspace:FindFirstChild("Nest")
	if not nest then
		nest = Instance.new("Part")
		nest.Name = "Nest"
		nest.Size = Vector3.new(10, 6, 10)
		nest.Position = NEST_POSITION
		nest.Anchored = true
		nest.Color = Color3.fromRGB(101, 67, 33)
		nest.Material = Enum.Material.Ground
		nest.Parent = workspace
	end

	local nodesFolder = workspace:FindFirstChild("FoodNodes")
	if not nodesFolder then
		nodesFolder = Instance.new("Folder")
		nodesFolder.Name = "FoodNodes"
		nodesFolder.Parent = workspace
		for i, offset in FOOD_NODE_OFFSETS do
			local node = Instance.new("Part")
			node.Name = "FoodNode" .. i
			node.Shape = Enum.PartType.Ball
			node.Size = Vector3.new(6, 6, 6)
			node.Position = NEST_POSITION + offset
			node.Anchored = true
			node.Color = Color3.fromRGB(85, 170, 85)
			node.Material = Enum.Material.Neon
			node:SetAttribute("FoodRemaining", 200)
			node.Parent = nodesFolder
			CollectionService:AddTag(node, "FoodNode")
		end
	end

	for _, folderName in { "Units", "Enemies" } do
		if not workspace:FindFirstChild(folderName) then
			local folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Parent = workspace
		end
	end
end

function WorldBuilder.GetNest()
	return nest
end

function WorldBuilder.GetSpawnPosition()
	local angle = math.random() * math.pi * 2
	local radius = 8 + math.random() * 4
	return nest.Position + Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius)
end

return WorldBuilder
