local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local SelectionController = {}

local Selected = {}
local dragStart

local function clearSelection()
	for _, model in Selected do
		local highlight = model:FindFirstChild("SelectionHighlight")
		if highlight then
			highlight:Destroy()
		end
	end
	table.clear(Selected)
end

local function addSelection(model)
	if table.find(Selected, model) then
		return
	end
	table.insert(Selected, model)
	local highlight = Instance.new("Highlight")
	highlight.Name = "SelectionHighlight"
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
	highlight.Parent = model
end

local function getUnitsInScreenRect(rectMin, rectMax)
	local camera = workspace.CurrentCamera
	local results = {}
	for _, model in CollectionService:GetTagged("PlayerUnit") do
		local screenPos, onScreen = camera:WorldToViewportPoint(model:GetPivot().Position)
		if onScreen and screenPos.X >= rectMin.X and screenPos.X <= rectMax.X and screenPos.Y >= rectMin.Y and screenPos.Y <= rectMax.Y then
			table.insert(results, model)
		end
	end
	return results
end

function SelectionController.GetSelected()
	return Selected
end

function SelectionController.Start(dragFrame)
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		dragStart = Vector2.new(mouse.X, mouse.Y)
		dragFrame.Visible = true
		dragFrame.Position = UDim2.fromOffset(dragStart.X, dragStart.Y)
		dragFrame.Size = UDim2.fromOffset(0, 0)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragStart or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local current = Vector2.new(mouse.X, mouse.Y)
		local topLeft = Vector2.new(math.min(dragStart.X, current.X), math.min(dragStart.Y, current.Y))
		local size = Vector2.new(math.abs(current.X - dragStart.X), math.abs(current.Y - dragStart.Y))
		dragFrame.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
		dragFrame.Size = UDim2.fromOffset(size.X, size.Y)
	end)

	UserInputService.InputEnded:Connect(function(input)
		if not dragStart or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		local current = Vector2.new(mouse.X, mouse.Y)
		dragFrame.Visible = false
		local dragDistance = (current - dragStart).Magnitude

		clearSelection()

		if dragDistance < 4 then
			local target = mouse.Target
			local model = target and target:FindFirstAncestorOfClass("Model")
			if model and CollectionService:HasTag(model, "PlayerUnit") then
				addSelection(model)
			end
		else
			local topLeft = Vector2.new(math.min(dragStart.X, current.X), math.min(dragStart.Y, current.Y))
			local bottomRight = Vector2.new(math.max(dragStart.X, current.X), math.max(dragStart.Y, current.Y))
			for _, model in getUnitsInScreenRect(topLeft, bottomRight) do
				addSelection(model)
			end
		end

		dragStart = nil
	end)
end

return SelectionController
