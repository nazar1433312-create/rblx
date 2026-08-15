local controllers = script.Parent:WaitForChild("controllers")

local CameraController = require(controllers.CameraController)
local SelectionController = require(controllers.SelectionController)
local CommandController = require(controllers.CommandController)
local HUDController = require(controllers.HUDController)

CameraController.Start()
local dragFrame = HUDController.Start()
SelectionController.Start(dragFrame)
CommandController.Start(SelectionController)

print("[Client] RTS core initialized")
