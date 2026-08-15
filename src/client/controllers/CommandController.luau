local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Net"))

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local CommandController = {}

function CommandController.Start(selectionController)
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe or input.UserInputType ~= Enum.UserInputType.MouseButton2 then
			return
		end
		local selected = selectionController.GetSelected()
		if #selected == 0 then
			return
		end
		local target = mouse.Target
		if not target then
			return
		end

		local model = target:FindFirstAncestorOfClass("Model")
		if model and CollectionService:HasTag(model, "Enemy") then
			Net.IssueOrder:FireServer(selected, "attack", model)
		elseif CollectionService:HasTag(target, "FoodNode") then
			Net.IssueOrder:FireServer(selected, "gather", target)
		else
			Net.IssueOrder:FireServer(selected, "move", mouse.Hit.Position)
		end
	end)
end

return CommandController
