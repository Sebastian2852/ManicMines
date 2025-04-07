local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local TroveClass = require(ReplicatedStorage.Packages.trove)

local CameraMotor = Flipper.SingleMotor.new(70)
CameraMotor:onStep(function(Value)
	workspace.CurrentCamera.FieldOfView = Value
end)

return {
	init = function(Component)
		Component._Trove = TroveClass.new()
	end,

	didMount = function(Component)
		local Blur = Instance.new("BlurEffect")
		Blur.Name = "_GuiBlur"
		Blur.Size = 10
		Blur.Parent = Lighting

		CameraMotor:setGoal(Flipper.Spring.new(60, {
			frequency = 5,
			dampingRatio = 1,
		}))
		workspace.CurrentCamera:AddTag("FORCE_FOV")

		Component._Trove:Add(Blur)
		Component._Trove:Add(function()
			CameraMotor:setGoal(Flipper.Spring.new(70, {
				frequency = 5,
				dampingRatio = 1,
			}))
			workspace.CurrentCamera:AddTag("FORCE_FOV")
		end)
	end,

	willUnmount = function(Component)
		Component._Trove:Clean()
	end,
}
