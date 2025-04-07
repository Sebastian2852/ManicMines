local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local WorldEffectsController = Knit.CreateController({ Name = "WorldEffectsController" })

local SettingsController

function WorldEffectsController:KnitStart()
	SettingsController = Knit.GetController("PlayerSettingsController")
	local TaggedModels = CollectionService:GetTagged("Effects/Spin")

	RunService.Heartbeat:Connect(function(Delta)
		if SettingsController:GetSetting("Wind") == true then
			for _, Model: Model in pairs(TaggedModels) do
				local Spin = Model:GetAttribute("SpinEffectAxis")
				local SpinStrenght = Model:GetAttribute("SpinEffectStrength")

				local Pivot = Model:GetPivot()
				local Rotation = CFrame.Angles(
					Spin == "x" and math.rad(SpinStrenght) * Delta or 0,
					Spin == "y" and math.rad(SpinStrenght) * Delta or 0,
					Spin == "z" and math.rad(SpinStrenght) * Delta or 0
				)

				Model:PivotTo(Pivot * Rotation)
			end
		end
	end)

	CollectionService:GetInstanceAddedSignal("Effects/Spin"):Connect(function(Model)
		table.insert(TaggedModels, Model)
	end)

	CollectionService:GetInstanceRemovedSignal("Effects/Spin"):Connect(function(Model)
		local i = table.find(TaggedModels, Model)
		if i then
			table.remove(TaggedModels, i)
		end
	end)
end

return WorldEffectsController
