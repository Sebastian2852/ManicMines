local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

local Tutorial = Roact.Component:extend("Tutorial")

function Tutorial:init()
	local DataFolder = self.props.DataFolder :: Core.DataFolder
	local InitialStage = DataFolder.TutorialStage.Value

	DataFolder.TutorialStage:GetPropertyChangedSignal("Value"):Connect(function()
		self:setState({
			Stage = DataFolder.TutorialStage.Value,
		})
	end)

	self:setState({
		Stage = InitialStage,
	})
end

function Tutorial:render()
	local Stage = self.state.Stage

	local StageGUIContent: Roact.Component = script:FindFirstChild(Stage)
	if StageGUIContent then
		StageGUIContent = require(StageGUIContent)
	else
		warn("No gui content for tutorial stage")
	end

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		DisplayOrder = 10,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Container = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			App = StageGUIContent and Roact.createElement(StageGUIContent),
		}),
	})
end

return Tutorial
