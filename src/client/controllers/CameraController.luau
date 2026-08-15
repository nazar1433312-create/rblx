local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local MIN_ZOOM = 20
local MAX_ZOOM = 120
local PAN_SPEED = 60
local PITCH_DEGREES = 55

local CameraController = {}

function CameraController.Start()
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable

	local focus = Vector3.new(0, 0, 0)
	local zoom = 60
	local pressed = {}

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end
		pressed[input.KeyCode] = true
	end)

	UserInputService.InputEnded:Connect(function(input)
		pressed[input.KeyCode] = nil
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			zoom = math.clamp(zoom - input.Position.Z * 8, MIN_ZOOM, MAX_ZOOM)
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		local move = Vector3.new(0, 0, 0)
		if pressed[Enum.KeyCode.W] then
			move += Vector3.new(0, 0, -1)
		end
		if pressed[Enum.KeyCode.S] then
			move += Vector3.new(0, 0, 1)
		end
		if pressed[Enum.KeyCode.A] then
			move += Vector3.new(-1, 0, 0)
		end
		if pressed[Enum.KeyCode.D] then
			move += Vector3.new(1, 0, 0)
		end
		if move.Magnitude > 0 then
			focus += move.Unit * PAN_SPEED * dt * (zoom / 60)
		end

		local pitchRad = math.rad(PITCH_DEGREES)
		local offset = Vector3.new(0, math.sin(pitchRad), math.cos(pitchRad)) * zoom
		camera.CFrame = CFrame.lookAt(focus + offset, focus)
	end)
end

return CameraController
